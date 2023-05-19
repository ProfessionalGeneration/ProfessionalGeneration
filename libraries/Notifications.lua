local Notes = {}
-- being so deadass rn snuffles on twitter so fucking CUTE

local function Show(box, outlines, size)
    Math.DeltaIter(0, 1, 60, function(inc)
        inc = Easing.Out.Quad(inc)

        for i,v in Box:Children(true) do
            v.Opacity = inc
        end

        Box.Opacity = inc
        Box.Size = Vector2.new(Math.Lerp(20, finalsize, inc), 20)
        Box.Position = Vector2.new(Math.Lerp(10, 50, inc), Box.Position.Y)
        outlines:Update()
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
    local finalsize = GetTextSize(settings.Text, 16, Drawing.Fonts["Monospace"]).X + 8
    local Box = Objects.Frame {
        Position = Vector2.new(10, 40 + (25 * (#Notes - 3))),
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
    Show(Box, Outlines, Size)


end

return Notes