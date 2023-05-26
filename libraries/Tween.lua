local Get, File, Directory = loadfile("Progen/libraries/FileSystem.lua")()
local Math, Easing = Get:Get"Math":Load(), Get:Get"Easing":Load()
local Tween = {}
Tween.__index = function(self, key)
    return Tween[key] or (self.__connections[key] and self.__connections[key].Event)
end

function Tween.Play(self)
    local ease = Easing[self.__set.Direction or "Out"][self.__set.Style or "Quad"]

    task.spawn(function()
        Math.DeltaIter(0, 1, 1 / (self.__set.Time or 1), function(inc)
            local eased = ease(inc)

            for prop, val in self.__props do
                self.__obj[prop] = self.__obj[prop]:lerp(val, eased)
            end
        end)

        self.__connections.Finished:Fire()
    end)
end

function Tween:new(tbl, properties, settings)
    return setmetatable({__props = properties, __obj = tbl, __set = settings, __connections = {Finished = Instance.new "BindableEvent"}}, Tween)
end

function Tween:GetValue(time, properties)
    return Easing[properties.Direction or "Out"][properties.Style or "Quad"](time)
end

return Tween
