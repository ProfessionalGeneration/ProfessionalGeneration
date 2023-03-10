--[==[
    I did most of the library (me sawd yes me)

    thank topit for the colorpicker gradient images
    THANK FRICK FOR THE ANGLER MATH THAT ONE RLY SUCKED FIXING (he pro)
]==]
-- i should move these gradients probably to github
local cams = workspace.CurrentCamera.ViewportSize
local gradient = syn.request({Url = "https://media.discordapp.net/attachments/907173542972502072/1076735971749535845/angryimg.png"}).Body
local colorpgradient = syn.request({Url = "https://media.discordapp.net/attachments/907173542972502072/1079247178410774630/overlay3.png"}).Body
local huegradient = syn.request({Url = "https://media.discordapp.net/attachments/907173542972502072/1079217266744381442/hue.png"}).Body
local startpos = (cams / 2) - Vector2.new(300, 200)
local lib = {
    AccentColor = Color3.new(0.078431, 0.333333, 0.878431)
}
local notes = {}
local cons = {}
local accents = {}
local shortendbinds = {["MouseButton1"] = "MB1", ["MouseButton2"] = "MB2", ["MouseButton3"] = "MB3", ["PageUp"] = "PUp", ["PageDown"] = "PDn", ["Home"] = "Hm", ["Delete"] = "Del", ["Insert"] = "Ins", ["LeftAlt"] = "LAlt", ["LeftControl"] = "LC", ["LeftShift"] = "LS", ["RightAlt"] = "RAlt", ["RightControl"] = "RC", ["RightShift"] = "RS", ["CapsLock"] = "Caps"} -- https://github.com/dotowasbaking/fricklib/blob/main/main.lua (i rly didnt wanna make any of this)
local sv = setmetatable({}, {__index = function(_, a)
    return game:GetService(a)
end})
local Draw do
    local drag = {}
    local funcs = {
        ["isinframe"] = function(frame, pos)
            if table.find({"Image", "Square"}, tostring(frame)) then
                return pos.X >= frame.Position.X and pos.Y >= frame.Position.Y and pos.X <= frame.Position.X + frame.Size.X and pos.Y <= frame.Position.Y + frame.Size.Y
            end

            if tostring(frame) == "Text" then
                local fpos = frame.Center and frame.Position - (frame.TextBounds / 2) or frame.Position

                return pos.X >= fpos.X and pos.Y >= fpos.Y and pos.X <= fpos.X + frame.TextBounds.X and pos.Y <= fpos.Y + frame.TextBounds.Y
            end
        end
    }
    local ctypes = { -- i love how i used this in exactly NONE of the ui lib at all
        ["clicked"] = function(frame) -- will return click pos
            local event = Instance.new("BindableEvent")

            sv.UserInputService.InputBegan:Connect(function(input, _)
                if _ then return end
                local mpos = sv.UserInputService:GetMouseLocation()

                if input.UserInputType == Enum.UserInputType.MouseButton1 and frame.Visible and funcs.isinframe(frame, mpos) then
                    event:Fire(mpos)
                end
            end)

            return event
        end
    }

    function Draw(type)
        local obj = Drawing.new(type)
        local tbl = {obj = obj, type = type, name = type, parent = nil}

        function tbl:children(recursive)
            local c = {}

            for i,v in tbl do
                if i ~= "parent" and typeof(v) == "table" then
                    table.insert(c, v)

                    if recursive then
                        table.foreach(v:children(true), function(_, descendant)
                            table.insert(c, descendant)
                        end)
                    end
                end
            end

            return c
        end

        function tbl:isa(type)
            return type == tbl.type
        end

        function tbl:connect(ctype, callback)
            assert(ctypes[ctype], "no connection type found")

            return ctypes[ctype](tbl.obj).Event:Connect(callback)
        end

        return setmetatable(tbl, {
            __newindex = function(_, k, v)
                if obj[k] ~= nil then
                    obj[k] = v

                    return
                end

                if k == "parent" then
                    table.insert(v, tbl)
                end

                if k == "draggable" then
                    table[v and "insert" or "remove"](drag, v and tbl or table.find(drag, tbl))
                end

                rawset(tbl, k, v)
            end,
            __index = function(a, b)
                return obj[b] ~= nil and obj[b] or nil
            end,
            __tostring = function()
                return tbl.name
            end
        })
    end

    do
        local dcon
        local offset = Vector2.zero

        table.insert(cons, sv.UserInputService.InputBegan:Connect(function(input, _)
            if _ or input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            local mpos = sv.UserInputService:GetMouseLocation()

            for i,v in drag do
                if v.Visible and funcs.isinframe(v.obj, mpos) and (function()
                    for i2,v2 in v:children(true) do
                        if v2:isa "Square" and not v2.Filled then continue end
                        if v2.Visible and v2.Opacity ~= 0 and funcs.isinframe(v2.obj, mpos) then return end
                    end

                    return true
                end)() then
                    offset = mpos - v.Position
                    local offsets = {}

                    for _,v2 in v:children(true) do
                        offsets[_] = mpos - v2.Position
                    end

                    dcon = sv.RunService.RenderStepped:Connect(function()
                        if not sv.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                            dcon:Disconnect()

                            return
                        end

                        v.Position = sv.UserInputService:GetMouseLocation() - offset

                        for _,v2 in v:children(true) do
                            v2.Position = sv.UserInputService:GetMouseLocation() - offsets[_]
                        end
                    end)

                    table.insert(cons, dcon)
                end
            end
        end))
    end
end

local function Box(frame, z, top)
    local d = {s = Draw "Square", ts = Draw "Square", l = Draw "Square"}
    local pos = frame.Position
    local size = frame:isa "Text" and frame.TextBounds or frame.Size

    d.s.Visible = true
    d.s.Color = Color3.new(.05, .05, .05)
    d.s.Position = pos - Vector2.new(1, 1)
    d.s.Size = size + Vector2.new(2, 2)
    d.s.Thickness = 2
    d.s.ZIndex = z or 1
    d.s.parent = frame
    d.s.name = "s"

    if top then
        d.ts.Visible = true
        d.ts.Color = Color3.new(.05, .05, .05)
        d.ts.Position = pos - Vector2.new(1, 6)
        d.ts.Size = Vector2.new(size.X + 2, 6)
        d.ts.Thickness = 2
        d.ts.ZIndex = z or 1
        d.ts.parent = frame
        d.ts.name = "ts"

        d.l.Visible = true
        d.l.Color = lib.AccentColor
        d.l.Position = pos - Vector2.new(-1, 4)
        d.l.Size = Vector2.new(size.X - 2, 2)
        d.l.Thickness = 2
        d.l.ZIndex = z or 1
        d.l.parent = frame
        d.l.name = "l"
    end

    table.insert(accents, d.l)

    return d
end

local function GetGradientBox(vis)
    local box = Draw "Image"

    box.obj.Data = gradient
    box.Visible = vis
    box.Color = Color3.new(.2, .2, .2)
    box.name = "GradientBox"

    return box
end

local function Lerp(a, b, t)
    return a + (b - a) * t
end

local function GetTextSize(text, size, font)
    local t = Drawing.new "Text"

    t.Text = text
    t.Size = size
    t.Font = font

    return t.TextBounds
end

local function clamp(a, b, c)
    return a < b and b or a > c and c or a
end

local function GetMousePosition()
    return sv.UserInputService:GetMouseLocation()
end

local function IsInFrame(frame, mouse)
    return frame.Position.Y < mouse.Y and mouse.Y < frame.Position.Y + frame.Size.Y and frame.Position.X < mouse.X and mouse.X < frame.Position.X + frame.Size.X
end

local function Ease(x)
    return math.sin((x * math.pi) / 2)
end

local function Scrolling(frame, options)
    options = options or {scrollamount = 10, paddingbottom = 0}

    table.insert(cons, sv.UserInputService.InputChanged:Connect(function(a, b)
        if b then return end

        if a.UserInputType == Enum.UserInputType.MouseWheel and IsInFrame(frame, GetMousePosition()) and frame.Visible and frame.Opacity ~= 0 then
            local up = a.Position.Z > 0

            for i,v in frame:children(true) do
                if (table.find({"l", "ts", "s"}, v.name) and v.parent == frame) then continue end

                task.spawn(function()
                    for _ = 1, options.scrollamount / 5 do
                        v.Position += Vector2.new(0, (up and options.scrollamount or -options.scrollamount) / 5)
                        if v.Position.Y <= frame.Position.Y or v.Position.Y + (typeof(v.Size) == "Vector2" and v.Size or v.TextBounds).Y >= frame.Position.Y + frame.Size.Y - options.paddingbottom then
                            v.Visible = false

                            for _, v2 in v:children(true) do
                                v2.Visible = false
                            end
                        end

                        if v.Position.Y > frame.Position.Y and v.Position.Y + (typeof(v.Size) == "Vector2" and v.Size or v.TextBounds).Y < frame.Position.Y + frame.Size.Y - options.paddingbottom then
                            v.Visible = true

                            for _, v2 in v:children(true) do
                                v2.Visible = true
                            end
                        end

                        task.wait()
                    end
                end)
            end
        end
    end))
end

local function IsInCircle(circle, pos)
    local mag = (circle.Position - pos).magnitude

    if mag >= circle.Radius - circle.Thickness and mag <= circle.Radius + circle.Thickness then
        return mag
    end
end

