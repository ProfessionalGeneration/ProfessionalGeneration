// i do not know js. this is my first real project with it. This will be fun l o l
// i debug when me home get >:33333333333
import { WebSocketServer } from 'ws';
var BotClients = [];
const BotServer = new WebSocketServer({ port: 10101 });
const AccountServer = new WebSocketServer({ port: 20202 });
const BotMethods = [
    invoke = (ws, data) => {
        data = JSON.parse(data);

        if (data.Method === "invoke" && data.Data) {
            if (data.Data.Action === "GetConnected") {
                var clients = [];

                for (const client of BotClients) {
                    clients.push(BotClients.indexOf(client));
                }
                BotClients[data.Client] = ws;

                return JSON.stringify([ID = recieved.ID, Return = true]);
            };
        };
    },
    send = (data) => {
        for (const client in BotClients) {
            client.send(data);
        };
    },
    sendclient = (data) => {
        clients[JSON.parse(data).Reciever].send(data);
    }
];

BotServer.on('connection', (ws) => {
    ws.on('message', (data) => {
        const sendback = BotMethods[recieved.Method](data);

        if (sendback != null) {
            ws.send(sendback);
        };
    });
});

AccountServer.on('connection', (ws) => {
    ws.on('message', (data) => {

    });
});