-- hi advisory teacher 😀
-- uhh to fill u in it basically a ui object base with parenting system

-- made this at school with absolutely NO debugging (quite the challenge aint it)
-- ill mess with OOP in school cuz why not (and remake my "Draw" stuff to be a bit more useful)

local Dinstance = {} do
    local GradientData = syn.request({Url = "https://github.com/GFXTI/ProfessionalGeneration/blob/main/LibraryImages/angryimg.png?raw=true"}).Body
    local DraggableFrames, ScrollableFrames = {}, {}
    local sv = {
        uis = cloneref(game:service "UserInputService"),
        core = cloneref(game:service "CoreGui"),
        run = cloneref(game:service "RunService")
    } -- Services if u couldn't tell (i dont wanna type it all out)

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
        local pos = frame.Position

        for i,v in GetParents(frame) do
            pos += v.Position
        end

        return pos
    end

    local function UpdateBox(props, frames) -- more of update than updatebox
        local msize = frames.Main.Size or frames.Main.TextBounds or frames.Main.Radius or (frames.PointB - frames.PointD) -- ill add the uhh custom outline objects later ("Circle", "Quad", and other stuff)

        if props.Drag then
            table.insert(DraggableFrames, frames.Main)
        else
            local Found = table.find(DraggableFrames, frames.Main)

            if Found then
                table.remove(DraggableFrames, Found)
            end
        end

        if props.Scrolling then
            table.insert(ScrollableFrames, frames.Main)
        else
            local Found = table.find(ScrollableFrames, frames.Main)

            if Found then
                table.remove(ScrollableFrames, Found)
            end
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
        
        if table.find({"Image", "Square"}, tostring(frames.Main))
            frames.Outline.Visible = props.Outline and frames.Main.Visible
            frames.Outline.Color = props.OutlineColor
            frames.Outline.Thickness = props.OutlineThickness
            frames.Outline.Position = frames.Main.Position - Vector2.new(props.OutlineThickness, props.OutlineThickness)
            frames.Outline.Size = msize + Vector2.new(props.OutlineThickness, props.OutlineThickness)
            frames.Outline.ZIndex = frames.Main.ZIndex
        end
    end

    local newindex = function(t, k, v)
        if k == "Position" then
            t.__frames.Main.Position = props.Parent and props.Parent.Position + props.Position or props.Position
            local actualframepos = Vector2.zero
            for i,v in GetParents(t.__frames.Main) do
                actualframepos += v.Position
            end

            for i,v in t.__children do
                v.Position = GetActualPosition(t.__.Frames) + v.Position
            end
        end

        t.props[k] = v
        UpdateBox(t.props, t.frames)
    end

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
            }
            local children = {}

            frame.Filled = true

            return frame, setmetatable({["__children"] = children, ["__props"] = props, ["__frames"] = frames}, {
                __index = props,
                __newindex = newindex
            })
        end,
        ["Text"] = function()
            local frame = Drawing.new "Text"
            local props = {}
            local children = {}

            return frame, setmetatable({["__children"] = children, ["__props"] = props, ["__frames"] = frames}, {
                __index = props,
                __newindex = newindex
            })
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
            }
            local children = {}

            frame.Data = GradientData

            return frame, setmetatable({}, {
                __index = props,
                __newindex = newindex
            })
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
                ["OutlineThickness"] = 2
            }
            local children = {}

            return frame, setmetatable({}, {
                __index = props,
                __newindex = newindex
            })
        end,
    }
    
    function Dinstance.new(Type)
        local Object, Metatable = Types[Type]()
        local RawNewIndex = getrawmetatable(Metatable.__newindex)

        setmetatable(Metatable, {
            __newindex = function(t, k, v)
                if k == "Parent" then
                    if Metatable.__props.Parent then
                        local oldparent = Metatable.__props.Parent.__children
                        table.remove(oldparent, table.find(oldparent, Metatable))

                        if v then
                            table.insert(v.__children, Metatable)
                        end
                    end
                end

                RawNewIndex(t, k, v)
            end
        })

        return Metatable
    end

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

            for _,child in self:children() do
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
        end
    }

    for i,v in funcs do
        Dinstance[i] = v
        Dinstance[i:lower()] = v
    end

    Dinstance.__index = Dinstance

    sv.uis.InputBegan:Connect(function(input, ret) 
        if ret then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            for i,v in DraggableFrames do
                if IsInFrame(v) and v.Opacity ~= 0 and v.Visible then
                    local _continue

                    for _i, _v in v:children(true) do
                        if (_v.Active and IsInFrame(_v) and _v.Opacity ~= 0 and _v.Visible) then
                            _continue = true
                            
                            break
                        end
                    end

                    if _continue then continue end
                end
            end
        end
    end)
end
