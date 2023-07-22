local Known = setmetatable({}, {__newindex = function(t, k, v)
    rawset(t, k, cloneref(game:service(v)))
end})

Known.Tween = "TweenService"
Known.Core = "CoreGui"
Known.Http = "HttpService"
Known.Run = "RunService"
Known.Players = "Players"
Known.Teams = "Teams"
Known.Storage = "ReplicatedStorage"
Known.First = "ReplicatedFirst"
Known.Teleport = "TeleportService"
Known.Stats = "Stats"
Known.Input = "UserInputService"

return Known
