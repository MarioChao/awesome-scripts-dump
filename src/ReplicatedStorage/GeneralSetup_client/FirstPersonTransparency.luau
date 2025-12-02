--!strict

-- First Person Transparency


---------- Services ----------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")


---------- Constants ----------

local Constants = {}

Constants.localPlayer = Players.LocalPlayer
Constants.showPartList = {
	["Left Arm"] = true,
	["Right Arm"] = true,
	-- ["Left Leg"] = true,
	-- ["Right Leg"] = true,
}


table.freeze(Constants)


---------- Local functions ----------

local firstPersonTransparencyLoop


----- Transparency -----

firstPersonTransparencyLoop = function()
	local character = Constants.localPlayer.Character
	if not character then return end

	for _, part in character:GetChildren() do
		if part:IsA("BasePart") and Constants.showPartList[part.Name] then
			part.LocalTransparencyModifier = 0
			part.CastShadow = false
		end
	end 
end


----- Main -----

local function main()
	RunService:BindToRenderStep("First Person Transparency", Enum.RenderPriority.Character.Value + 5, firstPersonTransparencyLoop)
	-- Constants.localPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
end


---------- Calling function ----------

main()


---------- Return module ----------

return {}
