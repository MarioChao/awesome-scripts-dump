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

for attribute, value in script:GetAttributes() do
    if module_nameExists[attribute] then
        if value then
            require(script:WaitForChild(attribute))
        end
    else
        warn(`[GenerateSetup_client]: module "{attribute}" not found!`)
    end
end