local function List(list, name)
    local e = Instance.new "BindableEvent"
    local main = GetGradientBox(true)
    local text = Draw "Text"
    local main2 = GetGradientBox(true)
    local lcons = {}

    main.ZIndex = 10
    main.Position = (cams / 2) - Vector2.new(610, 65)
    main.Size = Vector2.new(240, 125)
    main.draggable = true

    main2.ZIndex = 10
    main2.Position = main.Position + Vector2.new(5, 30)
    main2.Size = Vector2.new(230, 90)
    main2.parent = main
    main2.name = "main2"

    text.ZIndex = 11
    text.Visible = true
    text.Outline = true
    text.Color = Color3.new(1,1,1)
    text.Size = 15
    text.Font = Drawing.Fonts.Monospace
    text.Text = name
    text.Position = main.Position + Vector2.new(4, 4)
    text.name = name
    text.parent = main

    for i,v in list do
        local option = Draw "Text"
        local box = Draw "Square"

        box.ZIndex = 12
        box.Position = main2.Position + Vector2.new(4, 4) + Vector2.new(0, 20 * (i - 1))
        box.Size = Vector2.new(220, 15)
        box.parent = main2
        Box(box, 12)

        option.Visible = i < 4
        option.ZIndex = 13
        option.Outline = true
        option.Color = Color3.new(1,1,1)
        option.Size = 15
        option.Font = Drawing.Fonts.Monospace
        option.Text = tostring(v)
        option.Position = box.Position + Vector2.new(2)
        option.parent = box
        option.name = tostring(v)

        local con = sv.UserInputService.InputBegan:Connect(function(a, _)
            if _ then return end

            if a.UserInputType == Enum.UserInputType.MouseButton1 and option.Visible and option.Opacity ~= 0 and IsInFrame(box, GetMousePosition()) then
                e:Fire(v)

                table.foreach(lcons, function(_, v)
                    v:Disconnect()
                end)

                main.obj:Remove()
                table.foreach(main:children(true), function(_, v)
                    v.obj:Remove()
                end)
            end
        end)

        table.insert(cons, con)
        table.insert(lcons, con)
    end

    Box(main, 10, true)
    Box(main2, 11, true)
    Scrolling(main2, {scrollamount = 20, paddingbottom = 2})

    return e.Event:Wait()
end

local function rgb255(rgb)
    return rgb.R * 255, rgb.G * 255, rgb.B * 255
end

function lib:Chatlogs() -- someone test if this wok plsss
    local box = GetGradientBox(true)
    local ibox = GetGradientBox(true)
    local text = Draw "Text"
    
    box.Size = Vector2.new(400, 300)
    box.Position = Vector2.new(500, 500)
    box.Visible = true
    box.ZIndex = 20
    box.draggable = true

    text.Position = box.Position + Vector2.new(2)
    text.Size = 18
    text.parent = box
    text.name = "title"
    text.Text = "Chat logs"
    text.Font = Drawing.Fonts.Monospace
    text.Visible = true
    text.ZINdex = 21
    text.Color = Color3.new(1,1,1)
    text.Outline = true

    ibox.Position = box.Position + Vector2.new(10, 20)
    ibox.Size = Vector2.new(380, 264)
    ibox.Visible = true
    ibox.ZIndex = 21
    ibox.parent = box

    Box(ibox, 21, true)
    Box(box, 20, true)
    local update = Scrolling(ibox, {
        scrollamount = 16,
        paddingbottom = -2
    })

    local function Add(plr, msg) -- oh fuck i got no clue
        local txt = Draw "Text"
        --txt.Position = 
    end

    return function()
        box.obj:Destroy()

        for i,v in box:chldren(true) do
            v.obj:Desroy()
        end
    end
end

