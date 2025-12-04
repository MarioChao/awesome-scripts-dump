--!strict

-- Smooth Camera


---------- Services ----------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")


---------- Constants ----------

local Constants = {}
Constants.localPlayer = Players.LocalPlayer
Constants.camera = workspace.CurrentCamera :: Camera

Constants.smoothTime = 0.3
Constants.maxCameraOffsetXZMagnitude = 2
Constants.maxCameraOffsetYMagnitude = 2

Constants.testPart = Instance.new("Part")
Constants.testPart.Shape = Enum.PartType.Ball
Constants.testPart.Transparency = 1
Constants.testPart.CanCollide = false
Constants.testPart.Anchored = true
Constants.testPart.Parent = workspace

table.freeze(Constants)


---------- Global variables ----------

local Globals = {}

Globals.lastSubjectPosition = nil :: Vector3?
Globals.smoothDampVelocity = Vector3.zero
Globals.lastMaxCameraOffsetXZMagnitude = nil :: number?
Globals.lastMaxCameraOffsetYMagnitude = nil :: number?


---------- Local functions ----------

local isFirstPerson
local getCameraSubjectInfo
local setCameraCFrame


----- First person check -----

function isFirstPerson()
	local character = Constants.localPlayer.Character
	local head
	local result = false
	if character then
		head = character:FindFirstChild("Head")
		if head and head:IsA("BasePart") then
			result = head.LocalTransparencyModifier > 0.9
		end
	end
	return result
end


----- Camera -----

getCameraSubjectInfo = function(camera: Camera)
	local cameraSubject = camera.CameraSubject
	local character
	local humanoidRootPart
	local humanoid: Humanoid?
	local subjectCFrame: CFrame?
	local result

	if cameraSubject then
		if cameraSubject:IsA("Humanoid") then
			humanoid = cameraSubject
			character = cameraSubject.Parent
			if character then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
					subjectCFrame = humanoidRootPart.CFrame + cameraSubject.CameraOffset
				end
			end
		elseif cameraSubject:IsA("BasePart") then
			subjectCFrame = cameraSubject.CFrame
			if cameraSubject.Parent then
				humanoid = cameraSubject.Parent:FindFirstChildWhichIsA("Humanoid")
			end
		end
	end
	result = {
		humanoid = humanoid,
		subjectCFrame = subjectCFrame,
	}

	return result
end

setCameraCFrame = function(delta: number)
	local cameraSubjectInfo = getCameraSubjectInfo(Constants.camera)
	local humanoid = cameraSubjectInfo.humanoid
	local subjectCFrame = cameraSubjectInfo.subjectCFrame
	if humanoid and subjectCFrame then
		-- Smooth damp subject position
		local subjectPosition = subjectCFrame.Position
		local lastSubjectPosition = Globals.lastSubjectPosition or subjectCFrame.Position
		local smoothDampedSubjectPosition: Vector3
		smoothDampedSubjectPosition, Globals.smoothDampVelocity = TweenService:SmoothDamp(
			lastSubjectPosition, subjectPosition, Globals.smoothDampVelocity, Constants.smoothTime,
			nil, delta
		)

		-- Get clamped magnitude for camera offset
		local alpha = math.map(humanoid.WalkSpeed, 16, 32, 0, 1)
		alpha = math.clamp(alpha, 0, 1)
		local targetCameraOffsetXZMagnitude = math.lerp(0, Constants.maxCameraOffsetXZMagnitude, alpha)
		local targetCameraOffsetYMagnitude = math.lerp(0, Constants.maxCameraOffsetYMagnitude, alpha)
		targetCameraOffsetXZMagnitude = math.clamp(targetCameraOffsetXZMagnitude, 0, Constants.maxCameraOffsetXZMagnitude)
		targetCameraOffsetYMagnitude = math.clamp(targetCameraOffsetYMagnitude, 0, Constants.maxCameraOffsetYMagnitude)
		local lastMaxCameraOffsetXZMagnitude = Globals.lastMaxCameraOffsetXZMagnitude or targetCameraOffsetXZMagnitude
		local lastMaxCameraOffsetYMagnitude = Globals.lastMaxCameraOffsetYMagnitude or targetCameraOffsetYMagnitude
		local maxCameraOffsetXZMagnitude = math.lerp(lastMaxCameraOffsetXZMagnitude, targetCameraOffsetXZMagnitude, 0.1)
		local maxCameraOffsetYMagnitude = math.lerp(lastMaxCameraOffsetYMagnitude, targetCameraOffsetYMagnitude, 0.1)
		Globals.lastMaxCameraOffsetXZMagnitude = maxCameraOffsetXZMagnitude
		Globals.lastMaxCameraOffsetYMagnitude = maxCameraOffsetYMagnitude

		-- Clamp subject position
		local smoothDampedOffset = smoothDampedSubjectPosition - subjectPosition
		local clampedSubjectOffsetXZ = Vector3.new(smoothDampedOffset.X, 0, smoothDampedOffset.Z)
		local clampedSubjectOffsetY = Vector3.new(0, smoothDampedOffset.Y, 0)
		local clampScaleFactorXZ = if clampedSubjectOffsetXZ.Magnitude == 0 then 0 else (math.min(clampedSubjectOffsetXZ.Magnitude, maxCameraOffsetXZMagnitude) / clampedSubjectOffsetXZ.Magnitude)
		local clampScaleFactorY = if clampedSubjectOffsetY.Magnitude == 0 then 0 else (math.min(clampedSubjectOffsetY.Magnitude, maxCameraOffsetYMagnitude) / clampedSubjectOffsetY.Magnitude)
		clampedSubjectOffsetXZ *= clampScaleFactorXZ
		clampedSubjectOffsetY *= clampScaleFactorY
		local clampedSubjectOffset = Vector3.new(clampedSubjectOffsetXZ.X, clampedSubjectOffsetY.Y, clampedSubjectOffsetXZ.Z)
		local clampedSubjectPosition = subjectPosition + clampedSubjectOffset

		-- Final adjusted subject position
		local adjustedSubjectPosition = clampedSubjectPosition

		Globals.lastSubjectPosition = adjustedSubjectPosition
		Constants.testPart.Position = adjustedSubjectPosition

		-- Set camera CFrame
		if not isFirstPerson() then
			local originalCameraCFrame = Constants.camera.CFrame
			local adjustedSubjectCFrame = subjectCFrame.Rotation + adjustedSubjectPosition
			local cameraOffsetCFrame = subjectCFrame:ToObjectSpace(originalCameraCFrame)
			Constants.camera.CFrame = adjustedSubjectCFrame:ToWorldSpace(cameraOffsetCFrame)
		end
	end
end


----- Main -----

local function main()
	RunService:BindToRenderStep("Set Smooth Camera CFrame", Enum.RenderPriority.Camera.Value + 5, setCameraCFrame)
	Constants.camera.CameraType = Enum.CameraType.Scriptable
end


---------- Calling function ----------

main()


---------- Return module ----------

return {}
