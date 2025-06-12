local Actors: { Actor } = {}

local ACTOR_COUNT = 8

local Config = require(script.Parent.config)
local BoneMapper = require(script.Parent.bones)

local Types = require(script.Parent.types)

local running = false
local last = 0

local function Start()
	running = true
end

local function Stop()
	running = false
end

local function SetPlane(plane: Model, config: Types.Config?)
	config = config or Config
	if #Actors == 0 then
		for i = 1, ACTOR_COUNT do
			local actor = Instance.new("Actor")
			actor.Name = "WaveActor_" .. i
			actor.Parent = script
			script.Parent.actor:Clone().Parent = actor :: any
			Actors[i] = actor
		end
	end

	local bones = BoneMapper.CollectBones(plane)

	local bonesPerActor = math.ceil(#bones / ACTOR_COUNT)
	local boneIndex = 1
	local splitBones = {}

	for i = 1, ACTOR_COUNT do
		local boneActor = {}
		splitBones[i] = boneActor
		for j = 1, bonesPerActor, 1 do
			local boneAt = bones[boneIndex]
			if not boneAt then
				break
			end
			boneActor[j] = boneIndex
			boneIndex += 1
		end
	end

	task.delay(0.1, function()
		local clockTime = os.clock()
		for i, actor in Actors do
			actor:SendMessage("INIT", clockTime, plane, splitBones[i], config)
		end
	end)
end

game:GetService("RunService").Heartbeat:Connect(function()
	if not running then
		return
	end
	local now = os.clock()
	if now - last < 1 / 60 then
		return
	end
	last = now
	for _, actor in Actors do
		task.defer(function()
			actor:SendMessage("solve", now)
		end)
	end
end)

return {
	SetPlane = SetPlane,
	Start = Start,
	Stop = Stop,
}
