-- ill make websocket later lolo
local Get, Directory, File = loadfile("Progen/libraries/FileSystem.lua")()
local Services = Get:Get"libraries":Get"Services":Load()
local Network = {}
Network.__index = function(self, key)
    return Network[key] or self.__connections[key] or self[key]
end

function Network:new(port)
    local socket = WebsocketClient.new(`ws://localhost:{port}/`)

    return setmetatable({__socket = socket, __user = Services.Players.LocalPlayer.Name, __connections = {
        Recieved = socket.DataRecieved
    }}, Network)
end

function Network.Send(self, data)
    self.__socket:Send(Services.Http:JSONEncode(self:GetSendData(data)))
end

function Network.Connect(self)
    return self:Invoke(self:GetSendData({}, "connect"))
end

function Network.GetSendData(self, data, method: string?)
    return {
        ID = Services.Http:GenerateGUID(),
        Client = self.__user,
        Method = method or "send",
        Data = data
    }
end

function Network.Invoke(self, data)
    local senddata, recieved = self:GetSendData(data)
    self.__socket:Send(Services.Http:JSONEncode(senddata), "invoke")
    repeat
        recieved = Services.Http:JSONDecode(self.__socket.DataRecieved:Wait())
    until recieved and recieved.ID and recieved.ID == senddata.ID

    return recieved
end

return Network
