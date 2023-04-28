local Services = {
    Input = cloneref(game:service "UserInputService"),
    Core = cloneref(game:service "CoreGui"),
    Run = cloneref(game:service "RunService"),
    Tween = cloneref(game:service "TweenService")
}

local function DeltaIter(start, _end, mult, callback)
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

    rstep:wait()
    callback(_end)
end

local Draw = {}
Draw.__index = Draw

function Draw.Children(self, recursive)
    local children = {}
    
    for property, child in self do
        if type(child) == "table" and property ~= "Parent" then
            table.insert(children, child)

            if recursive then
                for _, descendant in child:Children(true) do
                    table.insert(children, descendant)
                end
            end
        end
    end

    return children
end

function Draw.Tween(self, tweeninfo, properties)
    local startprops = {}

    for i in properties do
        startprops[i] = self[i]
    end

    if tweeninfo.DelayTime or tweeninfo.delayTime then -- no fucking clue why roblox has this they clearly havent heard of "task.delay"
        task.wait(tweeninfo.DelayTime or tweeninfo.delayTime)
    end

    for i = 0, tweeninfo.RepeatCount or tweeninfo.repeatCount or 1 do
        DeltaIter(0, 1, 1 / (tweeninfo.Time or tweeninfo.time or 1), function(inc)
            local eased = Services.Tween:GetValue(inc, tweeninfo.EasingStyle or tweeninfo.easingStyle or Enum.EasingStyle.Quad, tweeninfo.EasingDirection or tweeninfo.easingDirection or Enum.EasingDirection.Out)

            for _, v in properties do
                self[_] = startprops[_]:lerp(v, eased)
            end
        end)

        if tweeninfo.Reverses then
            DeltaIter(1, 0, 1 / (tweeninfo.Time or tweeninfo.time or 1), function(inc)
                local eased = Services.Tween:GetValue(inc, tweeninfo.EasingStyle or tweeninfo.easingStyle or Enum.EasingStyle.Quad, tweeninfo.EasingDirection or tweeninfo.easingDirection or Enum.EasingDirection.Out)

                for _, v in properties do
                    self[_] = startprops[_]:lerp(v, eased)
                end
            end)
        end
    end
end

function Draw.new(Type)
    local obj = Drawing.new(Type)
    local properties = {
        Draggable = false,
        Parent = nil,
        TheThugShaker = nil
    }

end