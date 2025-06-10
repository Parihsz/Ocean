local function CollectBones(plane: Model)
	local bones = {}

	for _, obj in plane:GetChildren() do
		if obj:IsA("Bone") then
			table.insert(bones, obj)
		end
	end

	--we need to sort because we apply the waves in order of bone to get a consistent effect
	table.sort(bones, function(a, b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)
	return bones
end

local function GetBasePositions(bones: { Bone })
	local basePositions = {}

	for _, bone in bones do
		local position = bone.CFrame.Position
		table.insert(basePositions, vector.create(position.X, position.Y, position.Z))
	end

	return basePositions
end

return {
	CollectBones = CollectBones,
	GetBasePositions = GetBasePositions,
}
