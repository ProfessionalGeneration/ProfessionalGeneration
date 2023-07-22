local Get = ...
local Services, Math = Get:Get"libraries":Get"Services":Load(Get), Get:Get"libraries":Get"Math":Load(Get)
local fov = {
    On = false,
    SetFov = 50,
    Fov = 0,
    Mode = "Generic Circle",

    internal = {
        VelPart = nil
    }
}
local frames = setmetatable({}, {__newindex = function(tbl, idx, val)
    val.Thickness = 2
    val.Color = Color3.new(1, 0, 0)
    val.Filled = false

    rawset(tbl, idx, val)
end}) -- yes this isnt the draw lib we have cuz it doesnt fit our needs

function fov.SetMode(mode)
    local type = mode:split" "[1]
    local shape = mode:split" "[2]
    local newframes = {}

    if type == "Generic" or type == "Double" then
        if shape == "Circle" then
            newframes.MainCircle = Drawing.new "Circle"
        end

        if shape == "Square" then
            newframes.MainSquare = Drawing.new "Square"
        end
    end

    if type == "Double" then
        if shape == "Circle" then
            newframes.InnerCircle = Drawing.new "Circle"
        end

        if shape == "Square" then
            newframes.InnerSquare = Drawing.new "Square"
        end
    end

    for i,v in frames do
        v:Remove()
    end
    table.clear(frames)
    
    for i,v in newframes do
        frames[i] = v
    end
    fov.Mode = mode
end

function fov.SetVelocityTarget(part)
    fov.internal.VelPart = part
end

function fov.IsInFov(v2)
    local mp = Services.Input:GetMouseLocation()

    if fov.Mode:split" "[2] == "Circle" then
        return (v2 - mp).magnitude <= fov.Fov and (v2 - mp).magnitude
    end

    if fov.Mode:split" "[2] == "Square" then
        local tl, br = mp - Vector2.new(fov.Fov, fov.Fov), mp + Vector2.new(fov.Fov, fov.Fov)
        return (v2.Y > tl.Y and v2.Y < br.Y and v2.X > tl.X and v2.X < br.X) and (v2 - mp).magnitude
    end
end

fov.SetMode "Generic Square"

Services.Run.RenderStepped:Connect(function(delta)
    local newfov = Math.Lerp(fov.Fov, fov.SetFov + (fov.internal.VelPart and fov.internal.VelPart.Velocity.magnitude or 0), delta * 5)
    local pos = Services.Input:GetMouseLocation()
    fov.Fov = newfov

    for i,v in frames do
        v.Visible = fov.On
    end

    if frames.MainCircle then
        frames.MainCircle.Position = pos
        frames.MainCircle.Radius = newfov
    end

    if frames.MainSquare then
        frames.MainSquare.Position = pos - Vector2.new(newfov, newfov)
        frames.MainSquare.Size = Vector2.new(newfov * 2, newfov * 2)
    end

    if frames.InnerCircle then
        frames.InnerCircle.Position = pos
        frames.InnerCircle.Radius = fov.SetFov
    end

    if frames.InnerSquare then
        frames.InnerSquare.Position = pos - Vector2.new(fov.SetFov, fov.SetFov)
        frames.InnerSquare.Size = Vector2.new(fov.SetFov * 2, fov.SetFov * 2)
    end
end)

return fov
