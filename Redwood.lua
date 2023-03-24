---@diagnostic disable: undefined-global
local isv2 = select(2, identifyexecutor()):find "v2"
local library = not isv2 and loadstring(syn.request({Url = "https://raw.githubusercontent.com/GFXTI/ProfessionalGeneration/main/Library.lua"}).Body)() or {}
local sv = setmetatable({}, {
    __index = function(_, idx)
        return cloneref(game.GetService(game, idx))
    end
})
-- i rly dont wanna type these out in internal ui
getgenv().lp = sv.Players.LocalPlayer
getgenv().network = require(workspace.upsilonLibrary)
local kick = workspace.ignore.invisibleWalls:findFirstChild"armoryBarrier_Cheaters" or game:findFirstChild"armoryBarrier_Cheaters"
local hooks, enum, settings = {}, {
    kill = {
        "client",
        "melee",
        "gun",
    }
},
{
    player = {
        autore = true,
        antiarrest = true,
        antitase = false,
        antichoice = false,
        forcefield = false,
        forcefieldcolor = Color3.fromHSV(1, 1, 1),
        forcefieldsize = 10,
        defaultclothes = false,
        orbanim = false,
        antikick = true,
    }
}

local guns = {} do
    for i,v in workspace:children() do
        if v:findFirstChild "gunGiver" and not guns[v.Name] then
            guns[v.Name] = v
        end
    end
end

local cons = {} do
    function cons:new(con)
        table.insert(cons, con)

        return con
    end
end

local funcs = {} do
    function funcs:respawn(pos)
        pos = pos or lp.Character:GetPivot()
        network.FireServer "reloadMe"
        lp.CharacterAdded:Wait():WaitForChild"HumanoidRootPart".CFrame = pos
        lp.Character:WaitForChild "Humanoid":SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end

    function funcs:clonehumanoid()
        local c = lp.Character
        workspace.CurrentCamera.CameraSubject = c
        local hum = c:findFirstChildOfClass "Humanoid"
        local clone = hum:Clone()
        hum.Name = "nigger"

        clone.Name = "Humanoid"
        clone.Parent = c
        task.wait(.02)
        hum.Parent = nil

        c.Animate.Disabled = true
        workspace.CurrentCamera.CameraSubject = clone
    end

    function funcs:detatchcam()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

        return function()
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        end
    end

    function funcs:gethumanoid(plr)
        return plr.Character and plr.Character:findFirstChildOfClass "Humanoid"
    end

    function funcs:grab(instance, re)
        local hum = funcs:gethumanoid(lp)
        if not hum then return end

        task.spawn(network.InvokeServer, "giveRiotShield", instance:isA "Model" and (instance.PrimaryPart or instance:findFirstChildOfClass("Part", true)) or instance)

        if re then
            lp.Character.ChildAdded:Wait()
            task.delay(funcs:ping() * 2, funcs.respawn, lp.Character:GetPivot())
        end
    end

    function funcs:humgrab(plr)
        if not funcs:gethumanoid(lp) then return end
        local hum = funcs:gethumanoid(lp)
        local humclone = hum:Clone()
        local c = lp.Character

        hum.Name = 1
        humclone.Parent = c
        task.wait(.05)
        hum:Destroy()
        c.Animate.Disabled = true
        workspace.CurrentCamera.CameraSubject = c

        network.InvokeServer("giveItemApproved", "Hammer")
        local tool = lp.Backpack:waitForChild("Hammer")
        tool.Parent = c

        task.defer(firetouchinterest, tool.Handle, plr.Character.HumanoidRootPart, false)
    end

    function funcs:draw(props, client, p1, p2, perm)
        if perm then
            props["TopSurface"] = "Professional Generation (queue.synapse.to | discord.gg/ng8yFn2zX6)"
        end

        network.FireOtherClients("drawLaser", p1 or Vector3.zero, p2 or Vector3.zero, props)

        if client then
            local np = {}
            for i,v in props do
                if i == "CanCollide" then continue end

                np[i] = v
            end

            firesignal(network.revent.OnClientEvent, "drawLaser", p1 or Vector3.zero, p2 or Vector3.zero, np)
        end
    end

    function funcs:ping()
        return sv.Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    end

    function funcs:gun(order)
        local op = lp.Character:GetPivot()
        local reattach = funcs:detatchcam()

        for i,v in order do
            task.delay(funcs:ping() * 2, network.InvokeServer, "giveItemFromGunGiver", guns[v])
            lp.Character:PivotTo(guns[v].CFrame)
			lp.Backpack:waitForChild(v, funcs:ping() + 1)
        end

        lp.Character:PivotTo(op)
        reattach()
    end

    function funcs:arrest(plr, waitforchar)
        if plr.Team == sv.Teams.Police then
            funcs:grab(plr.Character.HumanoidRootPart)
            firetouchinterest(plr.Character.HumanoidRootPart, workspace["robber spawn"], false)
            plr:GetPropertyChangedSignal("Team"):Wait()
            funcs:respawn()
        end

        lp.Character:PivotTo(plr.Character:GetPivot())
        task.delay(funcs:ping() * 1.5, network.FireServer, "cuff", plr)

        return waitforchar and plr.CharacterAdded:Wait()
    end

    function funcs:kick(plr)
        local c = plr.Character

        funcs:humgrab(plr)
        task.wait(funcs:ping())
        for i = 1, 20 do
            task.spawn(firetouchinterest, c.HumanoidRootPart, workspace["robber spawn"], 0)
            task.spawn(firetouchinterest, c.HumanoidRootPart, kick, 0)
        end
    end

    function funcs:plrfromstr(str)
        str = "^"..str:lower()

        for i,v in sv.Players:players() do
            if v.Name:lower():find(str) or v.DisplayName:lower():find(str) then
                return v
            end
        end
    end

    function funcs:crash(power)
        local ct = table.create("FireOtherClients", 6999)

        for i = 1, power do
            network.FireOtherClients(unpack(ct))
        end
    end

    function funcs:kill(plr, method)
        if method == enum.kill.client then
            funcs:draw({
                Name = "Head",
                Parent = plr.Character,
            }, false, Vector3.zero, Vector3.zero)

            return
        end

        if method == enum.kill.melee then
            
        end
    end

    function funcs.dcall(func, ...)
        return funcs[func](funcs, ...)
    end
