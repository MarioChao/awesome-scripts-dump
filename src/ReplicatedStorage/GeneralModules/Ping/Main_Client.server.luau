--!strict

-- Main Client


---------- Constants ----------

local Constants = {}

Constants.mainRemoteEvent = script.Parent:WaitForChild("MainRemoteEvent")

table.freeze(Constants)


---------- Local functions ----------

----- Main -----

local function main()
    Constants.mainRemoteEvent.OnClientEvent:Connect(function(mode: string, ...)
        if mode == "Ping" then
            Constants.mainRemoteEvent:FireServer("Pong")
        end
    end)
end


---------- Calling functions ----------

main()
