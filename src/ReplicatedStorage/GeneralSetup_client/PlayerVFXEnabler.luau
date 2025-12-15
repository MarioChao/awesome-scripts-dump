--!strict

-- Player VFX Enabler


---------- Services ----------

local Players = game:GetService("Players")


---------- Imports ----------

local _GeneralModules = script.Parent.Parent:WaitForChild("GeneralModules")
local PlayerVFX = require(_GeneralModules:WaitForChild("PlayerVFX"))


---------- Constants ----------

local Constants = {}
Constants.localPlayer = Players.LocalPlayer

table.freeze(Constants)


---------- Local functions ----------

local onCharacterAdded


----- Character added -----

onCharacterAdded = function(character: Model)
    PlayerVFX.setTorsoTrailVisible(character, true)
    PlayerVFX.setLandingIndicatorVisible(character, true, "LocalPlayer")
end


----- Main -----

local function main()
    local initialCharacter = Constants.localPlayer.Character
    task.defer(function()
        if initialCharacter then
            onCharacterAdded(initialCharacter)
        end
    end)
    Constants.localPlayer.CharacterAdded:Connect(onCharacterAdded)
end


---------- Calling function ----------

main()


---------- Return module ----------

return {}
