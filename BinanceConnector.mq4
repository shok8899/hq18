//+------------------------------------------------------------------+
//|                                              BinanceConnector.mq4   |
//|                                          Copyright 2023, Your Name  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023"
#property link      ""
#property version   "1.00"
#property strict

// 外部参数
extern string WebSocketURL = "ws://localhost:3000"; // WebSocket服务器地址
extern int ReconnectDelay = 5000;                  // 重连延迟(毫秒)

// 全局变量
int socketHandle = -1;
bool isConnected = false;
double binancePrices[][2];  // 存储币安价格 [symbol_index][bid/ask]
string symbols[] = {"BTCUSDT", "ETHUSDT", "BNBUSDT"};

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit() {
   // 初始化价格数组
   ArrayResize(binancePrices, ArraySize(symbols));
   
   // 连接WebSocket服务器
   ConnectWebSocket();
   
   // 创建图表对象显示价格
   CreatePriceLabels();
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   if(socketHandle >= 0) {
      SocketClose(socketHandle);
   }
   DeletePriceLabels();
}

//+------------------------------------------------------------------+
//| Expert tick function                                               |
//+------------------------------------------------------------------+
void OnTick() {
   if(!isConnected) {
      ConnectWebSocket();
      return;
   }
   
   // 接收并处理WebSocket消息
   string message;
   while(SocketIsConnected(socketHandle) && 
         SocketRead(socketHandle, message, 1024) > 0) {
      ProcessMessage(message);
   }
   
   // 更新价格显示
   UpdatePriceLabels();
}

//+------------------------------------------------------------------+
//| 连接WebSocket服务器                                               |
//+------------------------------------------------------------------+
void ConnectWebSocket() {
   if(socketHandle >= 0) {
      SocketClose(socketHandle);
   }
   
   socketHandle = SocketCreate();
   
   if(socketHandle < 0) {
      Print("Socket creation failed");
      return;
   }
   
   if(!SocketConnect(socketHandle, WebSocketURL, 3000)) {
      Print("Socket connection failed");
      return;
   }
   
   isConnected = true;
   Print("Connected to WebSocket server");
}

//+------------------------------------------------------------------+
//| 处理接收到的消息                                                  |
//+------------------------------------------------------------------+
void ProcessMessage(string message) {
   // 解析JSON消息
   JSONParser parser;
   JSONValue jValue;
   
   if(!parser.parse(message, jValue)) {
      Print("JSON parsing failed: ", message);
      return;
   }
   
   string symbol = jValue["symbol"].toString();
   double price = jValue["price"].toDouble();
   
   // 更新价格数组
   for(int i=0; i<ArraySize(symbols); i++) {
      if(symbols[i] == symbol) {
         binancePrices[i][0] = price; // bid
         binancePrices[i][1] = price; // ask
         break;
      }
   }
}

//+------------------------------------------------------------------+
//| 创建价格标签                                                      |
//+------------------------------------------------------------------+
void CreatePriceLabels() {
   for(int i=0; i<ArraySize(symbols); i++) {
      string labelName = "Binance_" + symbols[i];
      ObjectCreate(0, labelName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, labelName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, 10);
      ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, 20 + i*20);
   }
}

//+------------------------------------------------------------------+
//| 更新价格标签                                                      |
//+------------------------------------------------------------------+
void UpdatePriceLabels() {
   for(int i=0; i<ArraySize(symbols); i++) {
      string labelName = "Binance_" + symbols[i];
      string priceText = symbols[i] + ": " + 
                        DoubleToString(binancePrices[i][0], 2);
      ObjectSetString(0, labelName, OBJPROP_TEXT, priceText);
   }
}

//+------------------------------------------------------------------+
//| 删除价格标签                                                      |
//+------------------------------------------------------------------+
void DeletePriceLabels() {
   for(int i=0; i<ArraySize(symbols); i++) {
      string labelName = "Binance_" + symbols[i];
      ObjectDelete(0, labelName);
   }
}