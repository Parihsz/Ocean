local Handler = {}

local Actors: { Actor } = {}

local ACTOR_COUNT = 8

local Config = require(script.Parent.config)
local BoneMapper = require(script.Parent.bones)

local Types = require(script.Parent.types)

local Running = false

function Handler.SetPlane(plane: Model, config: Types.Config?)
	config = config or Config
	if #Actors == 0 then
		for i = 1, ACTOR_COUNT do
			local actor = Instance.new("Actor")
			actor.Name = "WaveActor_" .. i
			actor.Parent = script
			script.Parent.actorScript:Clone().Parent = actor :: any
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

function Handler.Start()
	Running = true
end

function Handler.Stop()
	Running = false
end
local last = 0
game:GetService("RunService").Heartbeat:Connect(function()
	if not Running then
		return
	end
	local now = os.clock()
	if now - last < 1 / 60 then
		return
	end
	last = now
	local timeNow = os.clock()
	for i, actor in Actors do
		actor:SendMessage("solve", timeNow)
	end
end)

return Handler
