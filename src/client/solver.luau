--!native
local Config = require(script.Parent.config)
local Types = require(script.Parent.types)

type Wave = Types.Wave

local function PrepareWave(wave: Wave)
	--in this function, we precompute wave properties for optimization purposes.
	local _, wavelength, direction, _, phase =
		wave.amplitude, wave.wavelength, wave.direction, wave.steepness, wave.phase

	local directionVector = vector.create(direction.x, 0, direction.z)
	local directionUnit = vector.magnitude(directionVector) == 0 and Vector3.zero or (directionVector :: any).Unit

	local waveNumber = 2 * math.pi / wavelength

	wave.kVector = directionUnit * waveNumber
	wave.directionUnit = directionUnit
	wave.angularFrequency = math.sqrt(Config.GRAVITY * waveNumber)
	wave.phaseOffset = phase or 0
	wave.timeJitter = 1 + (math.random() * 2 - 1) * Config.PER_WAVE_JITTER
end

local function PrepareWaves(waveList): ()
	for _, wave in waveList do
		PrepareWave(wave)
	end
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
	if distance <= Config.FAR_FLATTEN_START then
		return 1
	end
	local t = (distance - Config.FAR_FLATTEN_START) / Config.FAR_FLATTEN_START
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

	return vector.create(horizontalDisplacement.x, effectiveAmplitude * sinTheta, horizontalDisplacement.z)
end

return {
	PrepareWaves = PrepareWaves,
	EvaluateWave = CalculateWaveOffset,
	BlendWeight = DistanceBlendWeight,
	FarDamp = FarDistanceDamping,
}
