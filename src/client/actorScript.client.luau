local ACTOR: Actor = script.Parent :: any

local UserInputService = game:GetService("UserInputService")

if not ACTOR:IsA("Actor") then
	return
end

local RunService = game:GetService("RunService")
local CurrentCamera = workspace.CurrentCamera

local Client:typeof(script.Parent) = (ACTOR::any).Parent.Parent
local BoneMapper = require(Client.bones)::any
local Solver = require(Client.solver)::any


local Plane
local Bones: { Bone } = {}
local BasePositions: { vector } = {}


ACTOR:BindToMessage("INIT", function(startTime, plane, bonesToUse,config)
    Solver.SetConfig(config)
    Solver.Prepare(startTime)


	local bones = BoneMapper.CollectBones(plane)
	local basePositions = BoneMapper.GetBasePositions(bones)
	Plane = plane
	Bones = {}
    BasePositions = {}

	for i, v in bonesToUse do
		Bones[i] = bones[v]
        BasePositions[i] = basePositions[v]
	end
end)

local LastCameraCFrame 
ACTOR:BindToMessage("solve", function(time) 
    local IsKeyDown = UserInputService:IsKeyDown(Enum.KeyCode.E)
    task.desynchronize()
    if not Plane then
        return
    end
    local timeNow = Solver.GetTimeNow(time)
    local CameraCFrame = CurrentCamera.CFrame
    if IsKeyDown then
        CameraCFrame = LastCameraCFrame
    end
    LastCameraCFrame = CameraCFrame
    local cameraPosition:vector = CameraCFrame.Position::any
    local cameraDirection:vector = CameraCFrame.LookVector::any
    local transforms:{vector|false} = table.create(#Bones)
    debug.profilebegin("Solver.CalculateTransforms")
    for i, basePosition in BasePositions do
        local transform = Solver.CalculateTransform(basePosition, timeNow, cameraPosition,cameraDirection)
        transforms[i] = transform
    end
    debug.profileend()
    task.synchronize()
    debug.profilebegin("ApplyTransforms")
    local nonRendered = 0
    for i, bone in Bones do
        local transform = transforms[i]
        if not transform then
            nonRendered += 1
            continue
        end
        bone.Transform = CFrame.new(transform::any)
    end
    --print("Non-rendered bones: ", nonRendered, "out of", #Bones)
    debug.profileend()
end)
