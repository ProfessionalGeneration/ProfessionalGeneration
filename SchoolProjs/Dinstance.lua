-- hi advisory teacher 😀
-- uhh to fill u in it basically a ui object base with parenting system

-- made this at school with absolutely NO debugging (quite the challenge aint it)
-- ill mess with OOP in school cuz why not (and remake my "Draw" stuff to be a bit more useful)

--[[ TODO:
    Size & Position clamping -- ok screw that ill do it later
    Finish scrolling
]]

local Dinstance, Funcs = {}, {} do
    local GradientData = syn.request({Url = "https://github.com/GFXTI/ProfessionalGeneration/blob/main/LibraryImages/angryimg%20(2).png?raw=true"}).Body
    local DraggableFrames, ScrollableFrames = {}, {}
    local mp = Vector2.zero
    local sv = {
        uis = cloneref(game:service "UserInputService"),
        core = cloneref(game:service "CoreGui"),
        run = cloneref(game:service "RunService"),
        ts = cloneref(game:service "TweenService")
    } -- Services if u couldn't tell (i dont wanna type it all out)
    local Frames = {} -- to prevent gc

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

    local function GetFinalParent(frame)
        while frame.Parent do
            frame = frame.Parent
        end

        return frame
    end

    local function GetParents(frame)
        local parents = {}

        while frame.Parent do
            frame = frame.Parent

            table.insert(parents, frame)
        end

        return parents
    end

    local function GetActualPosition(frame)
        return frame.__frames.Main.Position
    end

    local function IsInFrame(frame)
        local pos = frame.Parent and GetActualPosition(frame) or frame.Position
        local size = typeof(frame.Size) == "Vector2" and frame.Size or frame.TextBounds

        return pos.Y < mp.Y and mp.Y < pos.Y + size.Y and pos.X < mp.X and mp.X < pos.X + size.X
    end

    local function UpdateBox(props, frames) -- more of update than updatebox
        local msize = frames.Main.Size or frames.Main.TextBounds or frames.Main.Radius -- ill add the uhh custom outline objects later ("Circle", "Quad", and other stuff)
        local pos = props.Parent and props.Parent.Position or Vector2.zero

        if props.Parent then
            for i,v in GetParents(props.Parent) do
                pos += v.Position
            end
        end

        frames.Main.Position = pos + props.Position or props.Position

        if tostring(frames) == "Text" then
            props["TextBounds"] = frames.Main.TextBounds
        end

        if tostring(frames.Main) == "Circle" then
            for i,v in frames do
                if i == "Main" then continue end

                v.Visible = props.Outline and frames.Main.Visible
                v.Color = props.OutlineColor
                v.Thickness = props.OutlineThickness
                v.Position = frames.Main.Position
                v.Radius = frames.Main.Radius + ((props.OutlineThickness / 2) * (i:find("In") and -1 or 1))
                v.ZIndex = frames.Main.ZIndex
            end

            return
        end

        if table.find({"Image", "Square"}, tostring(frames.Main)) then
            frames.Outline.Visible = props.Outline and frames.Main.Visible
            frames.Outline.Color = props.OutlineColor
            frames.Outline.Thickness = props.OutlineThickness
            frames.Outline.Position = frames.Main.Position - Vector2.new(props.OutlineThickness / 2, props.OutlineThickness / 2)
            frames.Outline.Size = msize + Vector2.new(props.OutlineThickness / 2, props.OutlineThickness / 2)
            frames.Outline.ZIndex = frames.Main.ZIndex
        end
    end

    Funcs = {
        ["IsInFrame"] = IsInFrame,
        ["DeltaIter"] = DeltaIter,
        ["GetTextSize"] = GetTextSize,
        ["Lerp"] = Lerp,
        ["GetActualPosition"] = GetActualPosition,
    }

    local funcs = {
        ["Children"] = function(self, recursive)
            local children = {}

            for _,v in self.__children do
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
            for i,v in self.__frames do
                v:Destroy()
            end

            for _,child in self:children(true) do
                for __,v in child.__frames do
                    v:Destroy()
                end
            end
        end,
        ["FindChild"] = function(self, name, recursive)
            for i,v in self:children(recursive) do
                if v.name == name then
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
        end
    }

    local Types = {
        ["Frame"] = function()
            local frame = Drawing.new "Square"
            local frames = {
                ["Main"] = frame,
                ["Outline"] = Drawing.new "Square"
            }
            local props = {
                ["Outline"] = false,
                ["OutlineColor"] = Color3.new(),
                ["OutlineThickness"] = 2,
                ["Position"] = Vector2.zero,
                ["Size"] = Vector2.new(200, 200)
            }
            local children = {}
            local cons = {
                Mouse1Click = Instance.new"BindableEvent",
                Mouse2Click = Instance.new"BindableEvent",
                Hovered = Instance.new"BindableEvent",
            }

            sv.uis.InputBegan:Connect(function(input, ret)
                if ret then return end

                if IsInFrame(frame) then
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        cons.Mouse1Click:Fire(mp)
                    end

                    if input.UserInputType == Enum.UserInputType.MouseButton2 then
                        cons.Mouse2Click:Fire(mp)
                    end
                end
            end)

            frame.Filled = true

            return frame, {["__children"] = children, ["__props"] = props, ["__frames"] = frames, ["__connections"] = cons}
        end,
        ["Text"] = function()
            local frame = Drawing.new "Text"
            local tb, tbcon = Instance.new "TextBox" -- yes this is the only "roblox ui" because im not fucking making an entire keyboard handler
            local props = {
                ["Position"] = Vector2.zero,
                ["Size"] = 18,
                ["CanType"] = false
            }
            local children = {}
            local cons = {
                Mouse1Click = Instance.new"BindableEvent",
                Mouse2Click = Instance.new"BindableEvent",
                Hovered = Instance.new"BindableEvent",
                -- custom
                Focused = Instance.new"BindableEvent",
                Typing = Instance.new"BindableEvent",
                FocusLost = Instance.new"BindableEvent",
            }

            cons.Mouse1Click.Event:Connect(function(pos)
                if props.CanType and frame.Visible and frame.Opacity > .1 and IsInFrame({Position = frame.Position, TextBounds = Vector2.new(math.clamp(frame.TextBounds.X, 10, math.huge), props.Size)}) then
                    if tbcon then
                        tbcon:Disconnect()
                    end

                    tb.Parent = sv.core
                    tb:CaptureFocus()
                    tb.Text = frame.Text
                    tb.CursorPosition = #frame.Text + 1
                    cons.Focused:Fire()
                    tbcon = tb.Changed:Connect(function()
                        frame.Text = tb.Text
                        cons.Typing:Fire(tb.Text)
                    end)

                    tb.FocusLost:Once(function()
                        tbcon:Disconnect()
                        cons.FocusLost:Fire()
                        tb.Parent = nil
                    end)
                end
            end)

            return frame, {["__children"] = children, ["__props"] = props, ["__frames"] = {["Main"] = frame}, ["__connections"] = cons}
        end,
        ["Image"] = function()
            local frame = Drawing.new "Image"
            local frames = {
                ["Main"] = frame,
                ["Outline"] = Drawing.new "Square"
            }
            local props = {
                ["Outline"] = false,
                ["OutlineColor"] = Color3.new(),
                ["OutlineThickness"] = 2,
                ["Position"] = Vector2.zero,
                ["Size"] = Vector2.new(200, 200)
            }
            local children = {}
            local cons = {
                Mouse1Click = Instance.new"BindableEvent",
                Mouse2Click = Instance.new"BindableEvent",
                Hovered = Instance.new"BindableEvent",
            }

            return frame, {["__children"] = children, ["__props"] = props, ["__frames"] = frames, ["__connections"] = cons}
        end,
        ["Gradient"] = function()
            local frame = Drawing.new "Image"
            local frames = {
                ["Main"] = frame,
                ["Outline"] = Drawing.new "Square"
            }
            local props = {
                ["Outline"] = false,
                ["OutlineColor"] = Color3.new(),
                ["OutlineThickness"] = 2,
                ["Position"] = Vector2.zero,
                ["Size"] = Vector2.new(200, 200)
            }
            local children = {}
            local cons = {
                Mouse1Click = Instance.new"BindableEvent",
                Mouse2Click = Instance.new"BindableEvent",
                Hovered = Instance.new"BindableEvent",
            }

            frame.Data = GradientData

            return frame, {["__children"] = children, ["__props"] = props, ["__frames"] = frames, ["__connections"] = cons}
        end,
        ["Circle"] = function()
            local frame = Drawing.new "Cirlce"
            local frames = {
                ["Main"] = frame,
                ["OutlineIn"] = Drawing.new "Cirlce",
                ["OutlineOut"] = Drawing.new "Circle"
            }
            local props = {
                ["Outline"] = false,
                ["OutlineColor"] = Color3.new(),
                ["OutlineThickness"] = 2,
                ["Position"] = Vector2.zero,
                ["Size"] = Vector2.new(200, 200)
            }
            local children = {}
            local cons = {
                Mouse1Click = Instance.new"BindableEvent",
                Mouse2Click = Instance.new"BindableEvent",
                Hovered = Instance.new"BindableEvent",
            }

            return frame, {["__children"] = children, ["__props"] = props, ["__frames"] = frames, ["__connections"] = cons}
        end,
    }

    function Dinstance.new(Type)
        local Object, Metatable = Types[Type]()
        table.insert(Frames, Metatable)

        for i,v in Metatable.__props do
            if Object[i] then
                Object[i] = v
            end
        end

        for i,v in funcs do
            Metatable[i] = v
            Metatable[i:lower()] = v
        end

        sv.uis.InputBegan:Connect(function(input, ret)
            if not Metatable.__props.Active or ret then return end

            if IsInFrame(Object) and Object.Visible and Object.Opacity > .1 then
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Metatable.__connections.Mouse1Click:Fire(mp)
                end

                if input.UserInputType == Enum.UserInputType.MouseButton2 then
                    Metatable.__connections.Mouse2Click:Fire(mp)
                end
            end
        end)

        do
            local hovering

            sv.uis.InputChanged:Connect(function(input)
                if not Metatable.__props.Active or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

                if hovering then
                    if not IsInFrame(Object) and Object.Visible and Object.Opacity > .1 then
                        Metatable.__connections.Hovered:Fire(false)
                        hovering = false

                        return
                    end
                end

                if not hovering then
                    if IsInFrame(Object) and Object.Visible and Object.Opacity > .1 then
                        Metatable.__connections.Hovered:Fire(true)
                        hovering = true

                        return
                    end
                end
            end)
        end

        return setmetatable(Metatable, {
            __newindex = function(t, k, v)
                if k == "Parent" then
                    if Metatable.__props.Parent then
                        local oldparent = Metatable.__props.Parent.__children

                        table.remove(oldparent, table.find(oldparent, Metatable))
                    end

                    if v then
                        table.insert(v.__children, Metatable)
                    end

                    if not v.Visible then
                        for i,v in t.__frames do
                            v.Visible = false
                        end
                    end
                end

                if k == "Drag" then
                    if v then
                        if t.__props.Drag then return end

                        table.insert(DraggableFrames, Metatable)
                    else
                        local Found = table.find(DraggableFrames, Metatable)

                        if Found then
                            table.remove(DraggableFrames, Found)
                        end
                    end
                end

                if k == "Scrollable" then
                    if v then
                        if t.__props.Scrollable then return end

                        table.insert(ScrollableFrames, Metatable)
                    else
                        local Found = table.find(ScrollableFrames, Metatable)

                        if Found then
                            table.remove(ScrollableFrames, Found)
                        end
                    end
                end

                if k == "Position" then
                    for i,obj in Metatable:children() do
                        obj.Position = obj.Position
                    end
                end

                if k == "Visible" then
                    for i,obj in Metatable:children(true) do
                        for _, frame in obj.__frames do
                            frame.Visible = v and obj.Visible
                        end
                    end
                end

                if t.__frames.Main[k] ~= nil and k ~= "Position" then
                    t.__frames.Main[k] = v
                end

                t.__props[k] = v
                UpdateBox(t.__props, t.__frames)
            end,
            __index = function(_, v)
                return _.__props[v] or _.__children[v] or (_.__connections[v] and _.__connections[v].Event)
            end,
        })
    end

    Dinstance.__index = Dinstance

    sv.uis.InputChanged:Connect(function()
        mp = sv.uis:GetMouseLocation()
    end)

    do
        sv.uis.InputBegan:Connect(function(input, ret)
            if ret then return end
            if input.UserInputType == Enum.UserInputType.MouseWheel then
                local up = input.Position.Z > 0

                for _,frame in ScrollableFrames do
                    DeltaIter(0, 1, 10, function(i)
                        for __,v in frame:children() do
                            v.Position += Vector2.new(0, i * 20 * (up and -1 or 1))
                        end
                    end)
                end
            end
        end)
    end

    do
        local offset, frame, Connection = Vector2.zero

        sv.uis.InputBegan:Connect(function(input, ret)
            if ret then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                for i,v in DraggableFrames do
                    if IsInFrame(v) and v.Opacity ~= 0 and v.Visible then
                        local _continue

                        for _i, _v in v:children(true) do
                            if (_v.Active and IsInFrame(_v) and _v.Opacity ~= 0 and _v.Visible and v.__frames.Main.ZIndex <= _v.__frames.Main.ZIndex) then
                                _continue = true

                                break
                            end
                        end

                        if _continue then continue end

                        if Connection then
                            Connection:Disconnect()
                        end

                        frame = v
                        offset = (v.Parent and GetActualPosition(v) - mp or mp) - v.Position

                        Connection = sv.run.RenderStepped:Connect(function()
                            v.Position = (v.Parent and v.Parent.Position or Vector2.zero) + mp - offset
                        end)
                    end
                end
            end
        end)

        sv.uis.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if Connection then
                    Connection:Disconnect()
                end

                if frame then
                    frame.Position = (frame.Parent and frame.Parent.Position or Vector2.zero) + mp - offset
                    frame = nil
                end
            end
        end)
    end
