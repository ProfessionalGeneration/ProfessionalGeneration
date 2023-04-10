---@diagnostic disable: undefined-global
local library = loadstring(syn.request({Url = "https://raw.githubusercontent.com/GFXTI/ProfessionalGeneration/main/Library.lua"}).Body)() or {}
local sv = {
    uis = game:service"UserInputService",
    run = game:service"RunService",
    plrs = game:service"Players",
    ts = game:service"Teams",
    rs = game:service"ReplicatedStorage"
}
local hooks, enum, settings, remotes = {}, {}, {
    player = {
        ["Auto respawn"] = false,
        ["No root"] = false,
        ["Anti arrest"] = false,
    },
}, {
    item = workspace.Remote.ItemHandler,
    team = workspace.Remote.TeamEvent
}
local lp = sv.plrs.LocalPlayer
local time = lp.PlayerGui.Home.hud.Topbar.titleBar.Title.Text

setmetatable(sv, {
    __index = function(_, a)
        return game:service(a)
    end
})

local cons = {} do
    function cons.new(con)
        table.insert(cons, con)

        return con
    end
end

local funcs = {} do
    function funcs:ping()
        return sv.Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    end

    function funcs:gethumanoid(plr)
        return plr.Character and plr.Character:findFirstChildOfClass "Humanoid"
    end

    function funcs:firesynsignal(signal, ...)
        for i,v in getconnections(signal) do
            if v.Function and issynapsefunction(v.Function) then
                v.Function(...)
            end
        end
    end

    function funcs:plrfromstr(str)
        str = "^"..str:lower()

        for i,v in sv.plrs:players() do
            if v.Name:lower():find(str) or v.DisplayName:lower():find(str) then
                return v
            end
        end
    end

    function funcs:team(team, pos)
        local cam = workspace.CurrentCamera.CFrame
        pos = pos or lp.Character:getPivot()

        if team == "Really red" then
            if lp.Team == sv.ts.Guards then
                firetouchinterest(workspace["Criminals Spawn"].SpawnLocation, lp.Character and lp.Character.PrimaryPart or lp.CharacterAdded:wait():waitForChild"HumanoidRootPart", false)
                lp.CharacterAdded:wait():waitForChild "HumanoidRootPart".CFrame = pos
                workspace.CurrentCamera.CFrame = sv.run.RenderStepped:wait(1) and cam

                return
            end

            firetouchinterest(workspace["Criminals Spawn"].SpawnLocation, lp.Character and lp.Character.PrimaryPart or lp.CharacterAdded:wait():waitForChild"HumanoidRootPart", false)
        end

        if table.find({"Bright blue", "Bright orange"}, team) then
            remotes.team:FireServer(team)
            lp.CharacterAdded:wait():waitForChild "HumanoidRootPart".CFrame = pos
            workspace.CurrentCamera.CFrame = sv.run.RenderStepped:wait(1) and cam
        end
    end

    function funcs:respawn(pos)
        pos = pos or lp.Character:getPivot()
        local cam = workspace.CurrentCamera.CFrame

        if lp.Team == sv.ts.Criminals then
            if #sv.ts.Guards:getPlayers() < 8 then
                remotes.team:FireServer "Bright blue"
                firetouchinterest(workspace["Criminals Spawn"].SpawnLocation, lp.CharacterAdded:wait():waitForChild"HumanoidRootPart", false)
                lp.CharacterAdded:wait():waitForChild "HumanoidRootPart".CFrame = pos
                workspace.CurrentCamera.CFrame = sv.run.RenderStepped:wait(1) and cam

                return
            end

            remotes.team:FireServer "Bright orange"
            lp.CharacterAdded:wait():waitForChild "HumanoidRootPart".CFrame = pos;
            firetouchinterest(workspace["Criminals Spawn"].SpawnLocation, lp.Character and lp.Character.PrimaryPart or lp.CharacterAdded:wait():waitForChild"HumanoidRootPart", false)
            workspace.CurrentCamera.CFrame = sv.run.RenderStepped:wait(1) and cam

            return
        end

        if lp.Team == sv.ts.Guards then
            if #sv.ts.Guards:getPlayers() < 8 then
                remotes.team:FireServer "Bright blue"
                lp.CharacterAdded:wait():waitForChild "HumanoidRootPart".CFrame = pos
                workspace.CurrentCamera.CFrame = sv.run.RenderStepped:wait(1) and cam

                return
            end

            remotes.team:FireServer "Bright orange"
            remotes.team:FireServer "Bright blue";
            ({f = lp.CharacterAdded:wait(), r = lp.CharacterAdded:wait()})["r"]:waitForChild "HumanoidRootPart".CFrame = pos
            workspace.CurrentCamera.CFrame = sv.run.RenderStepped:wait(1) and cam

            return
        end

        remotes.team:FireServer "Bright orange"
        lp.CharacterAdded:wait():waitForChild "HumanoidRootPart".CFrame = pos
        workspace.CurrentCamera.CFrame = sv.run.RenderStepped:wait(1) and cam
    end

    function funcs:tool(tool: string | table)
        local tools = {}

        if type(tool) == "string" and (lp.Backpack:findFirstChild(tool) or lp.Character:findFirstChild(tool)) then
            return lp.Backpack:findFirstChild(tool) or lp.Character:findFirstChild(tool)
        end

        for i,v in (type(tool) == "string" and {tool} or tool) do
            task.spawn(remotes.item.InvokeServer, remotes.item, {
                Parent = workspace["Prison_ITEMS"].giver[v],
                Name = "ITEMPICKUP",
                Position = lp.Character:getPivot().p
            })

            tools[v] = lp.Backpack:waitForChild(v, funcs:ping() * 2)
        end

        return type(tool) == "string" and tools[tool] or tools
    end

    function funcs:humgrab(plr, tool)
        if not funcs:gethumanoid(lp) then return end
        tool = tool or lp.Backpack:findFirstChild "Handcuffs" or lp.Character:findFirstChild "Handcuffs" or (table.find({"Lunch", "Dinner", "Breakfest"}, time) and funcs:tool(time)) or lp.Team ~= sv.ts.Guards and (function()
            funcs:team("Bright blue")
            return lp.CharacterAdded:wait() and lp.Backpack:waitForChild "Handcuffs"
        end)()
        if not tool then return end
        local c = lp.Character
        local hum = funcs:gethumanoid(lp)
        local humclone = hum:clone()

        tool.Parent = lp.Backpack
        hum.Name = 1
        humclone.Parent = c
        task.wait(.05)
        hum:destroy()
        c.Animate.Disabled = true
        workspace.CurrentCamera.CameraSubject = c
        tool.Parent = c

        task.defer(firetouchinterest, tool.Handle, plr.Character.PrimaryPart, false)
    end

    function funcs:bring(plr, pos: CFrame?, tool: Tool?)
        local plrh, op = funcs:gethumanoid(plr), lp.Character:getPivot()
        if not plrh or not plr.Character or not plr.Character.PrimaryPart or plrh.Health == 0 then return end
        funcs:humgrab(plr, tool)
        lp.Character:pivotTo(pos or op)
        task.wait(math.clamp(.05 + funcs:ping() * 2, .1, 4.5))
        funcs:respawn(op)
    end
