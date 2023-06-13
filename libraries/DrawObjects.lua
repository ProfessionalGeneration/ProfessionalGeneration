local objects = {}
local Get, Directory, File = loadfile("Progen/libraries/FileSystem.lua")()
local Draw = Get:"libraries":Get"Draw":Load()
local Gradient = syn.crypt.base64.decode(Get:"data":Get"Gradient":Read())

objects.Outline = function(frame, props)
    local lines = {
        Top1 = Draw:new("Line", frame),
        Top2 = Draw:new("Line", frame),
        Right = Draw:new("Line", frame),
        Bottom1 = Draw:new("Line", frame),
        Bottom2 = Draw:new("Line", frame),
        Left = Draw:new("Line", frame),
    }

    for prop, val in props do
        for _, line in lines do
            v[prop] = val
        end
    end

    Top1.From = Vector2.new(-1, -1)
    Top1.To = Vector2.new((frame.Size.X / 2) - 1, -1)
    Top2.From = Vector2.new((frame.Size.X / 2) + 1, -1)
    Top2.To = Vector2.new(frame.Size.X + 1, -1)

    Right.From = Vector2.new(frame.Size.X, -1)
    Right.To = Vector2.new(frame.Size.X, frame.Size.Y + 1)

    Bottom1.From = Vector2.new(-1, frame.Size.Y + 1)
    Bottom1.To = Vector2.new((frame.Size.X / 2) - 1, frame.Size.Y + 1)
    Bottom2.From = Vector2.new((frame.Size.X / 2) + 1, frame.Size.Y + 1)
    Bottom2.To = Vector2.new(frame.Size.X + 1, frame.Size.Y + 1)

    Left.From = Vector2.new(-1, -1)
    Left.To = Vector2.new(-1, frame.Size.Y + 1)

    function lines:Update(props)
        lines.Top1.From = Vector2.new(-1, -1)
        lines.Top1.To = Vector2.new((frame.Size.X / 2) - 1, -1)
        lines.Top2.From = Vector2.new((frame.Size.X / 2) + 1, -1)
        lines.Top2.To = Vector2.new(frame.Size.X + 1, -1)

        lines.Right.From = Vector2.new(frame.Size.X, -1)
        lines.Right.To = Vector2.new(frame.Size.X, frame.Size.Y + 1)

        lines.Bottom1.From = Vector2.new(-1, frame.Size.Y + 1)
        lines.Bottom1.To = Vector2.new((frame.Size.X / 2) - 1, frame.Size.Y + 1)
        lines.Bottom2.From = Vector2.new((frame.Size.X / 2) + 1, frame.Size.Y + 1)
        lines.Bottom2.To = Vector2.new(frame.Size.X + 1, frame.Size.Y + 1)

        lines.Left.From = Vector2.new(-1, -1)
        lines.Left.To = Vector2.new(-1, frame.Size.Y + 1)

        for prop, val in props or {} do
            for _, line in lines do
                v[prop] = val
            end
        end
    end

    return lines
end

objects.Frame = function(Properties)
    local obj = Draw:new "Square"

    for i,v in Properties do
        obj[i] = v
    end

    return obj
end

objects.GradientFrame = function(Properties)
    local obj = Draw:new "Image"
    obj.__object.Data = Gradient

    for i,v in Properties do
        obj[i] = v
    end

    return obj
end

objects.Line = function(Properties)
    local obj = Draw:new "Line"

    for i,v in Properties do
        obj[i] = v
    end

    return obj
end

objects.Circle = function(Properties)
    local obj = Draw:new "Circle"

    for i,v in Properties do
        obj[i] = v
    end

    return obj
end

objects.Label = function(Properties)
    local obj = Draw:new "Text"

    for i,v in Properties do
        obj[i] = v
    end

    return obj
end