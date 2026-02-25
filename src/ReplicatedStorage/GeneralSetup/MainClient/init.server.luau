local moduleNames = {
    "AnimateUIGradient",
    "DisableCharacterCollisions",
    "DisableEmotes",
    "FirstPersonTransparency",
    "MouseLock",
    "PlayerVFXEnabler",
    "SmoothCamera",
}

local module_nameExists = {}
for _, name in moduleNames do
    module_nameExists[name] = true
end

local _scriptAttributes = script.Parent:WaitForChild("ScriptAttributes")
local attributeConfig = (function()
    local result
    local customConfig = _scriptAttributes:FindFirstChild("MainClient")
    if customConfig then
        result = customConfig
    else
        result = Instance.new("Configuration")
        for _, name in moduleNames do
            result:SetAttribute(name, true)
        end
    end
    return result
end)()

for attribute, value in attributeConfig:GetAttributes() do
    if module_nameExists[attribute] then
        if value then
            require(script:WaitForChild(attribute))
        end
    else
        warn(`[GenerateSetup_client]: module "{attribute}" not found!`)
    end
end