function lib:loader(name)
    local loader = {}
    local box = GetGradientBox(true)
    local mc = Draw "Circle"
    local oc = Draw "Circle"
    local ic = Draw "Circle"
    local d = {Draw "Circle", Draw "Circle", Draw "Circle", Draw "Circle", Draw "Circle", Draw "Circle"}
    local title = Draw "Text"
    local ltext = Draw "Text"
    local i, si, con = 0, 0

    box.Position = cams / 2 - Vector2.new(150, 50)
    box.Size = Vector2.new(300, 100)
    box.ZIndex = 50
    box.draggable = true

    title.Visible = true
    title.Size = 20
    title.ZIndex = 51
    title.Outline = true
    title.Font = Drawing.Fonts.Monospace
    title.Color = Color3.new(1, 1, 1)
    title.Position = box.Position + Vector2.new(box.Size.X / 2, 5)
    title.Text = name
    title.parent = box
    title.Center = true
    title.name = "title"

    ltext.Visible = true
    ltext.Size = 17
    ltext.ZIndex = 51
    ltext.Outline = true
    ltext.Font = Drawing.Fonts.Monospace
    ltext.Color = Color3.new(.7, .7, .7)
    ltext.Position = box.Position + Vector2.new(box.Size.X / 2, 30)
    ltext.Text = ""
    ltext.parent = box
    ltext.Center = true
    ltext.name = "title"

    mc.Position = box.Position + (box.Size / 2) + Vector2.new(0, 23)
    mc.Radius = 22
    mc.ZIndex = 51
    mc.Color = lib.AccentColor
    mc.Thickness = 2
    mc.Visible = true
    mc.parent = box
    mc.name = "middlecircle"

    oc.Position = box.Position + (box.Size / 2) + Vector2.new(0, 23)
    oc.Radius = 24
    oc.ZIndex = 51
    oc.Color = Color3.new()
    oc.Thickness = 1
    oc.Visible = true
    oc.parent = box
    oc.name = "outsidecircle"

    ic.Position = box.Position + (box.Size / 2) + Vector2.new(0, 23)
    ic.Radius = 20
    ic.ZIndex = 51
    ic.Color = Color3.new()
    ic.Thickness = 1
    ic.Visible = true
    ic.parent = box
    ic.name = "insidecircle"

    for _,v in d do
        v.parent = mc
        v.name = "loadercirclethinngy"..tostring(_)
        v.Radius = 2
        v.ZIndex = 52
        v.Thickness = 1
        v.Filled = true
        v.Visible = true
    end

    con = sv.RunService.Heartbeat:Connect(function()
        i += 1

        for _, v in d do
            v.Position = mc.Position + (Vector2.new(
                math.sin(
                    math.rad(i + (_ * (360 / #d)))
                ),
                math.cos(
                    math.rad(i + (_ * (360 / #d)))
                ))
                * 22
            )-- shitty code whatever
            v.Position += Vector2.new(v.Position.X < mc.Position.X and 1 or 0, 0)
        end
    end)

    table.insert(cons, con)

    Box(box, 50, true)

    function loader:set(text)
        ltext.Text = text
    end

    function loader:finish()
        task.spawn(function()
            for inc = 1, -.05, -.05 do
                box.Opacity = inc

                for _,v in box:children(true) do
                    v.Opacity = inc
                end

                task.wait()
            end

            box.obj:Remove()

            for _,v in box:children(true) do
                v.obj:Remove()
            end

            con:Disconnect()
        end)
    end

    return loader
end

function lib:note(msg, settings) -- -> any if settings.type is question (returns nil if none chosen in time)
    local box = GetGradientBox(true)
    local box2 = GetGradientBox(true)
    local timer = GetGradientBox(true)
    local text = Draw "Text"
    local sizex = GetTextSize(msg, 18, Drawing.Fonts.Monospace).X + 8
    local start = Vector2.new(-sizex - 2, 40)
    table.insert(accents, timer)
    settings = settings or {
        Error = false,
        Question = false,
        Time = 8,
        ThereIsABombUnderTheWhiteHouse = false,
        Options = {},
    }
    local opts = {}
    local offsets = {}
    local ret = settings.Question and Instance.new "BindableEvent" or nil
    local answered, con, tcon

    for i,v in notes do
        task.spawn(function()
            for inc = 1, settings.Question and 28 or 19 do
                v.Position += Vector2.new(0, 2)

                for _, c in v:children(true) do
                    c.Position += Vector2.new(0, 2)
                end

                task.wait()
            end
        end)
    end

    notes[#notes+1] = box

    box.Position = start
    box.Size = Vector2.new(sizex, 26)
    box.ZIndex = 20
    box.t = msg

    box2.Color = Color3.new(.1, .1, .1)
    box2.parent = box
    box2.Size = box.Size - Vector2.new(6, 7)
    box2.Position = box.Position + Vector2.new(3, 4)
    box2.ZIndex = 21
    box2.Color = Color3.new(.13, .13, .13)

    timer.Position = box.Position + Vector2.new(0, box.Size.Y - 2)
    timer.parent = box
    timer.Size = Vector2.new(1, 2)
    timer.Color = settings.Error and Color3.new(1, 0, 0) or lib.AccentColor
    timer.ZIndex = 22
    timer.name = "timer"

    text.Visible = true
    text.Size = 18
    text.ZIndex = 22
    text.Outline = true
    text.Font = Drawing.Fonts.Monospace
    text.Color = Color3.new(1, 1, 1)
    text.Position = box2.Position - Vector2.new(0, 1)
    text.Text = msg
    text.parent = box2
    text.name = "text"

    for i,v in settings.Question and settings.Options or {} do
        local option = GetGradientBox(true)
        local ot = Draw "Text"
        local pos = 1
        for _, v2 in opts do
            pos += v2.Size.X + 5
        end

        option.parent = box
        option.name = v
        option.Position = start + Vector2.new(pos, 31)
        option.ZIndex = 22
        option.Size = Vector2.new(GetTextSize(v, 15, Drawing.Fonts.Monospace).X + 2, 14)

        ot.Visible = true
        ot.Size = 15
        ot.ZIndex = 23
        ot.Outline = true
        ot.name = tostring(v)
        ot.Font = Drawing.Fonts.Monospace
        ot.Color = Color3.new(1, 1, 1)
        ot.Position = option.Position - Vector2.new(-1, 1)
        ot.Text = tostring(v)
        ot.parent = option

        Box(option, 22)
        opts[v] = option
    end

    con = sv.UserInputService.InputBegan:Connect(function(a, _)
        if _ then return end

        if a.UserInputType == Enum.UserInputType.MouseButton1 then
            for i,v in opts do
                if IsInFrame(v, GetMousePosition()) then
                    ret:Fire(i)
                    answered = true
                end
            end
        end
    end)

    Box(box, 20, true).l.Color = settings.Error and Color3.new(1, 0, 0) or lib.AccentColor
    Box(box2, 21)

    task.spawn(function()
        local t = tick()
        local ia = .01

        for i,v in box:children(true) do
            offsets[v] = v.Position.X - start.X
        end

        for i = 0, 1.01, .01 do
            box.Position = Vector2.new(Lerp(start.X, start.X + sizex + 40, Ease(i)), box.Position.Y)

            for _,v in box:children(true) do
                v.Position = Vector2.new(Lerp(start.X, start.X + sizex + 40, Ease(i)) + offsets[v], v.Position.Y)
            end

            task.wait()
        end

        tcon = sv.RunService.Heartbeat:Connect(function()
            timer.Size = Vector2.new(math.clamp((tick() - t) / settings.Time * sizex, 1, sizex), timer.Size.Y)
            timer.Opacity = math.acos(math.cos(ia * math.pi) / math.pi) - .8
            ia += .005

            if IsInFrame(box, GetMousePosition()) then
                t = tick()
            end
        end)

        repeat task.wait() until tick() - t > settings.Time or answered
        con:Disconnect()
        tcon:Disconnect()
        task.defer(table.remove, notes, table.find(notes, box))
        if tick() - t < settings.Time and settings.Question then
            ret:Fire()
        end

        for i = 1.2, -0.01, -.01 do
            box.Position = Vector2.new(Lerp(start.X, start.X + sizex + 40, Ease(i)), box.Position.Y)

            for _,v in box:children(true) do
                v.Position = Vector2.new(Lerp(start.X, start.X + sizex + 40, Ease(i)) + offsets[v], v.Position.Y)
            end

            task.wait()
        end

        for i,v in notes do
            if v.Position.Y < box.Position.Y then continue end
            task.spawn(function()
                for inc = 1, settings.Question and 28 or 19 do
                    v.Position -= Vector2.new(0, 2)

                    for _, c in v:children(true) do
                        c.Position -= Vector2.new(0, 2)
                    end

                    task.wait()
                end
            end)
        end
    end)

    return ret and ret.Event:Wait()
end

function lib:bindlist()
    local binds = {}
    local bts = {}

    local main = GetGradientBox(true)
    local title = Draw "Text"
    main.Position = Vector2.new(20, cams.Y / 1.7)
    main.Size = Vector2.new(200, 50)
    main.draggable = true

    title.Visible = true
    title.Size = 18
    title.Outline = true
    title.Font = Drawing.Fonts.Monospace
    title.Color = Color3.new(1, 1, 1)
    title.Position = main.Position + Vector2.new(main.Size.X / 2, 3)
    title.Center = true
    title.Text = "[ Keybinds ]"
    title.parent = main
    title.name = "title"

    local b = Box(main, 0, true)

    local function Resize()
        local sizex = 200
        local sizey = 25

        for i,v in bts do
            sizey += 20

            if main.Position.X + sizex - 6 < v.Position.X + v.TextBounds.X then
                sizex += (main.Position.X + main.Size.X - 6) - (v.Position.X + v.TextBounds.X)
            end
        end

        main.Size = Vector2.new(sizex, sizey)
        b.s.Size = Vector2.new(sizex + 2, sizey + 2)
    end

    local function len() -- i hate lua
        local i = 0
        for _, v in bts do i+=1 end
        return i
    end

    function binds:add(name, default, toggle, callback)
        local bind = {}
        local sb = default.EnumType == Enum.KeyCode and 14 or 19
        local con, toggled, con2
        local bt = Draw "Text"

        bts[name] = bt
        bt.Visible = true
        bt.Size = 16
        bt.Outline = true
        bt.Font = Drawing.Fonts.Monospace
        bt.Color = Color3.new(1, 1, 1)
        bt.Position = main.Position + Vector2.new(5, 2 + (len() * 20))
        bt.Text = ("[%s | %s] %s"):format(toggle and "Toggle" or "Hold", shortendbinds[tostring(default):sub(sb)] or tostring(default):sub(sb), name)
        bt.parent = main
        bt.name = name

        con = sv.UserInputService.InputBegan:Connect(function(a, _b)
            if _b then return end

            if a.KeyCode == default or a.UserInputType == default then
                if toggle then
                    toggled = not toggled
                    bt.Color = toggled and lib.AccentColor or Color3.new(1, 1, 1)
                    callback(toggled)
                else
                    bt.Color = lib.AccentColor
                    callback(true)
                end
            end
        end)

        con2 = sv.UserInputService.InputEnded:Connect(function(a)
            if not toggle and a.KeyCode == default or a.UserInputType == default then
                bt.Color = Color3.new(1, 1, 1)
                callback(true)
            end
        end)

        table.insert(cons, con)
        table.insert(cons, con2)

        Resize()

        function bind:set(newbind)
            default = newbind
            sb = default.EnumType == Enum.KeyCode and 14 or default.EnumType == Enum.UserInputType and 19
            bt.Text = ("[%s | %s] %s"):format(toggle and "Toggle" or "Hold", shortendbinds[tostring(newbind):sub(sb)] or tostring(newbind):sub(sb), name)

            Resize()
        end

        function bind:remove()
            table.remove(bts, table.find(bts, bt))
            bt.obj:Destroy()
            for i,v in bts do
                v.Position -= Vector2.new(0, 20)
            end
            con:Disconnect()
            con2:Disconnect()

            Resize()
        end

        return bind
    end

    Resize()

    return binds
end

function lib:togglelist()
    local togs = {}
    local objs = {}

    local function l()
        local i = 0
        for _,v in objs do i+=1 end
        return i
    end

    function togs:add(name)
        local tt = Draw "Text"

        objs[name] = tt
        tt.Visible = true
        tt.Size = 24
        tt.Outline = true
        tt.Font = Drawing.Fonts.Monospace
        tt.Color = Color3.fromHSV(math.acos(math.cos((l() / 20) * math.pi)) / math.pi, 1, 1)
        tt.Position = cams - Vector2.new(GetTextSize(name, 24, Drawing.Fonts.Monospace).X, 24 + ((l() - 1) * 26))
        tt.Text = name
    end

    function togs:remove(name)
        objs[name].obj:Destroy()

        for i,v in objs do
            v.Position += Vector2.new(0, 26)
        end
    end

    return togs
end

--[[function lib:commandbar() -- i dont wanna fuckin make this rn
    local cbar = {
        FocusKey = Enum.KeyCode.Semicolon,
        cmds = {
            {
                name = "print",
                aliases = "p",
                func = function(...)
                    print(...)
                end
            }
        }
    }
    -- sdata here cuz ik people only gonna use the ui lib
    local sdata = syn.request({Url = "https://cdn.discordapp.com/attachments/907173542972502072/1081870705471262760/334-3349023_free-white-settings-icon-png-tool-icon-white.png"}).Body

    local box = GetGradientBox(true)
    local listbb = GetGradientBox(true)
    local listb = Draw "Image"
    local tb = GetGradientBox(true)
    local tbtext = Draw "Text"
    local cb = Instance.new("TextBox", sv.CoreGui) -- uea i dont feel like making my own fucking keyboard handler
    box.Size = Vector2.new(241, 25)
    box.Position = Vector2.new(30, cams.Y - 60)
    box.draggable = true

    listbb.Position = box.Position + Vector2.new(222, 6)
    listbb.Size = Vector2.new(14, 14)
    listbb.ZIndex = 1
    listbb.parent = box
    listbb.Color = Color3.new(.1, .1, .1)

    listb.Visible = true
    listb.ZIndex = 2
    listb.Position = listbb.Position
    listb.Size = Vector2.new(14, 14)
    listb.parent = listbb
    listb.name = "list button"
    listb.obj.Data = sdata

    tb.Position = box.Position + Vector2.new(5, 6)
    tb.Size = Vector2.new(box.Size.X - 31, 14)
    tb.Color = Color3.new(.1, .1, .1)
    tb.ZIndex = 1
    tb.parent = box
    tb.name = "tb"

    tbtext.ZIndex = 1
    tbtext.Visible = true
    tbtext.Outline = true
    tbtext.Color = Color3.new(.7, .7, .7)
    tbtext.Size = 16
    tbtext.Font = Drawing.Fonts.Monospace
    tbtext.Text = ("%s to focus"):format(shortendbinds[tostring(cbar.FocusKey):sub(14)] or tostring(cbar.FocusKey):sub(14))
    tbtext.Position = tb.Position + Vector2.new(2, -2)
    tbtext.parent = tb

    Box(box, 0, true)
    Box(tb, 1)
    Box(listb, 1)

    table.insert(cons, cb.Focused:Connect(function()
        tbtext.Text = ""
        tbtext.Color = lib.AccentColor
        local tcon = cb.Changed:Connect(function()
            tbtext.Text = cb.Text
        end)

        table.insert(cons, tcon)
        cb.FocusLost:Wait()
        tcon:Disconnect()
        tbtext.Text = ("%s to focus"):format(shortendbinds[tostring(cbar.FocusKey):sub(14)] or tostring(cbar.FocusKey):sub(14))
        tbtext.Color = Color3.new(.7, .7, .7)
    end))

    table.insert(cons, sv.UserInputService.InputBegan:Connect(function(a, b)
        if b then return end

        if a.KeyCode == cbar.FocusKey then
            task.defer(cb.CaptureFocus, cb)

            return
        end

        if a.UserInputType == Enum.UserInputType.MouseButton1 then
            if IsInFrame(tb, GetMousePosition()) then
                cb:CaptureFocus()

                return
            end

            if IsInFrame(listbb, GetMousePosition()) then
                local list = GetGradientBox(true)
                local title = Draw "Text"

                list.Size = Vector2.new(241, 400)
                list.Position = box.Position - Vector2.new(0, 410)
                list.ZIndex = 4
                list.draggable = true

                title.ZIndex = 1
                title.Visible = true
                title.Outline = true
                title.Color = Color3.new(1,1,1)
                title.Size = 18
                title.Font = Drawing.Fonts.Monospace
                title.Text = "Settings  |  Commands"
                title.Position = list.Position + Vector2.new(20, 1)
                title.parent = tb
                title.ZIndex = 5

                for i,v in cbar.cmds do
                    
                end

                Box(list, 4, true)
            end
        end
    end))

    function cbar:remove()
        for i,v in box:children(true) do
            v.obj:Destroy()
        end

        cb:Destroy()
    end

    return cbar
end]]

function lib:new(libname, logodata)
    local oldop = {}
    local library = {
        tabs = {
            --[[
                sides = {
                    ops = {}
                }
                clickable = nil
                tab = nil
            ]]
        },
        dtabs = {}
    }
    local i = 0
    local listopen

    local topbox = GetGradientBox(true)
    local label = Draw "Text"
    local logo = logodata and Draw "Image"

    topbox.Position = startpos
    topbox.Size = Vector2.new(700, 421)
    topbox.draggable = true

    if logodata then
        logo.Position = topbox.Position + Vector2.new(5, 2)
        logo.Size = Vector2.new(18, 18)
        logo.Visible = true
        logo.parent = topbox
        logo.name = "logo"
        logo.obj.Data = logodata -- fuck you luau why do i always have to do obj.Data
        logo.ZIndex = 50
        logo.Opacity = 1
    end

    label.Visible = true
    label.Size = 18
    label.Outline = true
    label.Font = Drawing.Fonts.Monospace
    label.Color = Color3.new(1, 1, 1)
    label.Position = topbox.Position + Vector2.new(3 + (logo and 27 or 0), 2)
    label.Text = libname
    label.parent = topbox
    label.name = "label"

    local box = GetGradientBox(true)
    box.Position = topbox.Position + Vector2.new(5, 30)
    box.Size = Vector2.new(690, 386)
    box.parent = topbox

    Box(topbox, 0, true)
    Box(box, 1, true)

    local function SaveOps()
        oldop[topbox] = topbox.Opacity
        for _,v in topbox:children(true) do
            oldop[v] = v.Opacity
        end
    end

    do
        local vis = true

        table.insert(cons, sv.UserInputService.InputBegan:Connect(function(a, _)
            if _ then return end

            if a.KeyCode == Enum.KeyCode.RightShift then
                local change = {topbox}
                vis = not vis

                if not vis then
                    SaveOps()

                    for __,v in topbox:children(true) do
                        if v.Opacity == 0 then continue end

                        table.insert(change, v)
                    end
                else
                    for __,v in topbox:children(true) do
                        if oldop[v] == 0 then continue end

                        table.insert(change, v)
                    end
                end

                local start = vis and 0 or 1
                local down = vis
                local hb = sv.RunService.Heartbeat

                repeat
                    start = down and start + (hb:Wait() * 8) or start - (hb:Wait() * 8)

                    for __,v in change do
                        v.Opacity = start
                    end
                until start < 0 or start > 1

                for __,v in change do
                    v.Opacity = vis and 1 or 0
                end
            end
        end))
    end

    function library:tab(name)
        local tab = {}
        i += 1
        local si = 0
        local par = GetGradientBox(true)
        par.Visible = true
        par.Opacity = i == 1 and 1 or 0
        par.Position = box.Position + Vector2.new(5, 52)
        par.Size = Vector2.new(90, 329)
        par.parent = box
        par.name = name
        par.ZIndex = 2
        table.foreach(Box(par, 2, true), function(_, v)
            v.Visible = true
            v.Opacity = i == 1 and 1 or 0
        end)

        library.tabs[name] = {
            sides = {
                --[[
                    {
                        tab = drawing,
                        ops = {},
                        clickable = nil
                    }
                ]]
            },
            ops = {}, -- opaques
            tab = par
        }

        do
            local ci = i
            local cbox = GetGradientBox(true)
            local tname = Draw "Text"
            local sizex = GetTextSize(name, 16, Drawing.Fonts.Monospace).X + 8
            local pos = 0

            for _,v in library.dtabs do
                pos += v.Size.X + 10
            end

            cbox.Position = box.Position + Vector2.new(5 + pos, 10)
            cbox.Size = Vector2.new(sizex, 30)
            cbox.ZIndex = 2
            cbox.parent = box
            cbox.name = 'tabh'..name

            tname.Visible = true
            tname.Size = 16
            tname.Outline = true
            tname.ZIndex = 2
            tname.Font = Drawing.Fonts.Monospace
            tname.Color = Color3.new(1, 1, 1)
            tname.Position = cbox.Position + Vector2.new(4, 6)
            tname.Text = name
            tname.name = name
            tname.parent = cbox

            Box(cbox, 2, true)

            library.tabs[name].clickable = cbox
            library.dtabs[ci] = cbox

            table.insert(cons, sv.UserInputService.InputBegan:Connect(function(a, b)
                if b then return end

                if a.UserInputType == Enum.UserInputType.MouseButton1 then -- theres gotta be a better way to do this riiight?
                    if IsInFrame(cbox, GetMousePosition()) then
                        local otab = library.tabs[name].tab
                        local ops = library.tabs[name].ops

                        for _,v in library.tabs do
                            if v.tab.Opacity ~= 0 then
                                v.ops[v.tab] = v.tab.Opacity

                                for _,v2 in v.tab:children(true) do
                                    v.ops[v2] = v2.Opacity
                                end

                                v.tab.Opacity = 0
                                for _,v2 in v.tab:children(true) do
                                    v2.Opacity = 0
                                end
                            end
                        end

                        otab.Opacity = 1
                        for _, v in otab:children(true) do
                            v.Opacity = ops[v] or 1
                        end
                    end
                end
            end))
        end

        function tab:side(sname)
            local tbox = GetGradientBox(true)
            tbox.Size = Vector2.new(80, 20)
            tbox.Position = par.Position + Vector2.new(5, 5 + (si * 27))
            tbox.ZIndex = 2
            tbox.parent = par
            tbox.name = sname

            Box(tbox, 2)

            do
                local tl = Draw "Text"

                tl.Visible = true
                tl.Size = 18
                tl.Outline = true
                tl.Font = Drawing.Fonts.Monospace
                tl.Color = Color3.new(1, 1, 1)
                tl.Position = tbox.Position + Vector2.new(2)
                tl.Text = sname
                tl.parent = tbox
                tl.name = "label"
                tl.ZIndex = 2

                si += 1

                table.insert(cons, sv.UserInputService.InputBegan:Connect(function(a, b)
                    if b then return end

                    if a.UserInputType == Enum.UserInputType.MouseButton1 then
                        if IsInFrame(tbox, GetMousePosition()) and tbox.Visible and tbox.Opacity ~= 0 then
                            local otab = library.tabs[name].sides[sname].tab
                            local ops = library.tabs[name].sides[sname].ops

                            for _,v in library.tabs[name].sides do
                                if v.tab.Opacity ~= 0 then
                                    print(v.tab)
                                    v.ops[v.tab] = v.tab.Opacity

                                    for _,v2 in v.tab:children(true) do
                                        v.ops[v2] = v2.Opacity
                                    end

                                    v.tab.Opacity = 0
                                    for _,v2 in v.tab:children(true) do
                                        v2.Opacity = 0
                                    end
                                end
                            end

                            otab.Opacity = 1
                            for _, v in otab:children(true) do
                                v.Opacity = ops[v] or v.op or 1
                            end
                        end
                    end
                end))
            end

            local wbox = GetGradientBox(true)
            library.tabs[name].sides[sname] = {tab = wbox, ops = {}}
            local buttons = 0
            local side = {}

            wbox.ZIndex = 2
            wbox.Position = box.Position + Vector2.new(105, 52)
            wbox.Size = Vector2.new(580, 329)
            wbox.parent = tbox
            wbox.name = sname
            wbox.Opacity = si == 1 and i == 1 and 1 or 0
            Scrolling(wbox, {scrollamount = 25, paddingbottom = -2})

            table.foreach(Box(wbox, 2, true), function(_,v)
                v.Visible = true
                v.Opacity = si == 1 and i == 1 and 1 or 0
            end)

            function side:button(bname, callback)
                local bbox = GetGradientBox(buttons < 13)
                local text = Draw "Text"

                bbox.ZIndex = 3
                bbox.Position = wbox.Position + Vector2.new(5, 5 + (25 * buttons))
                bbox.Size = Vector2.new(570, 20)
                bbox.parent = wbox
                bbox.name = bname
                bbox.Opacity = si == 1 and i == 1 and 1 or 0

                text.ZIndex = 3
                text.Visible = buttons < 13
                text.Center = true
                text.Outline = true
                text.Color = Color3.new(1,1,1)
                text.Size = 18
                text.Font = Drawing.Fonts.Monospace
                text.Text = bname
                text.Position = bbox.Position + (bbox.Size / 2) - Vector2.new(0, 10)
                text.parent = bbox
                text.name = "text"
                text.Opacity = si == 1 and i == 1 and 1 or 0

                table.foreach(Box(bbox, 3), function(_,v)
                    v.Visible = true
                    v.Opacity = si == 1 and i == 1 and 1 or 0
                end)

                table.insert(cons, sv.UserInputService.InputBegan:Connect(function(a, b)
                    if b or listopen then return end

                    if a.UserInputType == Enum.UserInputType.MouseButton1 and bbox.Visible and bbox.Opacity ~= 0 then
                        if IsInFrame(bbox, GetMousePosition()) then
                            pcall(callback)
                        end
                    end
                end))

                buttons += 1
            end

            function side:toggle(bname, default, callback)
                local bbox = GetGradientBox(buttons < 13)
                local tb = Draw "Square"
                local text = Draw "Text"
                table.insert(accents, tb)

                bbox.ZIndex = 3
                bbox.Position = wbox.Position + Vector2.new(5, 5 + (25 * buttons))
                bbox.Size = Vector2.new(570, 20)
                bbox.name = bname
                bbox.parent = wbox
                bbox.Opacity = si == 1 and i == 1 and 1 or 0

                text.ZIndex = 3
                text.Visible = buttons < 13
                text.Outline = true
                text.Color = Color3.new(1,1,1)
                text.Size = 18
                text.Font = Drawing.Fonts.Monospace
                text.Text = bname
                text.Position = bbox.Position + Vector2.new(4)
                text.parent = bbox
                text.name = bname
                text.Opacity = si == 1 and i == 1 and 1 or 0

                tb.Position = bbox.Position + bbox.Size - Vector2.new(20, 17)
                tb.Size = Vector2.new(14, 14)
                tb.Visible = buttons < 13
                tb.Color = lib.AccentColor
                tb.ZIndex = 3
                tb.Filled = true
                tb.parent = bbox
                tb.name = "tb"
                tb.Opacity = i == 1 and default and 1 or 0
                tb.op = default and 1 or 0

                table.foreach(Box(tb, 3), function(_,v)
                    v.Visible = buttons < 13
                    v.Opacity = si == 1 and i == 1 and 1 or 0
                end)

                table.foreach(Box(bbox, 3), function(_,v)
                    v.Visible = buttons < 13
                    v.Opacity = si == 1 and i == 1 and 1 or 0
                end)

                table.insert(cons, sv.UserInputService.InputBegan:Connect(function(a, b)
                    if b or listopen then return end

                    if a.UserInputType == Enum.UserInputType.MouseButton1 and bbox.Visible and bbox.Opacity ~= 0 then
                        if IsInFrame(bbox, GetMousePosition()) then
                            default = not default
                            task.spawn(function()
                                for inc = default and 0 or 1, default and 1 or 0, default and .05 or -.05 do
                                    tb.Opacity = inc
                                    task.wait()
                                end
                            end)
                            pcall(callback, default)
                        end
                    end
                end))

                buttons += 1
            end

            function side:slider(bname, min, max, default, precise, callback)
                local bbox = GetGradientBox(buttons < 13)
                local b2box =GetGradientBox(buttons < 13)
                local text = Draw "Text"
                local con
                table.insert(accents, b2box)

                bbox.ZIndex = 3
                bbox.Position = wbox.Position + Vector2.new(5, 5 + (25 * buttons))
                bbox.Size = Vector2.new(570, 20)
                bbox.name = bname
                bbox.parent = wbox
                bbox.Opacity = si == 1 and i == 1 and 1 or 0

                b2box.Position = bbox.Position
                b2box.ZIndex = 3
                b2box.Size = Vector2.new((1 - ((max - default) / (max - min))) * 570, 21)
                b2box.Color = lib.AccentColor
                b2box.parent = bbox
                b2box.name = "b2box"
                b2box.Opacity = si == 1 and i == 1 and 1 or 0

                text.ZIndex = 5
                text.Visible = buttons < 13
                text.Center = true
                text.Outline = true
                text.Color = Color3.new(1,1,1)
                text.Size = 18
                text.Font = Drawing.Fonts.Monospace
                text.Text = ("%s [%i|%i]"):format(bname, default, max)
                text.Position = bbox.Position + (bbox.Size / 2) - Vector2.new(0, 10)
                text.parent = bbox
                text.name = "text"
                text.Opacity = si == 1 and i == 1 and 1 or 0

                table.foreach(Box(bbox, 3), function(_,v)
                    v.Visible = buttons < 13
                    v.Opacity = si == 1 and i == 1 and 1 or 0
                end)

                table.insert(cons, sv.UserInputService.InputBegan:Connect(function(a, b)
                    if b or listopen then return end

                    if a.UserInputType == Enum.UserInputType.MouseButton1 and bbox.Visible and bbox.Opacity ~= 0 and IsInFrame(bbox, GetMousePosition()) then
                        con = sv.RunService.Heartbeat:Connect(function()
                            local p = math.clamp((GetMousePosition().X - bbox.Position.X) / (bbox.Size.X), 0, 1)
					        local vtn = Lerp(min, max, p)

                            vtn = precise and tonumber(("%.2f"):format(vtn)) or math.round(vtn)
                            text.Text = ("%s [%i|%i]"):format(bname, vtn, max)
                            b2box.Size = Vector2.new(p * 570 > 1 and p * 570 or 1, b2box.Size.Y)
                            pcall(callback, vtn)
                        end)

                        table.insert(cons, con)
                    end
                end))

                table.insert(cons, sv.UserInputService.InputEnded:Connect(function(a, b)
                    if b then return end

                    if a.UserInputType == Enum.UserInputType.MouseButton1 then
                        pcall(con and con.Disconnect or function() end, con)
                    end
                end))

                buttons += 1
            end

            function side:bind(bname, default, callback)
                local bbox = GetGradientBox(buttons < 13)
                local tb = GetGradientBox(buttons < 13)
                local text = Draw "Text"
                local key =  Draw "Text"
                local keybox
                local is

                local function Update(new)
                    local ts = GetTextSize(new, 18, Drawing.Fonts.Monospace).X
                    local ep = bbox.Position.X + bbox.Size.X - 11 - ts

                    tb.Position = Vector2.new(ep, bbox.Position.Y + 3)
                    tb.Size = Vector2.new(ts + 6, 14)
                    key.Position = tb.Position + Vector2.new(2, -2)
                    keybox.s.Position = tb.Position - Vector2.new(1, 1)
                    keybox.s.Size = tb.Size + Vector2.new(1, 1)
                    key.Text = new
                end

                bbox.ZIndex = 3
                bbox.Position = wbox.Position + Vector2.new(5, 5 + (25 * buttons))
                bbox.Size = Vector2.new(570, 20)
                bbox.name = bname
                bbox.parent = wbox
                bbox.Opacity = si == 1 and i == 1 and 1 or 0

                text.ZIndex = 3
                text.Visible = buttons < 13
                text.Outline = true
                text.Color = Color3.new(1,1,1)
                text.Size = 18
                text.Font = Drawing.Fonts.Monospace
                text.Text = bname
                text.Position = bbox.Position + Vector2.new(4)
                text.parent = bbox
                text.name = bname
                text.Opacity = si == 1 and i == 1 and 1 or 0

                tb.Position = bbox.Position + bbox.Size - Vector2.new(20, 17)
                tb.Size = Vector2.new(14, 14)
                tb.Color = Color3.new(.1, .1, .1)
                tb.ZIndex = 3
                tb.parent = bbox
                tb.name = "tb"
                tb.Opacity = si == 1 and i == 1 and 1 or 0

                key.ZIndex = 3
                key.Visible = buttons < 13
                key.Outline = true
                key.Color = Color3.new(1,1,1)
                key.Size = 18
                key.Font = Drawing.Fonts.Monospace
                key.Text = shortendbinds[tostring(default):sub(14)] or tostring(default):sub(14)
                key.Position = tb.Position + Vector2.new(2, -2)
                key.parent = bbox
                key.name = "key"
                key.Opacity = si == 1 and i == 1 and 1 or 0

                keybox = Box(tb, 3)
                table.foreach(keybox, function(_,v)
                    v.Visible = buttons < 13
                    v.Opacity = si == 1 and i == 1 and 1 or 0
                end)

                table.foreach(Box(bbox, 3), function(_,v)
                    v.Visible = buttons < 13
                    v.Opacity = si == 1 and i == 1 and 1 or 0
                end)

                table.insert(cons, sv.UserInputService.InputBegan:Connect(function(a, b)
                    if b or is or listopen then return end

                    if a.UserInputType == Enum.UserInputType.MouseButton1 and bbox.Visible and bbox.Opacity ~= 0 then
                        if IsInFrame(bbox, GetMousePosition()) then
                            Update("...")
                            is = true
                        end
                    end
                end))

                table.insert(cons, sv.UserInputService.InputBegan:Connect(function(a, b)
                    if b then return end

                    if a.KeyCode == default and not is then
                        pcall(callback, a.KeyCode)
                    end

                    if a.KeyCode ~= Enum.KeyCode.Unknown and is then
                        Update(shortendbinds[tostring(a.KeyCode):sub(14)] or tostring(a.KeyCode):sub(14))
                        default = a.KeyCode
                        is = false
                        pcall(callback, a.KeyCode)
                    end
                end))

                Update(shortendbinds[tostring(default):sub(14)] or tostring(default):sub(14))
                buttons += 1
            end

            function side:list(bname, list, callback)
                local bbox = GetGradientBox(buttons < 13)
                local text = Draw "Text"

                bbox.ZIndex = 3
                bbox.Position = wbox.Position + Vector2.new(5, 5 + (25 * buttons))
                bbox.Size = Vector2.new(570, 20)
                bbox.parent = wbox
                bbox.name = bname
                bbox.Opacity = si == 1 and i == 1 and 1 or 0

                text.ZIndex = 3
                text.Visible = buttons < 13
                text.Center = true
                text.Outline = true
                text.Color = Color3.new(1,1,1)
                text.Size = 18
                text.Font = Drawing.Fonts.Monospace
                text.Text = bname.." [None selected]"
                text.Position = bbox.Position + (bbox.Size / 2) - Vector2.new(0, 10)
                text.parent = bbox
                text.name = bname
                text.Opacity = si == 1 and i == 1 and 1 or 0

                table.foreach(Box(bbox, 3), function(_,v)
                    v.Visible = true
                    v.Opacity = si == 1 and i == 1 and 1 or 0
                end)

                table.insert(cons, sv.UserInputService.InputBegan:Connect(function(a, b)
                    if b then return end

                    if a.UserInputType == Enum.UserInputType.MouseButton1 and bbox.Visible and bbox.Opacity ~= 0 then
                        if IsInFrame(bbox, GetMousePosition()) then
                            local at = List(list, bname)

                            text.Text = ("%s [%s]"):format(bname, tostring(at))
                            pcall(callback, at)
                        end
                    end
                end))

                buttons += 1
            end

            function side:colorpicker(bname, default, callback) -- thanks topit for giving me the images (and bit of other help) 🤑💲💸🤑💹💳💳
                local bbox = GetGradientBox(buttons < 13)
                local tb = Draw "Square"
                local text = Draw "Text"
                local colorbox, rb, ccon, cccon
                local rainbow = false

                bbox.ZIndex = 3
                bbox.Position = wbox.Position + Vector2.new(5, 5 + (25 * buttons))
                bbox.Size = Vector2.new(570, 20)
                bbox.name = bname
                bbox.parent = wbox
                bbox.Opacity = si == 1 and i == 1 and 1 or 0

                text.ZIndex = 3
                text.Visible = buttons < 13
                text.Outline = true
                text.Color = Color3.new(1,1,1)
                text.Size = 18
                text.Font = Drawing.Fonts.Monospace
                text.Text = bname
                text.Position = bbox.Position + Vector2.new(4)
                text.parent = bbox
                text.name = bname
                text.Opacity = si == 1 and i == 1 and 1 or 0

                tb.Position = bbox.Position + bbox.Size - Vector2.new(20, 17)
                tb.Size = Vector2.new(14, 14)
                tb.Visible = buttons < 13
                tb.Color = default
                tb.ZIndex = 3
                tb.Filled = true
                tb.parent = bbox
                tb.name = "tb"
                tb.Opacity = si == 1 and i == 1 and 1 or 0

                table.foreach(Box(tb, 3), function(_,v)
                    v.Visible = buttons < 13
                    v.Opacity = si == 1 and i == 1 and 1 or 0
                end)

                table.foreach(Box(bbox, 3), function(_,v)
                    v.Visible = buttons < 13
                    v.Opacity = si == 1 and i == 1 and 1 or 0
                end)

                do
                    local inc = 0

                    table.insert(cons, sv.RunService.Heartbeat:Connect(function(a)
                        inc += a / 2

                        local color = Color3.fromHSV(math.acos(math.cos(inc * math.pi)) / math.pi, 1, 1)
                        if rb then
                            rb.Color = color
                        end

                        if rainbow then
                            tb.Color = color
                            pcall(callback, color)
                        end
                    end))
                end

                table.insert(cons, sv.UserInputService.InputBegan:Connect(function(a, b)
                    if b or listopen then return end

                    if colorbox and IsInFrame(bbox, GetMousePosition()) and bbox.Visible and bbox.Opacity ~= 0 then
                        colorbox.obj:Remove()

                        table.foreach(colorbox:children(true), function(_, v)
                            v.obj:Remove()
                        end)

                        colorbox = nil
                        rb = nil
                        ccon:Disconnect()
                        cccon:Disconnect()
                        return
                    end

                    if a.UserInputType == Enum.UserInputType.MouseButton1 and bbox.Visible and bbox.Opacity ~= 0 then
                        if IsInFrame(bbox, GetMousePosition()) then
                            colorbox = GetGradientBox(true)
                            local gbox = GetGradientBox(true)
                            local hbox = GetGradientBox(true)
                            local hxbox = GetGradientBox(true)
                            local rgbbox= GetGradientBox(true)
                            rb = GetGradientBox(true)
                            local hdbox = Draw "Square"
                            local bgbox = Draw "Square"
                            local hxt =   Draw "Text"
                            local rgbt =  Draw "Text"
                            local title = Draw "Text"
                            local con, shdbox
                            local pH, pY, pX = default:ToHSV()

                            colorbox.ZIndex = 7
                            colorbox.Position = tb.Position + Vector2.new(40, 14)
                            colorbox.Size = Vector2.new(300, 225)
                            colorbox.draggable = true

                            title.ZIndex = 8
                            title.Visible = true
                            title.Outline = true
                            title.Color = Color3.new(1,1,1)
                            title.Size = 16
                            title.Font = Drawing.Fonts.Monospace
                            title.Text = bname
                            title.Position = colorbox.Position + Vector2.new(10, 2)
                            title.parent = colorbox
                            title.name = "title"

                            hbox.ZIndex = 8
                            hbox.Position = colorbox.Position + Vector2.new(270, 25)
                            hbox.Size = Vector2.new(20, 160)
                            hbox.obj.Data = huegradient
                            hbox.Color = Color3.new(1,1,1)
                            hbox.parent = colorbox
                            hbox.name = "hbox"

                            hdbox.Position = hbox.Position - Vector2.new(1, -5)
                            hdbox.Size = Vector2.new(22, 3)
                            hdbox.Color = Color3.new(1,1,1)
                            hdbox.name = "slider"
                            hdbox.ZIndex = 9
                            hdbox.parent = hbox
                            hdbox.Filled = true
                            hdbox.Visible = true

                            gbox.ZIndex = 8
                            gbox.Position = colorbox.Position + Vector2.new(8, 25)
                            gbox.Size = Vector2.new(250, 160)
                            gbox.obj.Data = colorpgradient
                            gbox.parent = colorbox
                            gbox.Color = default
                            gbox.name = "gbox"

                            bgbox.ZIndex = 7
                            bgbox.Visible = true
                            bgbox.Position = gbox.Position
                            bgbox.Size = gbox.Size
                            bgbox.Filled = true
                            bgbox.parent = gbox
                            bgbox.Color = Color3.new(1,1,1)
                            bgbox.name = "bgbox"

                            hxbox.ZIndex = 8
                            hxbox.Position = colorbox.Position + Vector2.new(8, 195)
                            hxbox.Size = Vector2.new(80, 20)
                            hxbox.parent = colorbox
                            hxbox.Color = Color3.new(.1, .1, .1)
                            hxbox.name = "hxbox"

                            hxt.ZIndex = 8
                            hxt.Visible = true
                            hxt.Outline = true
                            hxt.Color = Color3.new(1,1,1)
                            hxt.Size = 16
                            hxt.Font = Drawing.Fonts.Monospace
                            hxt.Text = "#"..default:ToHex()
                            hxt.Position = hxbox.Position + Vector2.new(2, 2)
                            hxt.parent = hxbox
                            hxt.name = "title"

                            rgbbox.ZIndex = 8
                            rgbbox.Position = colorbox.Position + Vector2.new(100, 195)
                            rgbbox.Size = Vector2.new(120, 20)
                            rgbbox.parent = colorbox
                            rgbbox.Color = Color3.new(.1, .1, .1)
                            rgbbox.name = "rgbbox"

                            rgbt.ZIndex = 8
                            rgbt.Visible = true
                            rgbt.Outline = true
                            rgbt.Color = Color3.new(1,1,1)
                            rgbt.Size = 16
                            rgbt.Font = Drawing.Fonts.Monospace
                            rgbt.Text = ("%i, %i, %i"):format(rgb255(default))
                            rgbt.Position = rgbbox.Position + Vector2.new(2, 2)
                            rgbt.parent = rgbbox
                            rgbt.name = "title"

                            rb.Position = colorbox.Position + Vector2.new(233, 195)
                            rb.Size = Vector2.new(20, 20)
                            rb.name = "rainbow"
                            rb.ZIndex = 8
                            rb.parent = colorbox

                            Box(colorbox, 7, true)
                            Box(gbox, 8)
                            Box(hbox, 8)
                            Box(hxbox, 8)
                            Box(rgbbox, 8)
                            Box(rb, 8)
                            shdbox = Box(hdbox, 9)

                            hdbox.Position = Vector2.new(hbox.Position.X - 1, Lerp(hbox.Position.Y, hbox.Position.Y + hbox.Size.Y, select(1, default:ToHSV())))
                            shdbox.s.Position = hdbox.Position - Vector2.one

                            ccon = sv.UserInputService.InputBegan:Connect(function(a2, b2)
                                if b2 then return end

                                if a2.UserInputType == Enum.UserInputType.MouseButton1 then
                                    if rb and IsInFrame(rb, GetMousePosition()) then
                                        rainbow = not rainbow

                                        if not rainbow then
                                            tb.Color = default
                                            pcall(callback, default)
                                        end

                                        return
                                    end

                                    if IsInFrame(rgbbox, GetMousePosition()) then
                                        local cb = Instance.new("TextBox", sv.CoreGui)
                                        cb:CaptureFocus()
                                        rgbt.Text = ""
                                        local tcon = cb.Changed:Connect(function()
                                            rgbt.Text = cb.Text
                                        end)

                                        table.insert(cons, tcon)
                                        cb.FocusLost:Wait()
                                        tcon:Disconnect()
                                        cb.Text = cb.Text:gsub(" ", "")
                                        local spl = cb.Text:split(",")
                                        local rgb = Color3.fromRGB(tonumber(spl[1]), tonumber(spl[2]), tonumber(spl[3]))

                                        default = rgb
                                        gbox.Color = Color3.fromHSV(select(1, rgb:ToHSV()), 1, 1)
                                        tb.Color = rgb
                                        hdbox.Position = Vector2.new(hbox.Position.X - 1, Lerp(hbox.Position.Y, hbox.Position.Y + hbox.Size.Y, select(1, rgb:ToHSV())))
                                        pH, pY, pX = rgb:ToHSV()
                                        shdbox.s.Position = hdbox.Position - Vector2.one
                                        pcall(callback, rgb)
                                        cb:Destroy()

                                        return
                                    end

                                    if IsInFrame(hxbox, GetMousePosition()) then
                                        local cb = Instance.new("TextBox", sv.CoreGui)
                                        cb:CaptureFocus()
                                        hxt.Text = ""
                                        local tcon = cb.Changed:Connect(function()
                                            hxt.Text = cb.Text
                                        end)

                                        table.insert(cons, tcon)
                                        cb.FocusLost:Wait()
                                        tcon:Disconnect()
                                        cb.Text = not cb.Text:sub(1,1) == "#" and "#"..cb.Text or cb.Text
                                        local rgb = Color3.fromHex(cb.Text)

                                        default = rgb
                                        gbox.Color = Color3.fromHSV(select(1, rgb:ToHSV()), 1, 1)
                                        tb.Color = rgb
                                        pH, pY, pX = rgb:ToHSV()
                                        hdbox.Position = Vector2.new(hbox.Position.X - 1, Lerp(hbox.Position.Y, hbox.Position.Y + hbox.Size.Y, select(1, rgb:ToHSV())))
                                        shdbox.s.Position = hdbox.Position - Vector2.one
                                        pcall(callback, rgb)
                                        cb:Destroy()

                                        return
                                    end

                                    if IsInFrame(gbox, GetMousePosition()) then
                                        con = sv.RunService.Heartbeat:Connect(function()
                                            pX = math.clamp((GetMousePosition().X - gbox.Position.X) / gbox.Size.X, 0, 1)
                                            pY = math.clamp((GetMousePosition().Y - gbox.Position.Y) / gbox.Size.Y, 0, 1)

                                            default = Color3.fromHSV(pH, 1 - pY, 1 - pX)
                                            rgbt.Text = ("%i, %i, %i"):format(rgb255(default))
                                            hxt.Text = "#"..default:ToHex()
                                            tb.Color = default
                                            pcall(callback, default)
                                        end)

                                        table.insert(cons, con)

                                        return
                                    end

                                    if IsInFrame(hbox, GetMousePosition()) then
                                        con = sv.RunService.Heartbeat:Connect(function()
                                            pH = math.clamp((GetMousePosition().Y - hbox.Position.Y) / hbox.Size.Y, 0, 1)
                                            hdbox.Position = Vector2.new(hbox.Position.X - 1, math.clamp(GetMousePosition().Y, hbox.Position.Y, hbox.Position.Y + hbox.Size.Y))
                                            shdbox.s.Position = hdbox.Position - Vector2.one

                                            default = Color3.fromHSV(pH, 1 - pY, 1 - pX)
                                            tb.Color = default
                                            rgbt.Text = ("%i, %i, %i"):format(rgb255(default))
                                            hxt.Text = "#"..default:ToHex()
                                            gbox.Color = Color3.fromHSV(pH, 1, 1)

                                            pcall(callback, default)
                                        end)

                                        table.insert(cons, con)
                                    end
                                end
                            end)

                            cccon = sv.UserInputService.InputEnded:Connect(function(a2, b2)
                                if b2 then return end

                                if a2.UserInputType == Enum.UserInputType.MouseButton1 then
                                    pcall(con and con.Disconnect or function() end, con)
                                end
                            end)

                            table.insert(cons, cccon)
                            table.insert(cons, ccon)
                        end
                    end
                end))

                buttons += 1
            end

            function side:textbox(bname, backtext, callback)
                local bbox = GetGradientBox(buttons < 13)
                local tb = GetGradientBox(buttons < 13)
                local text = Draw "Text"
                local tbtext = Draw "Text"

                bbox.ZIndex = 3
                bbox.Position = wbox.Position + Vector2.new(5, 5 + (25 * buttons))
                bbox.Size = Vector2.new(570, 20)
                bbox.name = bname
                bbox.parent = wbox
                bbox.Opacity = si == 1 and i == 1 and 1 or 0

                text.ZIndex = 3
                text.Visible = buttons < 13
                text.Outline = true
                text.Color = Color3.new(1,1,1)
                text.Size = 18
                text.Font = Drawing.Fonts.Monospace
                text.Text = bname
                text.Position = bbox.Position + Vector2.new(4)
                text.parent = bbox
                text.name = bname
                text.Opacity = si == 1 and i == 1 and 1 or 0

                tb.Position = text.Position + Vector2.new(text.TextBounds.X + 10, 3)
                tb.Size = Vector2.new(bbox.Size.X - 9 - (text.TextBounds.X + 10), 14)
                tb.Color = Color3.new(.1, .1, .1)
                tb.ZIndex = 3
                tb.parent = bbox
                tb.name = "tb"
                tb.Opacity = si == 1 and i == 1 and 1 or 0

                tbtext.ZIndex = 3
                tbtext.Visible = buttons < 13
                tbtext.Outline = true
                tbtext.Color = Color3.new(.7, .7, .7)
                tbtext.Size = 16
                tbtext.Font = Drawing.Fonts.Monospace
                tbtext.Text = backtext
                tbtext.Position = tb.Position + Vector2.new(2, -2)
                tbtext.parent = tb
                tbtext.name = backtext
                tbtext.Opacity = si == 1 and i == 1 and 1 or 0

                table.foreach(Box(tb, 3), function(_,v)
                    v.Visible = buttons < 13
                    v.Opacity = si == 1 and i == 1 and 1 or 0
                end)

                table.foreach(Box(bbox, 3), function(_,v)
                    v.Visible = buttons < 13
                    v.Opacity = si == 1 and i == 1 and 1 or 0
                end)

                table.insert(cons, sv.UserInputService.InputBegan:Connect(function(a, b)
                    if b or listopen then return end

                    if a.UserInputType == Enum.UserInputType.MouseButton1 and bbox.Visible and bbox.Opacity ~= 0 then
                        if IsInFrame(tb, GetMousePosition()) then
                            local cb = Instance.new("TextBox", sv.CoreGui)
                            cb:CaptureFocus()
                            tbtext.Color = lib.AccentColor
                            tbtext.Text = ""
                            local tcon = cb.Changed:Connect(function()
                                tbtext.Text = cb.Text
                            end)

                            table.insert(cons, tcon)
                            cb.FocusLost:Wait()
                            tcon:Disconnect()
                            tbtext.Color = Color3.new(.7, .7, .7)

                            pcall(callback, cb.Text)
                            cb:Destroy()
                        end
                    end
                end))

                buttons += 1
            end

            function side:angler(bname, default, callback) -- THANK U FRICK FOR LITERALLY ALL OF THE MATH IN THIS (MY DUMBASS AINT KNOW TRIG)
                local bbox = GetGradientBox(buttons < 13)
                local tb = GetGradientBox(buttons < 13)
                local text = Draw "Text"
                local angle =  Draw "Text"
                local anglebox, abox, ccon, cccon, spinning, vpos, circle, amount
                local isn = default < 0

                local function Update(new)
                    local ts = GetTextSize(new, 18, Drawing.Fonts.Monospace).X
                    local ep = bbox.Position.X + bbox.Size.X - 11 - ts

                    tb.Position = Vector2.new(ep, bbox.Position.Y + 3)
                    tb.Size = Vector2.new(ts + 6, 14)
                    angle.Position = tb.Position + Vector2.new(2, -2)
                    anglebox.s.Position = tb.Position - Vector2.one
                    anglebox.s.Size = tb.Size + Vector2.one
                    angle.Text = new
                end

                bbox.ZIndex = 3
                bbox.Position = wbox.Position + Vector2.new(5, 5 + (25 * buttons))
                bbox.Size = Vector2.new(570, 20)
                bbox.name = bname
                bbox.parent = wbox
                bbox.Opacity = si == 1 and i == 1 and 1 or 0

                text.ZIndex = 3
                text.Visible = buttons < 13
                text.Outline = true
                text.Color = Color3.new(1,1,1)
                text.Size = 18
                text.Font = Drawing.Fonts.Monospace
                text.Text = bname
                text.Position = bbox.Position + Vector2.new(4)
                text.parent = bbox
                text.name = bname
                text.Opacity = si == 1 and i == 1 and 1 or 0

                tb.Position = bbox.Position + bbox.Size - Vector2.new(20, 17)
                tb.Size = Vector2.new(14, 14)
                tb.Color = Color3.new(.1, .1, .1)
                tb.ZIndex = 3
                tb.parent = bbox
                tb.name = "tb"
                tb.Opacity = si == 1 and i == 1 and 1 or 0

                angle.ZIndex = 3
                angle.Visible = buttons < 13
                angle.Outline = true
                angle.Color = Color3.new(1,1,1)
                angle.Size = 18
                angle.Font = Drawing.Fonts.Monospace
                angle.Position = tb.Position + Vector2.new(2, -2)
                angle.parent = bbox
                angle.name = "key"
                angle.Opacity = si == 1 and i == 1 and 1 or 0

                anglebox = Box(tb, 3)
                table.foreach(anglebox, function(_,v)
                    v.Visible = buttons < 13
                    v.Opacity = si == 1 and i == 1 and 1 or 0
                end)

                table.foreach(Box(bbox, 3), function(_,v)
                    v.Visible = buttons < 13
                    v.Opacity = si == 1 and i == 1 and 1 or 0
                end)

                do
                    local ang = 0

                    table.insert(cons, sv.RunService.Heartbeat:Connect(function()
                        if ang > 360 then
                            ang = 0
                        end
                        ang += .2
                        local na = tonumber(string.format("%.2f", ang))

                        if spinning then
                            Update(tostring(na).."°")
                            pcall(callback, ang)
                            vpos.Position = circle.Position + Vector2.new(math.sin(math.rad(na)) * 73, math.cos(math.rad(na)) * 73)
                            amount.Text = tostring(na).."°"
                        end
                    end))
                end

                table.insert(cons, sv.UserInputService.InputBegan:Connect(function(a, b)
                    if b or listopen then return end

                    if abox and IsInFrame(bbox, GetMousePosition()) then
                        abox.obj:Remove()
                        table.foreach(abox:children(true), function(_, v)
                            v.obj:Remove()
                        end)
                        abox, circle, amount, vpos = nil, nil, nil, nil
                        ccon:Disconnect()
                        cccon:Disconnect()

                        return
                    end

                    if a.UserInputType == Enum.UserInputType.MouseButton1 and bbox.Visible and bbox.Opacity ~= 0 and not abox then
                        if IsInFrame(bbox, GetMousePosition()) then
                            abox = GetGradientBox(true)
                            local a2box = GetGradientBox(true)
                            local title = Draw "Text"
                            circle = Draw "Circle"
                            vpos = Draw "Square"
                            local slide = Draw "Square"
                            amount = Draw "Text"
                            local con
                            table.insert(accents, slide)
                            table.insert(accents, circle)

                            abox.Position = tb.Position + tb.Size + Vector2.new(40)
                            abox.Size = Vector2.new(200, 250)
                            abox.name = "abox"
                            abox.draggable = true
                            abox.ZIndex = 7

                            title.ZIndex = 8
                            title.Visible = true
                            title.Outline = true
                            title.Color = Color3.new(1,1,1)
                            title.Size = 18
                            title.Font = Drawing.Fonts.Monospace
                            title.Text = bname
                            title.Position = abox.Position + Vector2.new(4)
                            title.parent = abox
                            title.name = "title"

                            a2box.Position = abox.Position + Vector2.new(5, 26)
                            a2box.Size = Vector2.new(190, 190)
                            a2box.name = "abox"
                            a2box.ZIndex = 8
                            a2box.parent = abox

                            circle.ZIndex = 9
                            circle.Position = a2box.Position + Vector2.new(95, 90)
                            circle.Radius = 75
                            circle.Visible = true
                            circle.Color = lib.AccentColor
                            circle.Thickness = 5
                            circle.parent = a2box
                            circle.NumSides = 9e9
                            circle.name = "rad"

                            vpos.name = "vpos"
                            vpos.parent = circle
                            vpos.ZIndex = 11
                            vpos.Size = Vector2.new(5, 5)
                            vpos.Position = circle.Position + Vector2.new(math.sin(math.rad(default)) * 73, math.cos(math.rad(default)) * 73)
                            vpos.Visible = true
                            vpos.Filled = true

                            slide.Position = a2box.Position + Vector2.new(5, 178)
                            slide.parent = a2box
                            slide.Visible = true
                            slide.Size = Vector2.new(180, 7)
                            slide.Color = lib.AccentColor
                            slide.ZIndex = 9
                            slide.Filled = true

                            amount.ZIndex = 9
                            amount.Visible = true
                            amount.Outline = true
                            amount.Color = Color3.new(1,1,1)
                            amount.Size = 18
                            amount.Center = true
                            amount.Font = Drawing.Fonts.Monospace
                            amount.Text = tostring(default).."°"
                            amount.Position = circle.Position - Vector2.new(0, 9)
                            amount.parent = circle
                            amount.name = "amount"

                            Box(slide, 9)

                            local neg = GetGradientBox(true)
                            local nt = Draw "Text"

                            neg.name = "neg"
                            neg.parent = abox
                            neg.ZIndex = 8
                            neg.Position = abox.Position + Vector2.new(5, 225)
                            neg.Size = Vector2.new(20, 20)
                            neg.Color = Color3.new(.1, .1, .1)

                            nt.ZIndex = 9
                            nt.Visible = true
                            nt.Outline = true
                            nt.Color = Color3.new(1,1,1)
                            nt.Size = 14
                            nt.Font = Drawing.Fonts.Monospace
                            nt.Text = "+-"
                            nt.Position = neg.Position + Vector2.new(2, 2)
                            nt.parent = neg
                            nt.name = "nt"

                            local spin = GetGradientBox(true)
                            local st = Draw "Text"

                            spin.name = "spin"
                            spin.parent = abox
                            spin.ZIndex = 8
                            spin.Position = abox.Position + Vector2.new(30, 225)
                            spin.Size = Vector2.new(20, 20)
                            spin.Color = Color3.new(.1, .1, .1)

                            st.ZIndex = 9
                            st.Visible = true
                            st.Outline = true
                            st.Color = Color3.new(1,1,1)
                            st.Size = 14
                            st.Font = Drawing.Fonts.Monospace
                            st.Text = "o"
                            st.Position = spin.Position + Vector2.new(6, 2)
                            st.parent = spin
                            st.name = "st"

                            Box(spin, 8)
                            Box(neg, 8)

                            ccon = sv.UserInputService.InputBegan:Connect(function(a2, b2)
                                if b2 then return end

                                if a2.UserInputType == Enum.UserInputType.MouseButton1 then
                                    if IsInFrame(neg, GetMousePosition()) then
                                        isn = not isn
                                        amount.Text = tostring(-default).."°"
                                        Update(tostring(-default).."°")
                                        pcall(callback, -default)

                                        return
                                    end

                                    if IsInFrame(spin, GetMousePosition()) then
                                        spinning = not spinning

                                        if not spinning then
                                            amount.Text = tostring(default).."°"
                                            Update(tostring(default).."°")
                                            pcall(callback, default)
                                        end

                                        return
                                    end

                                    local mag = IsInCircle(circle, GetMousePosition())

                                    if mag then
                                        con = sv.RunService.Heartbeat:Connect(function()
                                            local pos = GetMousePosition()
                                            local dir = (pos - circle.Position).Unit
                                            local ang = math.atan2(dir.Y, dir.X) % (math.pi * 2)
                                            vpos.Position = circle.Position + Vector2.new(math.cos(ang) * 73, math.sin(ang) * 73)
                                            ang *= (isn and -1 or 1)
                                            amount.Text = tostring(math.round(math.deg(ang))).."°"
                                            default = ang
                                            pcall(callback, ang)
                                            Update(tostring(math.round(math.deg(ang))).."°")
                                        end)

                                        table.insert(cons, con)
                                    end
                                end
                            end)

                            cccon = sv.UserInputService.InputEnded:Connect(function(a2, b2)
                                if b2 then return end

                                if a2.UserInputType == Enum.UserInputType.MouseButton1 then
                                    pcall(con and con.Disconnect or function() end, con)
                                end
                            end)

                            table.insert(cons, ccon)
                            table.insert(cons, cccon)

                            Box(abox, 7, true)
                            Box(a2box, 8, true)
                        end
                    end
                end))

                Update(tostring(default).."°")
                buttons += 1
            end

            return side
        end

        return tab
    end

    function library:accent(newcolor)
        lib.AccentColor = newcolor

        for _,v in accents do
            v.Color = newcolor
        end
    end

    SaveOps()

    return library
end

return lib

--[==[

    local binds = lib:bindlist()
    local bind = binds:add("Bind down", Enum.KeyCode.X, true, print)
    binds:add("Bind hold", Enum.KeyCode.Z, false, print)

    local loader = lib:loader("Professional Generation")
    loader:set "Loading roblox hack"

    lib:note("Question (answer else lib doesnt unload)", {
        Question = true,
        Options = {
            "Yes",
            "Yes2"
        },
        Time = 9
    })
    lib:note("ERROR! BALCK PEROSN", {
        Error = true,
        Time = 5
    })
    lib:note("Professiona Generation", {
        Time = 2
    })

    local j = lib:new("Professional Generation", syn.request({Url = "https://cdn.discordapp.com/attachments/907173542972502072/1081826251758653540/1f602.png"}).Body) -- make library -> table (2nd arg is optional for a logo)
    local b = j:tab"Main tab" -- new tab with name -> table
    local t = b:side "side tab" -- new side tab with name -> table
    t:button("button", function() -- name, callback
        print'a'
    end)
    t:toggle("toggle true", true, print) -- name, default, callback -> boolean
    t:toggle("toggle false", false, print) -- name, default, callback -> boolean
    t:slider("slider", 0, 100, 50, true, print) -- name, minimum, maximum, default, precise, callback -> number
    t:bind("bind", Enum.KeyCode.LeftShift, print) -- name, default, callback -> EnumItem
    t:list("list", {'real', 'and', 'true'}, print) -- name, list, callback -> any
    t:colorpicker('colorpicker', lib.AccentColor, function(color) -- name, default, callback -> Color3
        j:accent(color)
    end)
    t:textbox("textbox", "text", print) -- name, background text, callback -> string
    t:angler("angler", 90, print) -- name, default angle, callback -> number (You need to manually convert it to an angle through math.rad)
    b:side "stab2":button("ninjas", print)
    j:tab"MONEY HACK"

    task.wait(10)
    table.foreach(cons, function(_, v) -- Disconnecting all of these kills the library
        v:Disconnect()
    end)
]==]
