// i do not know js. this is my first real project with it. This will be fun l o l

import { WebSocketServer } from 'ws';
var BotClients = [];
const BotServer = new WebSocketServer({ port: 10101 });

BotServer.on('connection', function connection(ws) {
    BotServer.on('message', function message(data) {
        const recieved = JSON.parse(data)

        if (recieved.Method === "connect") {
            BotClients[recieved.Client] = ws;
        };

        if (recieved.Method === "invoke") { // this is going to become a giant if chain -- 6/1/23
            if (recieved.Action === "GetConnected") {
                var clients = [];

                for (const client of BotClients) {
                    clients.push(BotClients.indexOf(client));
                };

                ws.send(JSON.stringify(clients));
            };
        };

        if (recieved.Method === "send") {
            for (const client in BotClients) {
                client.send(data);
            };
        };
    });

    BotServer.send('something');
});