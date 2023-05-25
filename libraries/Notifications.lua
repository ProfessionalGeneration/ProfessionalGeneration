local Notes = {}
local current = {}

local function Show(box, outlines, size)
    table.insert(box, current)
    Math.DeltaIter(0, 1, 60, function(inc)
        inc = Easing.Out.Quad(inc)

        for i,v in Box:Children(true) do
            v.Opacity = inc
        end

        Box.Opacity = inc
        Box.Size = Vector2.new(Math.Lerp(20, size, inc), 20)
        Box.Position = Vector2.new(Math.Lerp(10, 50, inc), Box.Position.Y)
        outlines:Update()
    end)
end

local function GetPosXByOptions(boxes)
    local pos = 0

    for i,v in boxes do
        pos += v.Size.X
    end

    return pos
end

local function GetNoteY()
    local pos = 0

    for i,v in current do
        pos += v.Size.Y
    end
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
                v.Position = Vector2.new(v.Position.X, Math.Lerp(old[v] - 25, old[v] inc))
            end
        end
    end)
end

function Notes:Note(settings)
    local sets = {
        Time = 5,
        Error = false,
        Text = "Note"
    }

    for i,v in settings do
        sets[i] = v
    end
end

do
    local finalsize = Math.GetTextSize(settings.Text, 16, Drawing.Fonts["Monospace"]).X + 8
    local Box = Objects.Frame {
        Position = Vector2.new(10, 40 + GetNoteY()),
        Size = Vector2.new(23, 23),
        Color = Color3.new(.15, .15, .15),
        Opacity = 0,
    }
    local Text = Objects.Label {
        Position = Vector2.new(2, 2),
        Parent = Box,
        Size = 16,
        Color = Color3.new(1,1,1),
        Outlined = true,
        Text = settings.Text,
        Opacity = 0
    }
    local Timer = Objects.Line {
        From = Vector2.zero,
        To = Vector2.zero,
        Parent = Box,
        Opacity = 0,
        Thickness = 2        
    }
    local Outlines = Objects.Outline(Box)
    local stop

    local function StartTimer()
        local i = 0

        while not stop do
            if i >= sets.Time then break end
            i += Services.Run.RenderStepped:wait()
            timer.To = Vector2.new(Math.Lerp(0, box.Size, i), 23)
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

do
    local finalsize = Math.GetTextSize(settings.Text, 16, Drawing.Fonts["Monospace"]).X + 8
    local answered = Instance.new "BindableEvent"
    local options = {}
    local Box = Objects.Frame {
        Position = Vector2.new(10, 40 + (25 * (#current - 1))),
        Size = Vector2.new(20, 20),
        Color = Color3.new(.15, .15, .15),
        Opacity = 0,
    }
    local Text = Objects.Label {
        Position = Vector2.new(2, 2),
        Parent = Box,
        Size = 16,
        Color = Color3.new(1,1,1),
        Outlined = true,
        Text = settings.Text,
        Opacity = 0
    }
    local Outlines = Objects.Outline(Box)
    
    for i,v in settings.Options do
        local textsize = Math.GetTextSize(v, 14, Drawing.Fonts["Monospace"]).X + 2
            
        local box = Objects.Frame {
            Position = Vector2.new(GetPosXByOptions(options) + (#options * 5), 30),
            Parent = Box,
            Size = Vector2.new(textsize),
            Color = Color3.new(.15, .15, .15),
            Opacity = 0,
            Active = true
        }

        local text = Objects.Label {
            Position = Vector2.one,
            Size = 14,
            Parent = box,
            Size = Vector2.new(textsize, 12),
            Text = v,
            Opacity = 0,
            Outlined = true,
            Color = Color3.new(1,1,1),
        }

        box.Button1Down:Connect(function()
            Answered:Fire(v)
        end)
    end

    Show(Box, Outlines, Size)

    Answered.Event:Once(function()
        Hide(Box)
    end)

    return {
        ["Answered"] = Answered.Event,
    }
end

return Notes