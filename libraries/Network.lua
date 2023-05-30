-- ok so basically, websocket. I'll have to make the websocket work wth these so /shrug
local Get, Directory, File = loadfile("Progen/libraries/FileSystem.lua")()
local Services = Get:Get"libraries":Get"Services":Load()

local Network = {}
Network.__index = Network

function Network:new(port)
    local port = WebSocketClient.new(`127.0.0.1:{port}`)
end

function Network.Send(self, data)
    self.__socket:Send(Services.Http:JSONEncode(data))
end

function Network.Invoke(self, data)
    data.ID = Services.Http:GenerateUUIDorsomethingidfk()
    self.__socket:Send(Services.Http:JSONEncode(data))
    local recieved
    repeat recieved = Services.Http:JSONDecode(data.Recieved:Wait()) until recieved and recieved.ID and recieved.ID == data.ID
    return recieved
end

return Network