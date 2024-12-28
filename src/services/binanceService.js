const WebSocket = require('ws');
const config = require('../config/binance');

class BinanceService {
  constructor() {
    this.prices = {};
    this.ws = null;
  }

  startPriceStream(callback) {
    this.ws = new WebSocket(config.wsEndpoint);

    // 构建订阅消息
    const subscribeMsg = {
      method: 'SUBSCRIBE',
      params: config.symbols.map(symbol => `${symbol}@trade`),
      id: 1
    };

    this.ws.on('open', () => {
      console.log('Connected to Binance WebSocket');
      this.ws.send(JSON.stringify(subscribeMsg));
    });

    this.ws.on('message', (data) => {
      try {
        const trade = JSON.parse(data);
        if (trade.e === 'trade') {
          const symbol = trade.s;
          const price = trade.p;
          this.prices[symbol] = price;
          callback(symbol, price);
        }
      } catch (error) {
        console.error('Error processing message:', error);
      }
    });

    this.ws.on('error', (error) => {
      console.error('WebSocket error:', error);
      this.reconnect(callback);
    });

    this.ws.on('close', () => {
      console.log('WebSocket closed. Reconnecting...');
      this.reconnect(callback);
    });
  }

  reconnect(callback) {
    setTimeout(() => {
      this.startPriceStream(callback);
    }, 5000);
  }
}

module.exports = new BinanceService();