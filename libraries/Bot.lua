-- Now this is where we start actually interacting with the game instead of all this misc shit
-- might have to add support for custom characters later down the line but, thats a problem for future me!
local Get, Directory, File = loadfile("Progen/libraries/FileSystem.lua")()
local Network, Services, Math, ESL, Config = Get:Get"libraries":Get"Network":Load(), Get:Get"libraries":Get"Services":Load(), Get:Get"libraries":Get"Math":Load(), Get:Get"games":Get"ElectricState":Get"Functions", shared.Config
local Bot = {}
Bot.__index = function(self, key)
    return Bot[key] or self.__client[key]
end
local lp = Services.Playes.LocalPlayer

function Bot:new(Type)
    local BotClient = Network:new "10101"
    do
        local status
        repeat status = BotClient:Connect()
        until status and status.Return
    end

    return setmetatable({__client = BotClient, __type = Type, __position = table.find(BotClient:GetConnected(), lp.Name)}, Bot)
end

function Bot.Teleport(self, position: Vector3 | CFrame)
    if lp.Character and lp.Character:findFirstChild "HumanoidRootPart" then
        lp.Character.HumanoidRootPart.CFrame = typeof(position) == "Vector3" and CFrame.new(position, lp.Character.HumanoidRootPart.CFrame.LookAt) or position
    end
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

function Bot.SetConfig(self, configpath, setting, newvalue)
    local path = Config

    for i,v in configpath:split"/" do
        path = path[v]
    end

    path[setting] = newvalue
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
        ESL.Chat(v)
        continue
    end

    Bot:Send {
        Action = "Chat",
        Message = v
    }

    task.wait(2)
end
]]