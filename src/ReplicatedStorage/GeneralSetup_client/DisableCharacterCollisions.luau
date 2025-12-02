local Players = game:GetService("Players")

local onOtherPlayerCharacterAdded
local onOtherPlayerAdded

local onLocalPlayerCharacterAdded
local onLocalPlayerAdded

onOtherPlayerCharacterAdded = function(character: Model)
    for _, part in character:GetDescendants() do
        if part:IsA("BasePart") then
            part.CollisionGroup = "OtherPlayer"
        end
    end
end

onOtherPlayerAdded = function(player: Player)
    local initialCharacter = player.Character
    if initialCharacter then
        task.defer(function()
            if initialCharacter then
                onOtherPlayerCharacterAdded(initialCharacter)
            end
        end)
    end
    player.CharacterAdded:Connect(onOtherPlayerCharacterAdded)
end

onLocalPlayerCharacterAdded = function(character: Model)
    for _, part in character:GetDescendants() do
        if part:IsA("BasePart") then
            part.CollisionGroup = "LocalPlayer"
        end
    end
end

onLocalPlayerAdded = function(player: Player)
    local initialCharacter = player.Character
    if initialCharacter then
        task.defer(function()
            if initialCharacter then
                onLocalPlayerCharacterAdded(initialCharacter)
            end
        end)
    end
    player.CharacterAdded:Connect(onLocalPlayerCharacterAdded)
end

local initialPlayers = Players:GetPlayers()
task.defer(function()
    for _, player in initialPlayers do
        if player ~= Players.LocalPlayer then
            onOtherPlayerAdded(player)
        end
    end
end)
Players.PlayerAdded:Connect(onOtherPlayerAdded)
onLocalPlayerAdded(Players.LocalPlayer)


---------- Return module ----------

return {}