end

--[==[
    -- Scrolling will be added later

    DOCUMENTATION:
        local Frame = Dinstance.new "Frame"

        -- Normal properties
        Frame.Position = Vector2.new(1000, 500) -- Default 0, 0
        Frame.Size = Vector2.new(200, 200) -- Default 200, 200
        Frame.Visible = true -- Remember to set this to true, as drawing objects are defaulted to false

        -- Dragging
        Frame.Drag = true

        local Gradient = Dinstance.new "Gradient"

        -- Normal properties
        Gradient.Position = Vector2.new(10, 10) -- Positions are relative to the frames they are parented too
        Gradient.Size = Vector2.new(180, 180)
        Gradient.Visible = true

        -- Parenting
        Gradient.Parent = Frame

        -- Outlines
        Frame.Outline = true -- Default false
        Frame.OutlineThickness = 2 -- Default 2
        Frame.OutlineColor = Color3.new(.15, .15, .15) -- Default Color3.new(0, 0, 0)

        local Text = Dinstance.new "Text"
        -- Normal properties

        Text.Position = Vector2.new(500, 500)
        Text.Text = "Text frame"
        Text.Visible = true
        Text.Size = 20
        Text.Outline = true
        Text.Color = Color3.new(1, 1, 1)

        -- Custom properties
        Text.CanType = true -- frame.Active must be set to true for you to interact with it (excluding dragging)
        Text.Active = true

        -- Functions
        Text:Children(true --[[Recursive]])
        Text:Tween(TweenInfo.new(2), --[[TweenInfo]], {Size = 40}--[[Properties]])
]==]

return Dinstance, Funcs