-- ill make websocket later lolo
local Get, Directory, File = loadfile("Progen/libraries/FileSystem.lua")()
local Services = Get:Get"libraries":Get"Services":Load()
local Network = {}
Network.__index = function(self, key)
    return Network[key] or (key == "Recieved" and self.__connections[key] or (self.__connections[key] and self.__connections.Event)) or self[key]
end

function Network:new(port)
    local socket = WebsocketClient.new(`ws://localhost:{port}/`)
    local cc = Instance.new "BindableEvent"
    socket.DataRecieved:Connect(function(data)
        local processed = Services.Http:JSONDecode(data)

        if data.Data and data.Data.Action == "ClientConnected" then
            cc:Fire(data.Data.Client)
        end
    end)

    return setmetatable({__socket = socket, __user = Services.Players.LocalPlayer.Name, __connections = {
        Recieved = socket.DataRecieved,
        ClientConnected = cc
    }}, Network)
end

function Network.Send(self, data)
    self.__socket:Send(Services.Http:JSONEncode(self:GetSendData(data)))
end

function Network.SendToClient(self, data, client)
    data["Reciever"] = client
    self.__socket:Send(Services.Http:JSONEncode(self:GetSendData(data)))
end

function Network.Connect(self)
    return Services.Http:JSONDecode(self:Invoke(self:GetSendData({}, "connect")))
end

function Network.GetConnected(self)
    return self:Invoke {["Action"] = "GetConnected"}.Connected
end

function Network.GetSendData(self, data, method: string?)
    return {
        ID = Services.Http:GenerateGUID(),
        Client = self.__user,
        Method = method or "send",
        Data = Services.Http:JSONEncode(data)
    }
end

function Network.Invoke(self, data)
    local senddata, recieved = self:GetSendData(data, "invoke")
    self.__socket:Send(Services.Http:JSONEncode(senddata))
    repeat
        recieved = Services.Http:JSONDecode(self.__socket.DataRecieved:Wait())
    until recieved and recieved.ID and recieved.ID == senddata.ID

    return recieved
end

return Network
