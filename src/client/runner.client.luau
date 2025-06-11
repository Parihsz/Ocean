local Types = require(script.Parent.types)

type Wave = Types.Wave

local plane = workspace:WaitForChild("Plane") :: Model

local Handler = require(script.Parent.handler)
Handler.SetPlane(plane)
Handler.Start()
