--!native
local Config = require(script.Parent.config)
local Types = require(script.Parent.types)

local GRAVITY = Config.GRAVITY
local PER_WAVE_JITTER = Config.PER_WAVE_JITTER
local NOISE_SCALE = Config.NOISE_SCALE
local NOISE_TIME_SCALE = Config.NOISE_TIME_SCALE
local NOISE_CONTRAST = Config.NOISE_CONTRAST
local MID_RADIUS = Config.MID_RADIUS
local NEAR_RADIUS = Config.NEAR_RADIUS
local FAR_FLATTEN_START = Config.FAR_FLATTEN_START
local GLOBAL_TIME_SCALE = Config.GLOBAL_TIME_SCALE

local Camera = workspace.CurrentCamera

local FOV = 0.4

local NearChop = Config.NearChop
local MidRollers = Config.MidRollers
local LongSwells = Config.LongSwells

local StartTime = os.clock()

type Wave = Types.Wave

local function SetConfig(config: Types.Config)
	GRAVITY = config.GRAVITY
	PER_WAVE_JITTER = config.PER_WAVE_JITTER
	NOISE_SCALE = config.NOISE_SCALE
	NOISE_TIME_SCALE = config.NOISE_TIME_SCALE
	NOISE_CONTRAST = config.NOISE_CONTRAST
	MID_RADIUS = config.MID_RADIUS
	NEAR_RADIUS = config.NEAR_RADIUS
	FAR_FLATTEN_START = config.FAR_FLATTEN_START
	GLOBAL_TIME_SCALE = config.GLOBAL_TIME_SCALE
	NearChop = config.NearChop
	MidRollers = config.MidRollers
	LongSwells = config.LongSwells
end

local function PrepareWave(wave: Wave)
	--in this function, we precompute wave properties for optimization purposes.
	local _, wavelength, direction, _, phase =
		wave.amplitude, wave.wavelength, wave.direction, wave.steepness, wave.phase

	local directionVector = vector.create(direction.x, 0, direction.z)
	local directionUnit = vector.magnitude(directionVector) == 0 and Vector3.zero or (directionVector :: any).Unit

	local waveNumber = 2 * math.pi / wavelength

	wave.kVector = directionUnit * waveNumber
	wave.directionUnit = directionUnit
	wave.angularFrequency = math.sqrt(GRAVITY * waveNumber)
	wave.phaseOffset = phase or 0
	wave.timeJitter = 1 + (math.random() * 2 - 1) * PER_WAVE_JITTER
end

local function GetTimeNow(timeToUse: number?): number
	return ((timeToUse or os.clock()) - StartTime) * GLOBAL_TIME_SCALE
end

local function PrepareWaves(waveList): ()
	for _, wave in waveList do
		PrepareWave(wave)
	end
end

local function Prepare(time: number)
	StartTime = time
	math.randomseed(time)
	PrepareWaves(LongSwells)
	PrepareWaves(MidRollers)
	PrepareWaves(NearChop)
end

--we applying quintic smoothstep (https://en.wikipedia.org/wiki/Smoothstep) to blend the wave height based on distance.
local function SmoothStep(t: number): number
	return t * t * t * (t * (6 * t - 15) + 10)
end

--blend weight based on distance
--a blend weight is a value between 0 and 1 that determines how much of the wave's effect should be applied based on the distance from the camera.
local function DistanceBlendWeight(distance: number, innerRadius: number, outerRadius: number): number
	if distance <= innerRadius then
		return 1
	end
	if distance >= outerRadius then
		return 0
	end
	return 1 - SmoothStep((distance - innerRadius) / (outerRadius - innerRadius))
end

local function FarDistanceDamping(distance: number): number
	if distance <= FAR_FLATTEN_START then
		return 1
	end
	local t = (distance - FAR_FLATTEN_START) / FAR_FLATTEN_START
	return 1 / (1 + 4 * t * t)
end

--the underlying gerstner wave formula is very simple, a wave is defined by its wave number (kVector), angular frequency, amplitude, and phase offset
--the wave offset is calculated by evaluating the sine and cosine of the wave's phase at a given position and time.
--the waves amplitude is multiplied by a multiplier which can be used to adjust the wave height based on distance or other factors.
--the waves direction is used to calculate the horizontal displacement of the wave.
local function CalculateWaveOffset(wave: Wave, position: vector, time: number, amplitudeMultiplier: number): vector
	if
		not wave.kVector
		or not wave.directionUnit
		or not wave.angularFrequency
		or not wave.phaseOffset
		or not wave.timeJitter
	then
		error("Wave properties are not properly initialized.")
	end
	local theta = vector.dot(position, wave.kVector) - wave.angularFrequency * time + wave.phaseOffset + wave.timeJitter
	local sinTheta = math.sin(theta)
	local cosTheta = math.cos(theta)

	local effectiveAmplitude = wave.amplitude * amplitudeMultiplier
	local horizontalDisplacement = wave.directionUnit * wave.steepness * effectiveAmplitude * cosTheta

	local flow = wave.directionUnit * effectiveAmplitude * 0.25 * sinTheta
	return vector.create(
		horizontalDisplacement.x + flow.x,
		effectiveAmplitude * sinTheta,
		horizontalDisplacement.z + flow.z
	)
end

local function PointIFrust(point: vector, cameraLocation: vector, cameraDirection): boolean
	return vector.dot(vector.normalize(point - cameraLocation), cameraDirection) > FOV
end

local function CalculateTransform(
	basePosition: vector,
	timeNow: number,
	cameraLocation: vector,
	cameraDirection
): vector | false
	if not PointIFrust(basePosition, cameraLocation, cameraDirection) then
		return false
	end
	local noise = math.noise(basePosition.x * NOISE_SCALE, timeNow * NOISE_TIME_SCALE, basePosition.z * NOISE_SCALE)
	local distance = vector.magnitude(basePosition - cameraLocation)
	local amplitude = 1 + noise * NOISE_CONTRAST
	local offset = Vector3.zero

	--basically we get the bone's base positon and distance to the camera to calculate the wave type
	--long swells apply uniformyl across all the bones.
	--mid rollers fade based on camera distance
	--chop waves has a steepness boost

	--unfortunate vector3 and vector types are not compatible, so we have to cast them :(
	for _, wave in LongSwells do
		offset += (CalculateWaveOffset(wave, basePosition, timeNow, amplitude) :: any) :: Vector3
	end

	local midW = DistanceBlendWeight(distance, MID_RADIUS, MID_RADIUS * 1.8)
	if midW > 0 then
		for _, wave in MidRollers do
			offset += (CalculateWaveOffset(wave, basePosition, timeNow, amplitude * midW) :: any) :: Vector3
		end
	end

	local nearW = DistanceBlendWeight(distance, NEAR_RADIUS, MID_RADIUS)
	if nearW > 0 then
		for _, wave in NearChop do
			offset += (CalculateWaveOffset(wave, basePosition, timeNow, amplitude * nearW) :: any) :: Vector3
		end
	end
	return offset * FarDistanceDamping(distance) :: any
end

return {
	PrepareWaves = PrepareWaves,
	EvaluateWave = CalculateWaveOffset,
	BlendWeight = DistanceBlendWeight,
	FarDamp = FarDistanceDamping,
	SetConfig = SetConfig,
	Prepare = Prepare,
	CalculateTransform = CalculateTransform,
	GetTimeNow = GetTimeNow,
}
