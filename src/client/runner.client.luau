--!native
local RunService = game:GetService("RunService")
local CurrentCamera = workspace.CurrentCamera

local Config = require(script.Parent.config)
local BoneMapper = require(script.Parent.bones)
local Solver = require(script.Parent.solver)
local Types = require(script.Parent.types)

type Wave = Types.Wave

math.randomseed(os.clock())

local PrepareWaves = Solver.PrepareWaves
local EvaluateWave = Solver.EvaluateWave
local BlendWeight = Solver.BlendWeight
local FarDamp = Solver.FarDamp

PrepareWaves(Config.LongSwells)
PrepareWaves(Config.MidRollers)
PrepareWaves(Config.NearChop)

local plane = workspace:WaitForChild("Plane")::Model
local bones = BoneMapper.CollectBones(plane)
local basePositions = BoneMapper.GetBasePositions(bones)

local startTime = os.clock()

local function calculateOffsetRawAt(basePosition: vector, timeNow: number, distance: number)
	local noise = math.noise(
		basePosition.x * Config.NOISE_SCALE,
		timeNow * Config.NOISE_TIME_SCALE,
		basePosition.z * Config.NOISE_SCALE
	)
	local amplitude = 1 + noise * Config.NOISE_CONTRAST
	local offset = Vector3.zero

	--basically we get the bone's base positon and distance to the camera to calculate the wave type
	--long swells apply uniformyl across all the bones.
	--mid rollers fade based on camera distance
	--chop waves has a steepness boost

	--unfortunate vector3 and vector types are not compatible, so we have to cast them :(
	for _, wave in Config.LongSwells do
		offset += (EvaluateWave(wave, basePosition, timeNow, amplitude) :: any) :: Vector3
	end

	local midW = BlendWeight(distance, Config.MID_RADIUS, Config.MID_RADIUS * 1.8)
	if midW > 0 then
		for _, wave in Config.MidRollers do
			offset += (EvaluateWave(wave, basePosition, timeNow, amplitude * midW) :: any) :: Vector3
		end
	end

	local nearW = BlendWeight(distance, Config.NEAR_RADIUS, Config.MID_RADIUS)
	if nearW > 0 then
		for _, wave in Config.NearChop do
			offset += (EvaluateWave(wave, basePosition, timeNow, amplitude * nearW) :: any) :: Vector3
		end
	end
	return offset
end

RunService.Heartbeat:Connect(function()
	local cameraPosition:vector = CurrentCamera.CFrame.Position::any
	local timeNow = (os.clock() - startTime) * Config.GLOBAL_TIME_SCALE

	for i, bone in bones do
		local basePosition = basePositions[i]
		local distance = vector.magnitude(cameraPosition - basePosition)

		local noise = math.noise(
			basePosition.x * Config.NOISE_SCALE,
			timeNow * Config.NOISE_TIME_SCALE,
			basePosition.z * Config.NOISE_SCALE
		)
		local amplitude = 1 + noise * Config.NOISE_CONTRAST
		local offset = Vector3.zero

		--basically we get the bone's base positon and distance to the camera to calculate the wave type
		--long swells apply uniformyl across all the bones.
		--mid rollers fade based on camera distance
		--chop waves has a steepness boost

		--unfortunate vector3 and vector types are not compatible, so we have to cast them :(
		for _, wave in Config.LongSwells do
			offset += (EvaluateWave(wave, basePosition, timeNow, amplitude) :: any) :: Vector3
		end

		local midW = BlendWeight(distance, Config.MID_RADIUS, Config.MID_RADIUS * 1.8)
		if midW > 0 then
			for _, wave in Config.MidRollers do
				offset += (EvaluateWave(wave, basePosition, timeNow, amplitude * midW) :: any) :: Vector3
			end
		end

		local nearW = BlendWeight(distance, Config.NEAR_RADIUS, Config.MID_RADIUS)
		if nearW > 0 then
			for _, wave in Config.NearChop do
				offset += (EvaluateWave(wave, basePosition, timeNow, amplitude * nearW) :: any) :: Vector3
			end
		end

		bone.Transform = CFrame.new(offset * FarDamp(distance))
	end
end)
