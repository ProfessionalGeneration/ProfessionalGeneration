-- Now this is where we start actually interacting with the game instead of all this misc shit
-- might have to add support for custom characters later down the line but, thats a problem for future me!
local Get, Directory, File = loadfile("Progen/libraries/FileSystem.lua")()
local Network, Services, Config = Get:Get"libraries":Get"Network":Load(), Get:Get"libraries":Get"Services":Load(), shared.Config
local Bot = {}
local lp = Services.Playes.LocalPlayer

function Bot:new()
    local BotClient = Network:new "10101"
    do
        local status
        repeat status = BotClient:Connect()
        until status and status.Data and Stataus.Data.Message == "success"
    end

    return setmetatable({__client = BotClient}, Bot)
end

function Bot.Teleport(self, position: Vector3 | CFrame)
    if lp.Character and lp.Character:findFirstChild "HumanoidRootPart" then
        lp.Character.HumanoidRootPart.CFrame = typeof(position) == "Vector3" and CFrame.new(position, lp.Character.HumanoidRootPart.CFrame.LookAt) or position
    end
end

function Bot.Pathfind(self, position: Vector3, mode: string) -- lmao ill make an a* conversion later
    if not lp.Character or not lp.Character:findFirstChild "HumanoidRootPart" or not lp.Character:findFirstChild "Humanoid" then return end
    local points = {}
    local funcs = {}

    if mode == "Run" then
        for i,v in points do
            lp.Character.Humanoid:MoveTo(v)
            lp.Character.Humanoid.MoveToFinished:Wait()
        end
    end

    if mode == "Walkspeed" then -- i assume this is gonna run a lot fuckin better
        for i,v in points do
            local oldcf = lp.Character.HumanoidRootPart.CFrame

            Math.DeltaIter(0, 1, Config.Player.Walkspeed.Speed, function(inc) 
                lp.Character.HumanoidRootPart.CFrame = oldcf:Lerp(CFrame.new(v), inc)
            end)
        end
    end
end

function Bot.SetConfig(self, configpath, setting, newvalue)
    local path = Config

    for i,v in configpath:split"/" do
        path = path[v]
    end

    path[setting] = value
end

return Bot