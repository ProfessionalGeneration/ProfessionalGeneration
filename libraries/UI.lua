-- v3 isnt updated.... this is a whole new challenge
local UIs = {}
local Get, Directory, File = ... -- this is the first library to do this so, ill explain here
-- whatever requires it MUST pass at least a Get function because the FileSystem library holds all the loaded modules (im trying not to reload them on every different library)
local Libraries = Get:Get"libraries"
local Services, Draw, DrawObjects, Easing, Math, Tween = Libraries:Get"Services":Load(), Libraries:Get"Draw":Load(), Libraries:Get"DrawObjects":Load(), Libraries:Get"Easing":Load(), Libraries:Get"Math":Load(), Libraries:Get"Tween":Load() -- lmao wtf

local Interactables = {}
Interactables.__index = Interactables

function Interactables:Button(frame, settings, callback) -- i think im gonna go a different route i dont like this one
    local Text = DrawObjects.Label()

    Text.Active = true
    Text.Text = settings.Text
    Text.Color = settings.Color or Color3.new(1, 1, 1)
    Text.Outlined = true
    Text.Size = settings.Size or frame.Size.Y - 2
    Text.Visible = true
    Text.Parent = frame
    Text.Name = "ButtonText"

    local con = Frame.Mouse1Down:Connect(function()
        local oc = Frame.Color

        Frame.Color = oc:Lerp(Color3.new(), .75)
        Frame.Mouse1Up:Wait()
        task.spawn(pcall, callback)
        Frame.Color = oc
    end)

    return setmetatable({__frame = frame, __settings = settings}, Interactables)
end


return UIs