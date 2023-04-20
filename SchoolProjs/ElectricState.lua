local old; old = hookfunction(getrenv()._G.ShakeCamera, function(...) 
    if Toggles.NoCameraShake then return end

    return old(...)
end)

local fake = character:Clone()
fake.Parent = workspace
local real = character
local rad, rand, v3 = math.rad, math.random, Vector3.new
local items = {}

real.Character.ChildRemoved:Connect(function(item) 
    if items[item] then
        items[item].Parnet = nil
    end
end)

real.Character.ChildAdded:Connect(function(item)
    if item:isA "Tool" then return end

    items[item] = item:Clone()
    items[item].Parent = fake
end)

Services.Run.RenderStepped:Connect(function()
    if not Settings.AntiAim then return end

    real.HumanoidRootPart.AngularVelocity = Vector3.new(1e5, 1e5, 1e5)
    real.HumanoidRootPart.CFrame = CFrame.new(fake.HumanoidRootPart.Position + v3(
        rand(-5, 5), rand(-2, 2), rand(-5, 5)),
    v3(
        rad(rand(-180,180)), rad(rand(-180, 180)), rad(rand(-180, 180))
    ))
end)

hooks["AntiAimIndex"] = hookmetamethod(game, "__index", function(instance, value)
    return hooks["AntiAimIndex"]
end)