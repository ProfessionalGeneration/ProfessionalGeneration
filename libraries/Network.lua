local Get, Directory, File = ...
local Services = Get:Get"libraries":Get"Services":Load()
local Network = {}
Network.__index = function(self, key)
    return Network[key] or self.__connections[key] or self[key]
end

function Network:new(port: number)
    local socket = WebsocketClient.new(`ws://localhost:{port}/`)
    local cc = Instance.new "BindableEvent"
    socket.DataRecieved:Connect(function(data)
        local processed = Services.Http:JSONDecode(data)

        if processed.Data and processed.Data.Action == "ClientConnected" then
            cc:Fire(processed.Data.Client)
        end
    end)

    return setmetatable({__socket = socket, __user = Services.Players.LocalPlayer.Name, __connections = {
        Recieved = socket.DataRecieved,
        ClientConnected = cc.Event
    }}, Network)
end

function Network.Send(self, data)
    self.__socket:Send(self:GetSendData(data))
end

function Network.SendToClient(self, data: table, client: string)
    data["Reciever"] = client
    self.__socket:Send(self:GetSendData(data, "sendclient"))
end

function Network.GetConnected(self)
    return self:Invoke {["Action"] = "GetConnected"}
end

function Network.Connect(self)
    return self:Invoke {["Action"] = "Connect"}
end

function Network.GetSendData(self, data: table, method: string?)
    return Services.Http:JSONEncode {
        ID = Services.Http:GenerateGUID(),
        Client = self.__user,
        Method = method or "send",
        JobId = game.JobId,
        Data = data
    }
end

function Network.Invoke(self, data)
    local senddata, recieved = self:GetSendData(data, "invoke")
    local id = Services.Http:JSONDecode(senddata).ID
    self.__socket:Send(senddata)
    repeat
        recieved = Services.Http:JSONDecode(self.__socket.DataRecieved:Wait())
    until recieved and recieved.ID and recieved.ID == id

    return recieved.Return
end

return Network
