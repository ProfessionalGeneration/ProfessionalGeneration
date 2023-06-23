local Get, File, Directory = ...
local Objects, Math, Easing, Services = Get:Get"libraries":Get"DrawObjects":Load(), Get:Get"libraries":Get"Math":Load(), Get:Get"libraries":Get"Easing":Load(), Get:Get"libraries":Get"Services":Load()
local Notes, current = {}, {}

local function Show(box, outlines, size)
    table.insert(box, current)
    Math.DeltaIter(0, 1, 60, function(inc)
        inc = Easing.Out.Quad(inc)

        for i,v in box:Children(true) do
            v.Opacity = inc
        end

        box.Opacity = inc
        box.Size = Vector2.new(Math.Lerp(20, size, inc), box.Size.Y)
        box.Position = Vector2.new(Math.Lerp(10, 50, inc), box.Position.Y)
        outlines:Update()
    end)
end

local function GetPosXByOptions(boxes)
    local pos = 0

    for i,v in boxes do
        pos += v.Size.X
    end

    return pos + (#boxes * 5)
end

local function GetNoteY()
    local pos = 0

    for i,v in current do
        pos += v.Size.Y
    end

    return pos + (#current * 5)
end

local function Hide(box)
    table.remove(current, table.find(current, box))
    local old = {}
    for i,v in current do
        old[v] = v.Position.Y
    end

    task.spawn(Math.DeltaIter, 1, 0, 20, function(inc)
        inc = Easing.Out.Quad(inc)

        for i,v in box:Children(true) do
            v.Opacity = inc
        end

        for i,v in current do
            if v.__object.Position.Y > box.__object.Position.Y then
                v.Position = Vector2.new(v.Position.X, Math.Lerp(old[v] - 25, old[v], inc))
            end
        end
    end)
end

local function GetDefaultNote(settings)
    local Box = Objects.Frame {
        Position = Vector2.new(10, 40 + GetNoteY()),
        Size = Vector2.new(20, 20),
        Color = Color3.new(.15, .15, .15),
        Opacity = 0,
    }
    local Text = Objects.Text {
        Position = Vector2.new(2, 2),
        Parent = Box,
        Size = 15,
        Color = Color3.new(1,1,1),
        Outlined = true,
        Text = settings.Text
    }
    local Outlines = Objects.Outline(Box)

    return Box, Text, Outlines
end

function Notes:Notify(settings)
    local sets = {
        Time = 5,
        Error = false,
        Text = "Note"
    }

    for i,v in settings do
        sets[i] = v
    end

    local finalsize = Math.GetTextSize(settings.Text, 16, Drawing.Fonts["Monospace"]).X + 8
    local Box, Text, Outlines = GetDefaultNote(settings)

    local Timer = Objects.Line {
        From = Vector2.new(0, Box.Size.Y - 2),
        To = Vector2.new(0, Box.Size.Y - 2),
        Parent = Box,
        Opacity = 0,
        Thickness = 2
    }
    local stop

    Show(Box, Outlines, finalsize)

    local function StartTimer()
        local i = 0

        while not stop do
            if i >= sets.Time then break end
            i += Services.Run.RenderStepped:wait()
            Timer.To = Vector2.new(Math.Lerp(0, Box.Size.Y - 2, i), 23)
        end

        if not stop then Hide(Box) end
    end

    task.spawn(StartTimer)

    Box.MouseEnter:Connect(function()
        stop = true
    end)

    Box.MouseLeave:Connect(function()
        stop = false
        StartTimer()
    end)
end

function Notes:Question(settings)
    local sets = {
        Text = "Note",
        Options = {
            "Yes",
            "No"
        }
    }

    for i,v in settings do
        sets[i] = v
    end

    local finalsize = Math.GetTextSize(settings.Text, 16, Drawing.Fonts["Monospace"]).X + 8
    local Box, Text, Outlines = GetDefaultNote(settings)
    local answered = Instance.new "BindableEvent"
    local options = {}

    for i,v in settings.Options do
        local textsize = Math.GetTextSize(v, 14, Drawing.Fonts["Monospace"]).X + 2

        local box = Objects.Frame {
            Position = Vector2.new(GetPosXByOptions(options), 30),
            Parent = Box,
            Size = Vector2.new(textsize, 12),
            Color = Color3.new(.15, .15, .15),
            Opacity = 0,
            Active = true
        }

        local text = Objects.Label {
            Position = Vector2.one,
            Size = 14,
            Parent = box,
            Text = v,
            Opacity = 0,
            Outlined = true,
            Color = Color3.new(1,1,1),
        }
        local outlime = Objects.Outline(text)
        box.Changed:Connect(outlime.Update)

        box.Button1Down:Once(function()
            answered:Fire(v)
        end)

        options[v] = box
    end

    Show(Box, Outlines, finalsize)

    answered.Event:Once(function()
        Hide(Box)
    end)

    return {
        ["Answered"] = answered.Event,
    }
end

function Notes:Yield(settings)
    local sets = {
        Text = "Note",
    }

    for i,v in settings do
        sets[i] = v
    end

    local finalsize = Math.GetTextSize(settings.Text, 16, Drawing.Fonts["Monospace"]).X + 8
    local Box = GetDefaultNote(settings)
end

return Notes
