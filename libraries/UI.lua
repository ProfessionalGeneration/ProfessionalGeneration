-- v3 isnt updated.... this is a whole new challenge
local UIs = {}
local Get, Directory, File = ... -- this is the first library to do this so, ill explain here
-- whatever requires it MUST pass at least a Get function because the FileSystem library holds all the loaded modules (im trying not to reload them on every different library)
local Libraries = Get:Get"libraries"
local Services, Draw, DrawObjects, Easing, Math, Tween = Libraries:Get"Services":Load(), Libraries:Get"Draw":Load(), Libraries:Get"DrawObjects":Load(), Libraries:Get"Easing":Load(), Libraries:Get"Math":Load(), Libraries:Get"Tween":Load() -- lmao wtf

local Interactables = {}
Interactables.__index = Interactables

function Interactables:Button(Frame, settings, callback) -- i think im gonna go a different route i dont like this one
    local Text = DrawObjects.Label {
        Text = settings.Text,
        Active = true,
        Color = settings.Locked and (settings.Color:Lerp(Color3.new(), .75) or Color3.new(1,1,1):Lerp(Color3.new(), .75)) or (settings.Color or Color3.new(1, 1, 1)),
        Outlined = true,
        Size = settings.Size or frame.Size.Y - 2,
        Visible = true,
        Position = settings.Position or Vector2.zero,
        Parent = Frame,
        Name = "ButtonText"
    }

    local con = Frame.Mouse1Down:Connect(function()
        if settings.Locked then return end
        local oc = Frame.Color

        Frame.Color = oc:Lerp(Color3.new(), .75)
        Frame.Mouse1Up:Wait()
        task.spawn(pcall, callback)
        Frame.Color = oc
    end)

    return setmetatable({__frame = frame, __settings = settings, __type = "Button"}, Interactables)
end

function Interactables:Toggle(Frame, settings, callback)
    local Text = DrawObjects.Label {
        Text = settings.Text,
        Active = true,
        Color = settings.Locked and (settings.Color:Lerp(Color3.new(), .75) or Color3.new(1,1,1):Lerp(Color3.new(), .75)) or (settings.Color or Color3.new(1, 1, 1)),
        Outlined = true,
        Size = settings.Size or frame.Size.Y - 2,
        Visible = true,
        Position = settings.Position or Vector2.zero,
        Parent = Frame,
        Name = "ButtonText"
    }
    local Toggle = DrawObjects.GradientFrame {
        Active = true,
        Size = Vector2.new(Frame.Size.Y - 4, Frame.Size.Y - 4),
        Visible = true,
        Color = settings.Toggled and Color3.new(0, .8, 0) or Color3.new(.8, 0, 0),
        Parent = Frame,
        Name = "ToggleBox"
    }
    DrawObjects.Outline(Toggle)
    local function Toggle()
        if settings.Locked then return end
    
        Toggle:Tween(, {}, {Direction = "InOut", Style = "Quint"})
    end

    Frame.Mouse1Down:Connect(Toggle)
    Toggle.Mouse1Down:Connect(Toggle)

    return setmetatable({__frame = frame, __settings = settings, __type = "Button"}, Interactables)
end

function Interactables.Lock(self, locked)
    local text = (table.find({"Button", "Toggle"}, self.__type) and self.__frame.ButtonText

    locked = locked == nil and not self.__settings.Locked or locked
    self.__settings.Locked = locked
    text.Color = locked and (settings.Color:Lerp(Color3.new(), .75) or Color3.new(1,1,1):Lerp(Color3.new(), .75)) or (settings.Color or Color3.new(1, 1, 1))
end

function Interactables.Edit(self, settings)
    --self.
end

return UIs