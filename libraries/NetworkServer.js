// i do not know js. this is my first real project with it. This will be fun l o l

import { WebSocketServer } from 'ws';
var BotClients = [];
const BotServer = new WebSocketServer({ port: 10101 });

BotServer.on('connection', (ws) => {
    ws.on('message', (data) => {
        const recieved = JSON.parse(data)

        if (recieved.Method === "invoke" && recieved.Data) { // this is going to become a giant if chain -- 6/1/23
            if (recieved.Data.Action === "GetConnected") {
                var clients = [];

                for (const client of BotClients) {
                    clients.push(BotClients.indexOf(client));
                };

                ws.send(JSON.stringify([ID = recieved.ID, Return = clients]));

                return;
            };

            if (recieved.Data.Action === "Connect") {
                BotClients[recieved.Client] = ws;
                ws.send(JSON.stringify([ID = recieved.ID, Return = true]));

                return;
            };
        };

        if (recieved.Method === "send") {
            for (const client in BotClients) {
                client.send(data);
            };
        };
    });
});