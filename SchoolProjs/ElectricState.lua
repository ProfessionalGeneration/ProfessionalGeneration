name.Color = table.find({"Mayor", "Soldier", "Detective"}, player.Job.Value) and Color3.new(.1, .1, .8) or player.Job.Value == "Farmer" and Color3.new(.1, .8, .1) or Color3.new(.8, .8, .8)

local function LerpDeltaIter(start, _end, speed, callback)
    local percent = 0

    while percent < 1 do
        percent += Services.Run.RenderStepped:wait() * speed

        callback(Math.Lerp(start, _end, percent))
    end

    callback(_end)
end

for i,v in binds do
    local bind = binds:add(i, v.Default, v.Toggle, v.Function)

    binds:Toggle(i, true, function(toggled) 
        if toggled then
            return bind:remove()
        end

        bind = bind:add(i, v.Default, v.Toggle, v.Function)
    end)
end