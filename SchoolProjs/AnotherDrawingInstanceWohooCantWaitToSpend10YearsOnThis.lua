-- commit info goes hard frfr :3
-- ok so now it time to add connections.
-- i fucking love making thsoe yea,,,,,,,,,,

local Services = {
    Input = cloneref(game:service "UserInputService"),
    Core = cloneref(game:service "CoreGui"),
    Run = cloneref(game:service "RunService"),
    Tween = cloneref(game:service "TweenService")
}

local Easing = {} do
    Easing.Out = {} do
        Easing.Out.Quad = function(x) -- main easing for scrolling
            return 1 - math.pow(1 - x, 4)
        end
    end
end

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

local function Lerp(a, b, c)
    return a + c * (b - a)
end

local DraggableObjs = {} do
    local Connection

    Services.Input.InputBegan:Connect(function(input, ret)
        if input.UserInputType == Enum.UserInputType.MouseBUtton1 then
            for _, frame in DraggableObjs do
                if frame:MouseInFrame() and frame.Visible and frame.Opacity ~= 0 then
                    local _continue

                    for __, descendant in frame:Children(true) do
                        if (descendant.Active and descendant:IsInFrame() and descendant.Opacity ~= 0 and descendant.__object.Visible and frame.__object.Main.ZIndex <= descendant.__object.Main.ZIndex) then
                            _continue = true

                            break
                        end
                    end

                    if _continue then continue end

                    if Connection then
                        Connection:Disconnect()
                    end

                    local mp = Services.Input:GetMouseLocation()
                    local offset = (v.Parent and v.__object.Position - mp or mp) - v.Position

                    Connection = Services.Input.InputChanged:Connect(function() 
                        frame.Position = (frame.Parent and frame.Parent.Position or Vector2.zero) + mp - offset
                    end)
                end
            end
        end
    end)
end

local ScrollableObjs = {} do
    Services.Input.InputChanged:Connect(function(input, ret)
        if ret then return end

        if input.UserInputType == Enum.UserInputType.MouseWheel then
            local up = input.Position.Z > 0

            for _, frame in ScrollableObjs do
                if frame.__scrolling.YPosition <= 0 and not up then continue end
                if frame.__scrolling.YPosition >= frame.__properties.ScrollSize and up then continue end
                local samount, ypos = frame.__properties.ScrollAmount, frame.__scrolling.YPosition

                if frame:MouseInFrame() and frame.Visible and frame.Opacity ~= 0 then
                    DeltaIter(up and 0 or 1, up and 1 or 0, 50, function(inc)
                        for i,v in frame:Children(true) do
                            if v.__properties.IgnoreScrolling then continue end

                            if v.Class == "Line" then
                                v.__object.To = Vector2.new(v.__object.To.X, frame.Position.Y + v.To.Y + Lerp(ypos, ypos + samount, Easing.Out.Quad(inc)))
                                v.__object.From = Vector2.new(v.__object.from.X, frame.Position.Y + v.From.Y + Lerp(ypos, ypos + samount, Easing.Out.Quad(inc)))
                            
                                continue
                            end

                            v.__object.Position = Vector2.new(v.__object.Position.X, frame.Position.Y + v.Y + Lerp(ypos, ypos + samount, Easing.Out.Quad(inc)))
                        end
                    end)

                    frame.__scrolling.YPosition += (up and 1 or -1) * frame.ScrollAmount
                end
            end
        end
    end)
end
local Draw = {}

Draw.__index = function(self, key)
    return Draw[key] or self.__properties[key] or self.__children[key] or error(`{key} is not a valid member of {self.Name}`)
end
Draw.__newindex = function(self, key, value)
    if key == "Parent" then
        if value then
            table.insert(self, value.__children)

            Draw.__newindex(self, "Position", self.Position)
        end

        if self.__properties.Parent then
            table.remove(self.__properties.Parent, table.find(self.__properties.Parent, self))
        end

        self.__properties.Parent = value
    end

    if key == "Draggable" then
        if not value and not table.find(DraggableObjs, self) then return end
        table[value and "insert" or "remove"](DraggableObjs, value and self or table.find(DraggableObjs, self))
    end

    if key == "Position" then
        local pos, parent = Vector2.zero, self.__properties.Parent

        while parent do
            parent = parent.__properties.Parent

            if parent then
                pos += parent.__properties.Position
            end
        end

        for _, descendant in self:Children(true) do
            descendant.__object.Position = descendant.__object.Position + (self.__object.Position - descendant.__object.Position)
        end

        self.__properties[key] = value

        return
    end

    if key == "ZIndex" then
        local zindex, parent = self.__properties.ZIndex, self.__properties.Parent

        while parent do
            parent = parent.__properties.Parent

            if parent then
                zindex += parent.__properties.ZIndex
            end
        end

        self.__object.ZIndex = zindex
        self.__properties[key] = value

        return
    end

    if key == "Visible" then
        for _, descendant in self:Children(true) do
            descendant.__object.Visible = descendant.Visible and value or false
        end
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

    if tweeninfo.DelayTime or tweeninfo.delayTime then -- i get most roblox devs are incompetent but delay(time, func, ...) exists?? 
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

function Draw.MouseInFrame(self)
    local Mouse = Services.Input:GetMouseLocation()
    local Pos = self.__object.Position or self.__object.PointB 
    local Size = typeof(frame.Size) == "Vector2" and frame.Size or frame.TextBounds

    return Pos.Y < Mouse.Y and Mouse.Y < Pos.Y + Size.Y and Pos.X < Mouse.X and Mouse.X < Pos.X + Size.X
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

function Draw.SetAttribute(self, key, value)
    self.__attributes[key] = value
end

function Draw.GetAttribute(self, key)
    return self.__attributes[key]
end

function Draw:new(Type, parent)
    local obj = Drawing.new(Type)
    local properties = {
        Draggable = false,
        Scrollable = false,
        IgnoreScrolling = false,
        ScrollSize = 200,
        ScrollAmount = 20
        Name = Type,
        Class = Type,
        Parent = parent,
        Active = false,
        -- Defaualt properties
        Visible = true,
        Opacity = 1,
        ZIndex = 0,
        Color = Color3.new(1, 1, 1),
    }

    return setmetatable({__properties = {}, __children = {}, __object = obj, __attributes = {}, __scrolling = {
        YPosition = 0
    }}, Draw)
end

return Draw