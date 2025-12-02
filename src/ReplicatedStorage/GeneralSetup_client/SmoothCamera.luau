--!strict

-- Smooth Camera


---------- Services ----------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")


---------- Constants ----------

local Constants = {}
Constants.localPlayer = Players.LocalPlayer
Constants.camera = workspace.CurrentCamera :: Camera

table.freeze(Constants)


---------- Global variables ----------

local Globals = {}

Globals.lastSubjectPosition = nil :: Vector3?
Globals.lastAlpha = 0 :: number?


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

setCameraCFrame = function()
	local cameraSubjectInfo = getCameraSubjectInfo(Constants.camera)
	local humanoid = cameraSubjectInfo.humanoid
	local subjectCFrame = cameraSubjectInfo.subjectCFrame
	if humanoid and subjectCFrame then
		-- Lerp alpha
		local targetAlpha = math.clamp(math.map(humanoid.WalkSpeed, 16, 32, 1.0, 0.3), 0.3, 1.0)
		local lastAlpha = Globals.lastAlpha or targetAlpha
		local lerpedAlpha = math.lerp(lastAlpha, targetAlpha, 0.1)
		Globals.lastAlpha = lerpedAlpha

		-- Lerp subject position
		local lastSubjectPosition = Globals.lastSubjectPosition or subjectCFrame.Position
		local lerpedSubjectPosition
		if lerpedAlpha < 0.99 then
			lerpedSubjectPosition = lastSubjectPosition:Lerp(subjectCFrame.Position, lerpedAlpha)
		else
			lerpedSubjectPosition = subjectCFrame.Position
		end
		Globals.lastSubjectPosition = lerpedSubjectPosition

		-- Set camera CFrame
		if not isFirstPerson() then
			local originalCameraCFrame = Constants.camera.CFrame
			local lerpedSubjectCFrame = subjectCFrame.Rotation + lerpedSubjectPosition
			local cameraOffsetCFrame = subjectCFrame:ToObjectSpace(originalCameraCFrame)
			Constants.camera.CFrame = lerpedSubjectCFrame:ToWorldSpace(cameraOffsetCFrame)
		end
	end
end


----- Main -----

local function main()
	RunService:BindToRenderStep("Set Camera CFrame Before", Enum.RenderPriority.Camera.Value + 5, setCameraCFrame)
	Constants.camera.CameraType = Enum.CameraType.Scriptable
end


---------- Calling function ----------

main()


---------- Return module ----------

return {}
