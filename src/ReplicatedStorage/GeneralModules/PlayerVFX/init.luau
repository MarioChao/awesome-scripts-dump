--!strict

-- Player VFX


---------- Constants ----------

local Constants = {}
Constants.prefix = "_PlayerVFX_"

Constants.default = {
    torsoTrail = script:WaitForChild("PlayerVFX_TorsoTrail"),
    landing_indicatorPart = script:WaitForChild("PlayerVFX_LandingIndicator"),
}
Constants.default.landing_indicatorPart.Parent = nil
table.freeze(Constants.default)

Constants.instance_name = {
    torsoTrail_trail = Constants.prefix .. "Trail",
    torsoTrail_attachment0 = Constants.prefix .. "Trail_Attachment0",
    torsoTrail_attachment1 = Constants.prefix .. "Trail_Attachment1",
    landing_indicatorPart = Constants.prefix .. "Landing_IndicatorPart"
}
table.freeze(Constants.instance_name)

table.freeze(Constants)


---------- Globals ----------

local Globals = {}
Globals.character_landingIndicatorPart = {} :: {[Model]: typeof(Constants.default.landing_indicatorPart)}
Globals.character_landingIndicatorThread = {} :: {[Model]: thread}
Globals.character_landingIndicatorCleanupConnection = {} :: {[Model]: RBXScriptConnection}


---------- Local functions ----------

local getCharacterPart
local getTorso
local getOrCreateAttachment
local setTorsoTrailVisible
local setLandingIndicatorVisible


----- Character parts -----

getCharacterPart = function(character: Model, humanoid: Humanoid?, partNameR6: string, partNameR15: string)
    local finalHumanoid = humanoid or character:FindFirstChildWhichIsA("Humanoid")
    local result
    if finalHumanoid then
        if finalHumanoid.RigType == Enum.HumanoidRigType.R6 then
            result = character:FindFirstChild(partNameR6)
        elseif finalHumanoid.RigType == Enum.HumanoidRigType.R15 then
            result = character:FindFirstChild(partNameR15)
        end
    end
    return result
end

getTorso = function(character: Model, humanoid: Humanoid?)
    return getCharacterPart(character, humanoid, "Torso", "UpperTorso")
end


----- Get or create -----

getOrCreateAttachment = function(parent: Instance, attachmentName: string)
    local child = parent:FindFirstChild(attachmentName)
    local result
    if child and child:IsA("Attachment") then
        result = child
    else
        result = Instance.new("Attachment")
        result.Name = attachmentName
        result.Parent = parent
    end
    return result
end


----- Trail -----

setTorsoTrailVisible = function(character: Model, isVisible: boolean)
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    local torso
    local trail
    local attachment0
    local attachment1
    if humanoid then
        torso = getTorso(character, humanoid)
        if torso then
            trail = (function()
                local trailName = Constants.instance_name.torsoTrail_trail
                local child = torso:FindFirstChild(trailName)
                local result
                if child and child:IsA("Trail") then
                    result = child
                else
                    result = Constants.default.torsoTrail:Clone()
                    result.Name = trailName
                    result.Parent = torso
                end
                return result
            end)()
            attachment0 = getOrCreateAttachment(torso, Constants.instance_name.torsoTrail_attachment0)
            attachment1 = getOrCreateAttachment(torso, Constants.instance_name.torsoTrail_attachment1)
            attachment0.Position = Vector3.new(-0.5, 0, 0)
            attachment1.Position = Vector3.new(0.5, 0, 0)
            trail.Attachment0 = attachment0
            trail.Attachment1 = attachment1
            trail.Enabled = isVisible
        end
    end
end


----- Landing indicator -----

setLandingIndicatorVisible = function(character: Model, isVisible: boolean, collisionGroup: string)
    local function cleanUp(destroying: boolean)
        if Globals.character_landingIndicatorCleanupConnection[character] then
            Globals.character_landingIndicatorCleanupConnection[character]:Disconnect()
            Globals.character_landingIndicatorCleanupConnection[character] = nil
        end
        if destroying then
            if Globals.character_landingIndicatorThread[character] then
                task.cancel(Globals.character_landingIndicatorThread[character])
                Globals.character_landingIndicatorThread[character] = nil
            end
            if Globals.character_landingIndicatorPart[character] then
                Globals.character_landingIndicatorPart[character]:Destroy()
                Globals.character_landingIndicatorPart[character] = nil
            end
        end
    end
    cleanUp(false)

    Globals.character_landingIndicatorCleanupConnection[character] = character.Destroying:Once(function()
        cleanUp(true)
    end)

    local indicatorPart = Globals.character_landingIndicatorPart[character] or (function()
        local previousResult
        local result

        -- Clean up existing indicators
        previousResult = workspace:FindFirstChild(Constants.instance_name.landing_indicatorPart)
        while previousResult do
            previousResult:Destroy()
            previousResult = workspace:FindFirstChild(Constants.instance_name.landing_indicatorPart)
        end

        -- Create new indicator
        result = Constants.default.landing_indicatorPart:Clone()
        result.Name = Constants.instance_name.landing_indicatorPart
        result.Parent = workspace
        return result
    end)()
    if not isVisible then
        indicatorPart.Parent = nil
    else
        indicatorPart.Parent = workspace
    end
    local indicatorSurfaceGui = indicatorPart:WaitForChild("SurfaceGui")
    Globals.character_landingIndicatorPart[character] = indicatorPart

    if not Globals.character_landingIndicatorThread[character] then
        Globals.character_landingIndicatorThread[character] = task.defer(function()
            local humanoid
            local humanoidRootPart
            local raycastOrigin
            local raycastRadius = math.min(indicatorPart.Size.X, indicatorPart.Size.Z) / 2
            local raycastDirection = Vector3.new(0, -1000, 0)
            local raycastParams = RaycastParams.new()
            local raycastResult
            local indicatorPartOffset_Y = -indicatorPart.Size.Y * 0.5
            local indicatorPosition
            if collisionGroup then
                raycastParams.CollisionGroup = collisionGroup
            end
            raycastParams.FilterDescendantsInstances = {character}
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            while true do
                humanoid = character:FindFirstChildWhichIsA("Humanoid")
                humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoid and humanoid.Health <= 0 then
                    indicatorSurfaceGui.Enabled = false
                elseif humanoidRootPart and humanoidRootPart:IsA("BasePart") then
                    raycastOrigin = humanoidRootPart.Position
                    raycastResult = workspace:Spherecast(raycastOrigin, raycastRadius, raycastDirection, raycastParams)
                    if raycastResult and raycastResult.Distance > 1 then
                        indicatorPosition = Vector3.new(raycastOrigin.X, raycastResult.Position.Y + indicatorPartOffset_Y, raycastOrigin.Z)
                        indicatorPart.Position = indicatorPosition
                        indicatorSurfaceGui.Enabled = true
                    else
                        indicatorSurfaceGui.Enabled = false
                    end
                end
                task.wait()
            end
        end)
    end
end


---------- Module ----------

local Module = {}


----- Module fields -----

Module.setTorsoTrailVisible = setTorsoTrailVisible
Module.setLandingIndicatorVisible = setLandingIndicatorVisible


---------- Return module ----------

table.freeze(Module)
return Module
