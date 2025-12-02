--!strict

-- Mouse Lock


---------- Services ----------

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")


---------- Constants ----------

local Constants = {}

Constants.localPlayer = Players.LocalPlayer
Constants.mouseLockToggleKeys = {
	Enum.KeyCode.N
}

Constants.newScreenGui = Instance.new("ScreenGui")
Constants.newScreenGui.IgnoreGuiInset = true
Constants.newScreenGui.ResetOnSpawn = false

Constants.textButton = Instance.new("TextButton")
Constants.textButton.BackgroundTransparency = 1
Constants.textButton.Interactable = false
Constants.textButton.Modal = true
Constants.textButton.Size = UDim2.fromScale(1, 1)
Constants.textButton.ZIndex = -999
Constants.textButton.Text = ""

Constants.textButton.Parent = Constants.newScreenGui
Constants.newScreenGui.Parent = Constants.localPlayer.PlayerGui


table.freeze(Constants)


---------- Global variables ----------

local Globals = {}

Globals.mouseLocked = false
Globals.previousIsFirstPerson = false


---------- Local functions ----------

local isFirstPerson
local toggleMouseLock
local updateMouseLock


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


----- Mouse lock -----

toggleMouseLock = function(actionName: string, inputState: Enum.UserInputState, inputObject)
	if actionName == "Toggle Mouse Lock" then
		if inputState == Enum.UserInputState.Begin then
			Globals.mouseLocked = not Globals.mouseLocked
		end
	end
end

updateMouseLock = function()
	if isFirstPerson() then
		if not Globals.previousIsFirstPerson then
			Globals.mouseLocked = true
		end
		Globals.previousIsFirstPerson = true
		Constants.newScreenGui.Enabled = not Globals.mouseLocked
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	else
		Globals.previousIsFirstPerson = false
		Constants.newScreenGui.Enabled = false
		if Globals.mouseLocked then
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		else
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
	end
end


----- Main -----

local function main()
	ContextActionService:BindAction("Toggle Mouse Lock", toggleMouseLock, false, table.unpack(Constants.mouseLockToggleKeys))
	RunService:BindToRenderStep("Mouse Lock Update", Enum.RenderPriority.Camera.Value - 5, updateMouseLock)
end


---------- Calling function ----------

main()


---------- Return module ----------

return {}
