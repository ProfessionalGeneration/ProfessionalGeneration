-- Now this is where we start actually interacting with the game instead of all this misc shit
-- might have to add support for custom characters later down the line but, thats a problem for future me!
local Get, Directory, File = loadfile("Progen/libraries/FileSystem.lua")()
local Network, Services, Math, ESL, Config = Get:Get"libraries":Get"Network":Load(), Get:Get"libraries":Get"Services":Load(), Get:Get"libraries":Get"Math":Load(), Get:Get"games":Get"ElectricState":Get"Functions", shared.Config
local Bot = {}
Bot.__index = function(self, key)
    return Bot[key] or self.__client[key]
end
local lp = Services.Playes.LocalPlayer

function JsonToCFrame(pos) -- thank you paa!
    return CFrame.new(unpack(pos:split(', ')))
end

function Bot:new(Type)
    local BotClient = Network:new "10101"
    do
        local status
        repeat status = BotClient:Connect()
        until status and status.Return
    end

    BotClient.Recieved:Connect(function(data) -- this is going to look exactly like the networkserver :3 (no its not i just havent updated with current verion)
        local recieved = Services.Http:JSONDecode(data)

        if recieved.Data then
            if recieved.Data.Action == "Join" and game.JobId ~= data.JobId then
                Services.Teleport:TeleportToPlaceInstance(game.PlaceId, data.JobId)
            end

            if recieved.Data.Action == "Chat" and data.JobId == game.JobId then            
                ESL.Util.Chat(recieved.Data.Message)
            end

            if recieved.Data.Action == "Shoot" then
                ESL.Combat.Shoot(Services.Players[recieved.Data.Player])
            end

            if recieved.Data.Action == "Node" then
                ESL.Building.Place("Node", JsonToCFrame(recieved.Data.CFrame))
            end

            if recieved.Data.Action == "Build" then
                ESL.Building.Place(recieved.Data.PropName, JsonToCFrame(recieved.Data.CFrame), recieved.Data.Color, recieved.Data.Material, recieved.Data.Size)
            end

            if recieved.Data.Action == "Edit" then
                local prop = (function() 
                    for i,v in workspace.Buildings[lp.Name]:children() do
                        if v.PrimaryPart.CFrame == JsonToCFrame(recieved.Data.PartCFrame) then
                            return v
                        end
                    end
                end)()

                ESL.Building.Edit(prop, JsonToCFrame(recieved.Data.CFrame), recieved.Data.Color, recieved.Data.Material, recieved.Data.Size)
            end
        end
    end)

    return setmetatable({__client = BotClient, __type = Type, __position = table.find(BotClient:GetConnected(), lp.Name)}, Bot)
end

function Bot.Move(self, position: Vector3 | CFrame)
    ESL.Movement.Teleport(type(position) == "Vector3" and CFrame.new(position, lp.Character:getPivot().lookVector) or position)
end

function Bot.Guard(self, cf: Vector3, size: Vector3, Callback)
    if not lp.Character or not lp.Character:findFirstChild "HumanoidRootPart" or not lp.Character:findFirstChild "Humanoid" then return end
    local points = {
        [1] = cf * CFrame.new(size.X / 2, size.Y / 2, size.Z / 2), -- toprightfront
        [3] = cf * CFrame.new(size.X / 2, size.Y / 2, size.Z / -2), -- toprightback
        [5] = cf * CFrame.new(size.X / -2, size.Y / 2, size.Z / 2), -- topleftfront
        [8] = cf * CFrame.new(size.X / -2, size.Y / 2, size.Z / -2), -- topleftback
        [7] = cf * CFrame.new(size.X /  2, size.Y / -2, size.Z / 2), -- bottomrightfront
        [6] = cf * CFrame.new(size.X / 2, size.Y / -2, size.Z / -2), -- bottomrightback
        [4] = cf * CFrame.new(size.X / -2, size.Y / -2, size.Z / 2), -- bottomleftfront
        [2] = cf * CFrame.new(size.X / -2, size.Y / -2, size.Z / -2), -- bottomleftback
    }

    for i = 1, 8 do -- just incase update ever called while moving
        local oldcf = lp.Character.HumanoidRootPart.CFrame

        Math.DeltaIter(0, 1, Config.Player.Walkspeed.Speed, function(inc)
            lp.Character.HumanoidRootPart.CFrame = oldcf:Lerp(CFrame.new(points[i]), inc)
        end)
    end

    return {
        Update = function(cf, size)
            points = {
                [1] = cf * CFrame.new(size.X / 2, size.Y / 2, size.Z / 2), -- toprightfront
                [3] = cf * CFrame.new(size.X / 2, size.Y / 2, size.Z / -2), -- toprightback
                [5] = cf * CFrame.new(size.X / -2, size.Y / 2, size.Z / 2), -- topleftfront
                [8] = cf * CFrame.new(size.X / -2, size.Y / 2, size.Z / -2), -- topleftback
                [7] = cf * CFrame.new(size.X /  2, size.Y / -2, size.Z / 2), -- bottomrightfront
                [6] = cf * CFrame.new(size.X / 2, size.Y / -2, size.Z / -2), -- bottomrightback
                [4] = cf * CFrame.new(size.X / -2, size.Y / -2, size.Z / 2), -- bottomleftfront
                [2] = cf * CFrame.new(size.X / -2, size.Y / -2, size.Z / -2), -- bottomleftback
            }
        end
    }
end

return Bot

--[[
LMAO i thought of something hilarious during my math class, and it brings back old piano v1.4 days...
Theyve got allen wrenches...

local lyrics = {
    
}
local BotIncrement = 0
local Bots = Bot.__client:GetConnected()

for i,v in lyrics do
    BotIncrement += 1
    if BotIncrement == 1 then
        ESL.Util .Chat(v)
        continue
    end

    Bot:Send {
        Action = "Chat",
        Message = v
    }

    task.wait(1)
end
]]