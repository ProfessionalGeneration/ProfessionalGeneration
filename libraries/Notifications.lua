local Notes = {}

local function Show(box, outlines, size)
    Math.DeltaIter(0, 1, 60, function(inc)
        inc = Easing.Out.Quad(inc)

        for i,v in Box:Children(true) do
            v.Opacity = inc
        end

        Box.Opacity = inc
        Box.Size = Vector2.new(Lerp(20, finalsize, inc), 20)
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
    local Outlines = Objects.Outline(Box)
    Show(Box, Outlines, Size)


end

return Notes