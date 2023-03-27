local sv = {
    uis = cloneref(game:service "UserInputService"),
    core = cloneref(game:service "CoreGui"),
    run = cloneref(game:service "RunService"),
    ts = cloneref(game:service "TweenService")
}

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

local function TextWrapY(text, textsize, x)
    local lines = {}
    local cx = 0
    local start = 1
    local i = 1

    text:gsub(".", function(v)
        local size = GetTextSize(text, textsize, Drawing.Fonts.Monospace).X
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

local function DeltaIter(start, _end, mult, callback)
    local up
    local rstep = sv.run.RenderStepped

    if _end > start then
        up = true
    end

    while true do
        if up and start > _end then break end
        if not up and _end > start then break end

        start += rstep:wait() * (up and 1 or -1) * mult
        task.spawn(callback, start)
    end

    rstep:wait()
    callback(_end)
end

local function IsInFrame(frame)
    local pos = frame.ScreenPos
    local mp = sv.uis:GetMouseLocation()
    local size = typeof(frame.Size) == "Vector2" and frame.Size or frame.TextBounds

    return pos.Y < mp.Y and mp.Y < pos.Y + size.Y and pos.X < mp.X and mp.X < pos.X + size.X
end

local funcs = {
    ["Children"] = function(self, recursive)
        local children = {}

        for _,v in self._children do
            table.insert(children, v)

            if recursive then
                for __,obj in v:children(true) do
                    table.insert(children, obj)
                end
            end
        end

        return children
    end,
    ["Destroy"] = function(self)
        self._obj:Destroy()

        for _,child in self:children(true) do
            child._obj:Destroy()
        end
    end,
    ["FindChild"] = function(self, name, recursive)
        for i,v in self:children(recursive) do
            if v.Name == name then
                return v
            end
        end
    end,
    ["Tween"] = function(self, tweeninfo, properties)
        local startprops = {}

        for i in properties do
            startprops[i] = self[i]
        end

        if tweeninfo.DelayTime or tweeninfo.delayTime then -- no fucking clue why roblox has this they clearly havent heard of "task.delay"
            task.wait(tweeninfo.DelayTime or tweeninfo.delayTime)
        end

        for i = 0, tweeninfo.RepeatCount or tweeninfo.repeatCount or 1 do
            DeltaIter(0, 1, 1 / (tweeninfo.Time or tweeninfo.time or 1), function(inc)
                local eased = sv.ts:GetValue(inc, tweeninfo.EasingStyle or tweeninfo.easingStyle or Enum.EasingStyle.Quad, tweeninfo.EasingDirection or tweeninfo.easingDirection or Enum.EasingDirection.Out)

                for _, v in properties do
                    self[_] = startprops[_]:lerp(v, eased)
                end
            end)

            if tweeninfo.Reverses then
                DeltaIter(1, 0, 1 / (tweeninfo.Time or tweeninfo.time or 1), function(inc)
                    local eased = sv.ts:GetValue(inc, tweeninfo.EasingStyle or tweeninfo.easingStyle or Enum.EasingStyle.Quad, tweeninfo.EasingDirection or tweeninfo.easingDirection or Enum.EasingDirection.Out)

                    for _, v in properties do
                        self[_] = startprops[_]:lerp(v, eased)
                    end
                end)
            end
        end
    end,
    ["IsInFrame"] = function(self)
        return IsInFrame(self._obj)
    end
}

local PDraw = function(Type, ...)
    assert(getgenv()[Type.."Dynamic"], "fucking retard that doesnt exist")
    local obj = getgenv()[Type.."Dynamic"].new(...)
    local tbl = {_children = {}, _obj = obj, Parent = nil, Name = Type}

    for i,v in funcs do
        tbl[i] = v
        tbl[i:lower()] = v
    end

    return setmetatable(tbl, {
        __newindex = function(_, k, v)
            if obj[k] then
                obj[k] = v
            end

            if obj[k] then
                if k == "Visible" then
                    for i,x in tbl:children(true) do
                        x._obj.Visible = v and obj.Visible
                    end
                end
            end

            rawset(tbl, k, v)
        end,
        __index = function(_, v)
            return tbl._obj[v] or tbl._children[v]
        end
    })
end

local guipoint = PointOffset.new(Point2D.new(UDim2.new(.5, 0, .5, 0)), Vector2.new(200, 200))
local point = PDraw("Text", guipoint)
point.Visible = true
point.Text = "real"
point.Outlined = true
point.OutlineThickness = 1
point.OutlineOpacity = 1
point.Color = Color3.new(1,1,1)
point.Size = 20
for i = 1, .5, -.005 do
guipoint.Point = UDim2.new(.5, 0, i, 0)
task.wait()
end
task.wait(5)

return PDraw