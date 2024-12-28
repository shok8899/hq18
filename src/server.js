const express = require('express');
const WebSocket = require('ws');
const binanceService = require('./services/binanceService');
const mt4Service = require('./services/mt4Service');

const app = express();
const port = process.env.PORT || 3000;

// 创建WebSocket服务器
const wss = new WebSocket.Server({ noServer: true });

// 处理WebSocket连接
wss.on('connection', (ws) => {
  mt4Service.handleConnection(ws);
});

// 启动价格流
binanceService.startPriceStream((symbol, price) => {
  mt4Service.broadcastPrice(symbol, price);
});

// 启动HTTP服务器
const server = app.listen(port, () => {
  console.log(`服务器运行在端口 ${port}`);
});

// 将WebSocket服务器附加到HTTP服务器
server.on('upgrade', (request, socket, head) => {
  wss.handleUpgrade(request, socket, head, (ws) => {
    wss.emit('connection', ws, request);
  });
});