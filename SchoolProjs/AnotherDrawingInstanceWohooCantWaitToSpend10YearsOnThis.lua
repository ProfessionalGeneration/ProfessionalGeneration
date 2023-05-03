-- commit info goes hard frfr :3
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

local DraggableObjs = {}

local Draw = {}
Draw.__index = function(self, key)
    return self.__properties[key] or self.__children[key] or error(`{key} is not a valid member of {self.Name}`)
end
Draw.__newindex = function(self, key, value)
    if key == "Parent" then
        if value then
            table.insert(self, value.__children)

            Draw.__newindex(self, "Position", self.Position)
        end

        if self.__parent then
            table.remove(self.__parent, table.find(self.__parent, self))
        end

        self.__parent = value
    end

    if key == "Draggable" then
        table[value and "insert" or "remove"](DraggableObjs, value and self or table.find(DraggableObjs, self))
    end

    if key == "Position" then
        if self.__properties.Parent then
            local pos, parent = Vector2.zero, self.__properties.Parent

            while true do
                parent = parent.__properties.Parent

                if parent then
                    pos += parent.__properties.Position
                else
                    break
                end
            end
        end

        for _, descendant in self:Children(true) do
            descendant.__object.Position = descendant.__object.Position - (self.__object.Position - descendant.__object.Position)
        end

        self.__properties[key] = value

        return
    end

    if self.__object[key] then
        self.__object[key] = value
    end

    self.__properties[key] = value
end
Draw.__tostring = function(self)
    return self.__properties.Name
end

function Draw.Children(self, recursive)
    local children = {}
    
    for property, child in self.__children do
        table.insert(children, child)

        if recursive then
            for _, descendant in child.__children do
                table.insert(children, descendant)
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

function Draw.Destroy(self)
    self.Object:Destroy()

    for i,v in self:Children(true) do
        v.Object:Destroy()
    end
end

function Draw.Find(self, name, recursive)
    for i,v in self.__children do
        if v.Name == name then
            return v
        end
    end

    if recursive then
        for i,v in self:Children(true) do
            if v.Name == name then
                return v
            end
        end
    end
end

function Draw.ChildrenOfClass(self, type, recursive)
    for property, child in self.__children do
        if self.__properties.Class ~= type then continue end
        table.insert(children, child)

        if recursive then
            for _, descendant in child.__children do
                if self.__properties.Class ~= type then continue end
                table.insert(children, descendant)
            end
        end
    end
end

function Draw.FindOfClass(self, type, recursive)
    for i,v in self.__children do
        if v.Class == type then
            return v
        end
    end

    if recursive then
        for i,v in self:Children(true) do
            if v.Class == type then
                return v
            end
        end
    end
end

function Draw.new(Type, parent)
    local obj = Drawing.new(Type)
    local properties = {
        Draggable = false,
        Name = Type,
        Class = Type,
        Parent = parent,
    }

    return setmetatable({__properties = {}, __children = {}, __object = obj}, Draw)
end

return Draw