end

do
    local ui = library:new("Professional Generation", syn.request {Url = "https://cdn.discordapp.com/attachments/907173542972502072/1081826251758653540/1f602.png"}.Body)

    do
        local tab = ui:tab "Local"

        do
            local buttons = tab:side "Buttons"

            buttons:button("Rejoin", function()
                sv.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
            end)

            buttons:button("Respawn", function()
                funcs:respawn()
            end)

            buttons:button("No root", function()
                local c = lp.Character

                c.Parent = nil
                c.HumanoidRootPart.Parent = nil
                c.Parent = workspace
            end)
        end

        do
            local togs = tab:side "Toggles"
            local custom = {
                ["No root"] = function()
                    funcs:respawn()
                end
            }

            for i,v in settings.player do
                togs:toggle(i, v, function(val)
                    settings.player[i] = val

                    if custom[i] then
                        custom[i](val)
                    end
                end)
            end
        end

        do
            local teams = tab:side "Teams"

            for i,v in {["Criminal"] = "Really red", ["Guard"] = "Bright blue", ["Prisoner"] = "Bright orange"} do
                teams:button(i, function()
                    funcs:team(v)
                end)
            end
        end
    end

    do
        local tab = ui:tab "World"

        do
            local plrs = tab:side "Players"
            local plr

            plrs:textbox("Player", "Player name/display name", function(text)
                plr = funcs:plrfromstr(text)

                if not plr then
                    library:note("Player is not valid!", {
                        Time = 4,
                        Error = true
                    })
                end
            end)

            plrs:button("Bring", function()
                if not plr then return end

                funcs:bring(plr)
            end)
        end
    end
end

cons:new(lp.CharacterAdded:Connect(function(char)
    local hrp, hum = char:waitForChild "HumanoidRootPart", char:waitForChild "Humanoid"

    hum.Died:Once(function()
        if settings.player["Auto respawn"] then
            funcs:respawn(hrp:getPivot())
        end
    end)

    if settings.player["No root"] then
        task.delay(.25, function()
            char.Parent = nil
            hrp.Parent = nil
            char.Parent = workspace
        end)
    end
end))

cons:new(workspace.Remote.arrestPlayer.OnClientEvent:Connect(function()
    if not settings.player["Anti arrest"] then return end
    local oae, op, ot = settings.player["Auto respawn"], lp.Character:getPivot(), lp.TeamColor.Name
    settings.player["Auto respawn"] = false

    lp.Character:BreakJoints()
    lp.CharacterAdded:wait()

    settings.player["Auto respawn"] = oae

    if ot == "Bright orange" then
        funcs:respawn(op)

        return
    end

    if #sv.ts.Guards:getPlayers() < 8 then
        remotes.team:FireServer "Bright blue"
        firetouchinterest(workspace["Criminals Spawn"].SpawnLocation, lp.CharacterAdded:wait():waitForChild"HumanoidRootPart", false)
        lp.CharacterAdded:wait():waitForChild"HumanoidRootPart".CFrame = op
    else
        firetouchinterest(workspace["Criminals Spawn"].SpawnLocation, lp.Character:waitForChild"HumanoidRootPart", false)
        lp.Character:pivotTo(op)
    end
end))

cons:new(workspace.Remote.UpdateTopbar.OnClientEvent:connect(function(title, sub)
    time = title
end))

funcs:firesynsignal(lp.CharacterAdded, lp.Character)
