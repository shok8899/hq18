const WebSocket = require('ws');

class MT4Service {
  constructor() {
    this.clients = new Set();
  }

  // 处理新的MT4客户端连接
  handleConnection(ws) {
    this.clients.add(ws);
    
    ws.on('close', () => {
      this.clients.delete(ws);
    });

    ws.on('error', (error) => {
      console.error('MT4客户端连接错误:', error);
      this.clients.delete(ws);
    });
  }

  // 向所有连接的MT4客户端广播价格更新
  broadcastPrice(symbol, price) {
    const message = JSON.stringify({
      type: 'price',
      symbol,
      price: parseFloat(price)
    });

    this.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(message);
      }
    });
  }
}

module.exports = new MT4Service();