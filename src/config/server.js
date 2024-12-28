const serverConfig = {
  port: process.env.PORT || 3000,
  // MT4 服务器配置
  mt4Server: {
    port: 443,
    symbols: [
      {
        name: 'BTCUSD',
        digits: 2,
        spread: 1,
        stopLevel: 5,
        lotSize: 1,
      },
      {
        name: 'ETHUSD',
        digits: 2,
        spread: 1,
        stopLevel: 5,
        lotSize: 1,
      },
      {
        name: 'BNBUSD',
        digits: 2,
        spread: 1,
        stopLevel: 5,
        lotSize: 1,
      }
    ]
  }
};

module.exports = serverConfig;