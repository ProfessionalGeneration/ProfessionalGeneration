local Math = {}

Math.DeltaIter = function(start, _end, mult, callback)
    local up

    if _end > start then
        up = true
    end

    while true do
        if up and start > _end then break end
        if not up and _end > start then break end

        start += Services.Run.RenderStepped:wait() * (up and mult or -mult)
        if select(coroutine.resume(coroutine.create(callback), inc), 2) then break end
    end

    Services.Run.RenderStepped:wait()
    callback(_end)
end

Math.Lerp = function(a, b, c)
    return a + c * (b - a)
end

Math.LerpDeltaIter = function(start, _end, speed, callback)
    return Math.DeltaIter(0, 1, speed, function(inc)
        callback(Math.Lerp(start, _end, inc))
    end)
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

Math.GetTextSize = function(text, size, font)
    local t = Drawing.new "Text"
    t.Text, t.Size, t.Font = text, size, font
    return t.TextBounds
end

Math.ToV2 = function(vec)
    return Vector2.new(vec.X, vec.Y)
end

Math.Point = function(part)
    return cloneref(cloneref(workspace).CurrentCamera):WorldToViewportPoint(part:getPivot().p)
end

return Math