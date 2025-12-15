--!strict

-- Animate UI Gradient


---------- Services ----------

local CollectionService = game:GetService("CollectionService")


---------- Constants ----------

local Constants = {}
Constants.tagName = "AnimatedGradient"

table.freeze(Constants)


---------- Globals ----------

local Globals = {}
Globals.instance_gradientThread = {} :: {[Instance]: thread}


---------- Local functions ----------

local getColorSequenceColor
local getShiftedColorSequence
local gradient
local onInstanceTagAdded
local onInstanceTagRemoved


----- UI Gradient -----

getColorSequenceColor = function(colorSequenceKeypoints, alpha: number): Color3
	local keypoints = colorSequenceKeypoints
	local keypoint1
	local keypoint2
	local segmentAlpha
	local result

	-- Binary search for keypoint
	local bsearch = {
		left = 1,
		right = #keypoints - 1,
		mid = -1,
		result = 0,
	}
	while bsearch.left <= bsearch.right do
		bsearch.mid = bsearch.left + (bsearch.right - bsearch.left) // 2
		local tempKeypoint1 = keypoints[bsearch.mid]
		local tempKeypoint2 = keypoints[bsearch.mid + 1]
		if tempKeypoint1.Time <= alpha and alpha <= tempKeypoint2.Time then
			bsearch.result = bsearch.mid
			bsearch.right = bsearch.left - 1
		elseif tempKeypoint2.Time < alpha then
			bsearch.left = bsearch.mid + 1
		elseif alpha < tempKeypoint1.Time then
			bsearch.right = bsearch.mid - 1
		end
	end
	keypoint1 = keypoints[bsearch.result]
	keypoint2 = keypoints[bsearch.result + 1]
	segmentAlpha = (alpha - keypoint1.Time) / (keypoint2.Time - keypoint1.Time)
	result = keypoint1.Value:Lerp(keypoint2.Value, segmentAlpha)
	return result
end

getShiftedColorSequence = function(colorSequence: ColorSequence, shiftTime: number)
	shiftTime = shiftTime % 2

	local initialKeypoints = colorSequence.Keypoints
	for _, keypoint in colorSequence.Keypoints do
		table.insert(initialKeypoints, ColorSequenceKeypoint.new(2 - keypoint.Time, keypoint.Value))
	end
	table.sort(initialKeypoints, function(a, b) return a.Time < b.Time end)

	local keypoints = {}
	local newKeypoint
	local newColorSequence
	
	-- Endpoint keypoints
	table.insert(keypoints, ColorSequenceKeypoint.new(0, getColorSequenceColor(initialKeypoints, shiftTime)))
	table.insert(keypoints, ColorSequenceKeypoint.new(1, getColorSequenceColor(initialKeypoints, (shiftTime + 1) % 2)))
	
	-- Intermediate keypoints
	for _, keypoint in initialKeypoints do
		local keypointTime = (keypoint.Time + shiftTime) % 2
		if keypointTime < 1 then
			newKeypoint = ColorSequenceKeypoint.new(keypointTime, keypoint.Value)
			table.insert(keypoints, newKeypoint)
		end
	end
	table.sort(keypoints, function(a, b) return a.Time < b.Time end)

	newColorSequence = ColorSequence.new(keypoints)
	return newColorSequence
end

gradient = function(uiGradient: UIGradient)
	local initialColorSequence = uiGradient.Color
	local startTime = time()
	local speed = tonumber(uiGradient:GetAttribute("Speed")) or 1.0
	local currentTime
	local shiftTime
	local currentColorSequence
	return task.defer(function()
		while true do
			currentTime = time() - startTime
			shiftTime = currentTime * speed
			currentColorSequence = getShiftedColorSequence(initialColorSequence, shiftTime)
			uiGradient.Color = currentColorSequence
			task.wait()
		end
	end)
end


----- Tag -----

onInstanceTagAdded = function(object: Instance)
	if Globals.instance_gradientThread[object] then
		task.cancel(Globals.instance_gradientThread[object])
	end
	if object:IsA("UIGradient") then
		Globals.instance_gradientThread[object] = gradient(object)
	end
end

onInstanceTagRemoved = function(object: Instance)
	if Globals.instance_gradientThread[object] then
		task.cancel(Globals.instance_gradientThread[object])
	end
	Globals.instance_gradientThread[object] = nil
end


----- Main -----

local function main()
	local initialTagged = CollectionService:GetTagged(Constants.tagName)
	task.defer(function()
		for _, object in initialTagged do
			task.defer(onInstanceTagAdded, object)
		end
	end)
	CollectionService:GetInstanceAddedSignal(Constants.tagName):Connect(onInstanceTagAdded)
	CollectionService:GetInstanceRemovedSignal(Constants.tagName):Connect(onInstanceTagRemoved)
end


---------- Calling function ----------

main()


---------- Return module ----------

return {}
