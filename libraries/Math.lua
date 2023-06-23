local Math = {}
local Get, Directory, File = loadfile("Progen/libraries/FileSystem.lua")()
local Services = Get:Get"libraries":Get"Services":Load()
local cam = cloneref(cloneref(workspace).CurrentCamera)
local text = Drawing.new "Text"
text.Visible = false

Math.DeltaIter = function(start, _end, mult, callback)
    local up
    local Break

    local function Spawn()
        if callback(start) then
            Break = true
        end
    end

    if _end > start then
        up = true
    end

    while not Break do
        if up and start > _end then break end
        if not up and _end > start then break end

        start += Services.Run.RenderStepped:wait() * (up and mult or -mult)
        task.spawn(Spawn)
    end
    if Break then return end

    Services.Run.RenderStepped:Once(Spawn)
end

Math.Curve = function(start, _end, points, _i)
    for i = 1, #points do
        start = start:lerp(points[i], _i)
    end

    return start:lerp(_end, _i)
end

Math.LerpDeltaIter = function(start, _end, speed, callback)
    local percent = 0

    while percent < 1 do
        percent += Services.Run.RenderStepped:wait() * speed

        callback(Math.Lerp(start, _end, percent))
    end

    callback(_end)
end

Math.GetTextSize = function(text, size, font)
    text.Text, text.Size, text.Font = text, size, font
    return text.TextBounds
end

Math.TextWrap = function(text, textsize, size)
    local lines = {}
    local cx = 0
    local start = 1
    local i = 1

    text:gsub(".", function(v)
        local size = Math.GetTextSize(text, textsize, Drawing.Fonts.Monospace).X
        i += 1

        if size + cx < x then
            cx += size
        else
            table.insert(lines, text:sub(start, i))
            start = i + 1
            cx = 0
        end
    end)

    return table.concat(lines, "\n")
end

Math.Lerp = function(a, b, c)
    return a + c * (b - a)
end

Math.ToV2 = function(vec)
    return Vector2.new(vec.X, vec.Y)
end

Math.Point = function(part)
    return cam:WorldToViewportPoint(part:getPivot().p)
end

return Math