end

(function() -- if v3 down (wish i could do end)
    if isv2 then
        return
    end

    local ui = library:new("Professional Generation", syn.request({Url = "https://cdn.discordapp.com/attachments/907173542972502072/1081826251758653540/1f602.png"}).Body)

    do
        local tab = ui:tab "Player"

        do
            local plr = tab:side "Misc"

            plr:button("Rejoin", function()
                sv.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
            end)

            plr:button("Unlock gamepasses", function()
                for i,v in {"hasSpecOps", "hasAtv", "hasPilot", "hasSwat", "hasMerc"} do
                    network.data.setValue(v, true)
                end
            end)

            plr:button("Get guns", function()
                local order = {}

                for i,v in guns do
                    table.insert(order, i)
                end

                funcs:gun(order)
            end)

            plr:button("Mod guns", function()
                local func
                for i,v in filtergc("function", {Name = "itemCanFire"}) do
                    if getfenv(v).script:IsDescendantOf(game.Players.LocalPlayer) then
                        func = v

                        break
                    end
                end

                hookfunction(func, function(gun)
                    gun.curAmmo = math.huge
                    gun.coolDown = 0 -- bro what the fuck "coolDown"????
                    gun.fireType = "automatic"

                    return true
                end)
            end)
        end

        do
            local plr = tab:side "Toggles"

            plr:toggle("Default clothes", settings.player.defaultclothes, function(a)
                settings.player.defaultclothes = a
            end)

            plr:toggle("Auto respawn", settings.player.autore, function(a)
                settings.player.autore = a
            end)

            plr:toggle("Respawn when arrested", settings.player.antiarrest, function(a)
                settings.player.antiarrest = a
            end)

            plr:toggle("Anti tase", settings.player.antitase, function(a)
                settings.player.antitase = a
            end)

            plr:toggle("Anti choice ui", settings.player.antichoice, function(a)
                settings.player.antichoice = a
            end)

            plr:toggle("Anti unsual drawLaser", settings.player.antidraw, function(a)
                settings.player.antidraw = a
            end)

            plr:toggle("Force field", settings.player.forcefield, function(a)
                settings.player.forcefield = a
            end)

            plr:colorpicker("Force field color", settings.player.forcefieldcolor, function(a)
                settings.player.forcefieldcolor = a
            end)

            plr:slider("Force field size", 1, 100, settings.player.forcefieldsize, false, function(a)
                settings.player.forcefieldsize = a
            end)

            plr:toggle("Orb animation", settings.player.orbanim, function(a)
                settings.player.orbanim = a
            end)

            plr:toggle("Anti kick", settings.player.antikick, function(a)
                settings.player.antikick = a
            end)
        end
    end

    do
        local world = ui:tab "World"
        local selected

        do
            local tab = world:side "Players"

            tab:textbox("Player", "Name", function(a)
                selected = funcs:plrfromstr(a)
            end)

            tab:button("Kick", function()
                if not selected then return end

                funcs:kick(selected)
            end)

            tab:button("Kill", function()
                if not selected then return end

                funcs:kill(selected, enum.kill.client)
            end)
        end

        do
            local tab = world:side "World"
            local power = 100

            tab:button("Crash", function()
                funcs:crash(power)
            end)

            tab:slider("Crash power", 1, 300, 100, false, function(a)
                power = a
            end)
        end
    end
end)()

