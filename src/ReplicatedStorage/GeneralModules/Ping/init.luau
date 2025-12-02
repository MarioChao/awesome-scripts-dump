--!strict

-- Ping


---------- Services ----------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")


---------- Constants ----------

local Constants = {}
Constants.mainRemoteEvent = script:WaitForChild("MainRemoteEvent")

table.freeze(Constants)


---------- Globals ----------

local Globals = {}
Globals.server_ponged = false
Globals.player_ponged = {}


---------- Local functions ----------

local waitUntilPong_local
local waitUntilPong_server


----- Yield -----

waitUntilPong_local = function()
    while not Globals.server_ponged do
        task.wait()
    end
end

waitUntilPong_server = function(player: Player)
    while not Globals.player_ponged[player] do
        task.wait()
    end
end


----- Main -----

local function main()
    if RunService:IsClient() then
        Constants.mainRemoteEvent.OnClientEvent:Connect(function(mode: string, ...)
            if mode == "Pong" then
                Globals.server_ponged = true
            end
        end)
    elseif RunService:IsServer() then
        Constants.mainRemoteEvent.OnServerEvent:Connect(function(player: Player, mode: string, ...)
            if mode == "Pong" then
                Globals.player_ponged[player] = true
            end
        end)
        Players.PlayerRemoving:Connect(function(player: Player)
            Globals.player_ponged[player] = nil
        end)
    end
end


---------- Calling function ----------

main()


---------- Module ----------

local Module = {}


----- Module fields -----

function Module.ping_local()
    local startTime = time()
    if RunService:IsClient() then
        Globals.server_ponged = false
        Constants.mainRemoteEvent:FireServer("Ping")
        waitUntilPong_local()
    else
        warn("[Ping]: `ping_local` should only be called on client!")
    end
    return time() - startTime
end

function Module.ping_player(player: Player)
    local startTime = time()
    if RunService:IsServer() then
        Globals.player_ponged[player] = nil
        Constants.mainRemoteEvent:FireClient(player, "Ping")
        waitUntilPong_server(player)
    else
        warn("[Ping]: `ping_server` should only be called on server!")
    end
    return time() - startTime
end


---------- Return module ----------

return Module
