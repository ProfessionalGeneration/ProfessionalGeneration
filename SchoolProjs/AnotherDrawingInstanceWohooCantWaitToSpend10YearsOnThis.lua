local Services = {
    Input = cloneref(game:service "UserInputService"),
    Core = cloneref(game:service "CoreGui"),
    Run = cloneref(game:service "RunService"),
    Tween = cloneref(game:service "TweenService")
}

local Draw = {}
Draw.__index = Draw

function Draw.Children(self, recursive)
    local children = {}
    
    for property,child in self do
        if type(child) == "table" and property ~= "Parent" then
            table.insert(children, child)

            if recursive then
                for _, descendant in child:Children(true) do
                    table.insert(children, descendant)
                end
            end
        end
    end

    return children
end