cons:new(lp.CharacterAdded:Connect(function(char)
    task.spawn(function()
        if not settings.player.defaultclothes then return end

        local sid, pid = char:WaitForChild"Shirt".ShirtTemplate, char:WaitForChild"Pants".PantsTemplate

        char.Shirt.Changed:Wait()
        task.delay(.2, network.FireServer, "wearShirt", sid)
        task.delay(.2, network.FireServer, "wearPants", pid)
    end)

    char:WaitForChild "Humanoid".Died:Connect(function()
        if settings.player.autore then
            funcs:respawn()
        end
    end)
end))

cons:new(network.revent.OnClientEvent:Connect(function(foc, plr, func, ...)
    if foc == "smallNotice" and plr:find("You were arrested by:") and settings.player.antiarrest then -- server fires it on u so foc and plr are not what their named
        funcs:respawn(sv.Players:findFirstChild(plr:sub(23)).Character:GetPivot())
    end
end))

cons:new(sv.UserInputService.InputBegan:Connect(function(a, b)
    if b then return end

    if a.KeyCode == Enum.KeyCode.Q then
        funcs:respawn()
    end
end))

cons:new(lp.Changed:Connect(function()
    if not settings.player.antikick or lp.Team == sv.Teams.Police then return end

    network.FireServer("becomeHostile")
end))

cons:new(workspace.DescendantAdded:Connect(function(item)
    if table.find({"robber spawn", "armoryBarrier_Cheaters"}, item.Name) then
        task.defer(item.Destroy, item)
        item.CanTouch = false
    end
end))

do
    local t = tick()
    local lpp = Vector3.zero

    cons:new(sv.RunService.RenderStepped:Connect(function()
        if tick() - t > .05 then
            t = tick()

            if settings.player.forcefield then
                lpp = lp.Character and lp.Character:GetPivot().p

                funcs:draw({
                    CanCollide = true,
                    Size = Vector3.new(settings.player.forcefieldsize, settings.player.forcefieldsize, settings.player.forcefieldsize),
                    Color = settings.player.forcefieldcolor,
                    Material = Enum.Material.ForceField,
                    Shape = Enum.PartType.Ball,
                    Parent = workspace,
                }, true, lpp, lpp - Vector3.new(0, 2, 0))
            end
        end
    end))
end

do
    local i, t, lpp = 0, tick(), Vector3.zero

    cons:new(sv.RunService.RenderStepped:Connect(function(d)
        i += d
        if tick() - t > .05 then
            t = tick()

            if settings.player.orbanim then
                local p = lp.Character and lp.Character:GetPivot()
                lpp = lp.Character and (p + (p.LookVector + p.UpVector) * -2).p

                for a = 1, 2 do
                    for inc = 1, 2 do
                        funcs:draw({
                            CanCollide = false,
                            Size = Vector3.new(2, 2, 2),
                            Color = Color3.fromHSV(math.acos(math.cos(((i / 10) / inc) * math.pi)) / math.pi, 1, 1),
                            Material = Enum.Material.Neon,
                            Shape = Enum.PartType.Ball,
                            Parent = workspace,
                            Position = lpp + Vector3.new(
                                math.sin(i) * (inc == 1 and 1 or -1),
                                math.sin(i) * (inc == 1 and 1 or -1),
                                0
                            ) * 3 * (a == 1 and -1 or 1)
                        }, true, Vector3.zero, Vector3.zero)
                    end
                end
            end
        end
    end))
end

if not isv2 then
    hooksignal(network.revent.OnClientEvent, function(connection, ...)
        if issynapsefunction(connection.Function) then return true, ... end
        if select("#", ...) > 20 then return end

        if select(1, ...) == "taseMe" and settings.player.antitase then
            return
        end

        if select(3, ...) == "displayChoice" and settings.player.antichoice then
            return
        end

        if select(3, ...) == "drawLaser" and settings.player.antidraw then
            local props = select(6, ...)

            if type(props) == "table" then
                for i,v in props do
                    if not table.find({"BrickColor", "Material", "Reflectance"}, i) then
                        return
                    end

                    if not table.find({BrickColor.new("Bright yellow"), .5, Enum.Material.Neon}, v) then
                        return
                    end
                end
            end
        end

        return true, ...
    end)
end

do
    for i,v in workspace.ignore.invisibleWalls:children() do
        v.Parent = game
    end
end

--funcs:gun({"M16", "M60", "ACR"})

--[[
    while task.wait() do
        if game.Players.LocalPlayer.Team ~= game.Teams.Police then
            require(workspace.upsilonLibrary).InvokeServer("requestTeam", "police")
        end
    end
]]
