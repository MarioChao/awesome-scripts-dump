--!strict

-- Main Server


---------- Constants ----------

local Constants = {}

Constants.mainRemoteEvent = script.Parent.MainRemoteEvent

table.freeze(Constants)


---------- Local functions ----------

----- Main -----

local function main()
    Constants.mainRemoteEvent.OnServerEvent:Connect(function(player: Player, mode: string, ...)
        if mode == "Ping" then
            Constants.mainRemoteEvent:FireClient(player, "Pong")
        end
    end)
end


---------- Calling function ----------

main()
