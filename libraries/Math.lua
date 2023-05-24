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
        task.spawn(callback, start)
    end

    Services.Run.RenderStepped:wait()
    callback(_end)
end

Math.Lerp = function(a, b, c)
    return a + c * (b - a)
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