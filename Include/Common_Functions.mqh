//+------------------------------------------------------------------+
//|                                             Common_Functions.mqh |
//|                                                     Syahmul Aziz |
//|                                      https://www.SyahmulAziz.com |
//+------------------------------------------------------------------+
#property copyright "Syahmul Aziz"
#property link      "https://www.SyahmulAziz.com"
#property strict
//+------------------------------------------------------------------+

double get_pip_value (){
   if (_Digits >= 4) return 0.0001;
   else return 0.01;
}

double calculate_take_profit (bool is_long, int take_profit_pips) {
   if (is_long) 
      return Ask + take_profit_pips * get_pip_value();
   else 
      return Bid - take_profit_pips * get_pip_value();
}

//Calculate TP based on the RR.
double calculate_take_profit (bool is_long, double stop_loss, double entry_price, int reward_ratio) {
   int sl_pip_distance = CalculatePips(stop_loss, entry_price);
   int take_profit_pips = sl_pip_distance * reward_ratio;
   
   if (is_long)
      return Ask + take_profit_pips * get_pip_value();
   else 
      return Bid - take_profit_pips * get_pip_value();
}

double calculate_stop_loss (bool is_long, int stop_loss_pips) {
   if (is_long) 
      return Ask - stop_loss_pips * get_pip_value();
   else 
      return Bid + stop_loss_pips * get_pip_value();
}

bool is_trading_allowed(){
   if (!IsTradeAllowed()) {
      Comment("EA is NOT allowed to trade. Check AutoTrading.");
      return false;
   }
   
   if (!IsTradeAllowed(Symbol(), TimeCurrent())) {
      Comment("EA is NOT allowed for " + Symbol() + " at this time.");
      return false;
   }
   
   return true;
}

double OptimalLotSize(double maxRiskPrc, int maxLossInPips) {

  double accEquity = AccountEquity();
  double lotSize = MarketInfo(NULL,MODE_LOTSIZE);
  double tickValue = MarketInfo(NULL,MODE_TICKVALUE);
  //double tickValue = MarketInfo(NULL, MODE_MARGINREQUIRED);  // Use MODE_MARGINREQUIRED to get tick value for XAUUSD
  
  if(Digits <= 3) {
     tickValue = tickValue / 100;
  }
  
  double maxLossDollar = accEquity * maxRiskPrc;
  double maxLossInQuoteCurr = maxLossDollar / tickValue;
  double optimalLotSize = NormalizeDouble(maxLossInQuoteCurr /(maxLossInPips * get_pip_value())/lotSize,2);
  
  return optimalLotSize;
}


double OptimalLotSize(double maxRiskPrc, double entryPrice, double stopLoss)
{
   int maxLossInPips = MathAbs(entryPrice - stopLoss)/get_pip_value();
   return OptimalLotSize(maxRiskPrc,maxLossInPips);
}

bool  CheckIfOpenOrdersByMagicNumber (int magicNumber) {
   int totalOrders = OrdersTotal();
   
   for(int i=0; i< totalOrders; i++) {
      if(OrderSelect(i, SELECT_BY_POS)) {
         if (OrderMagicNumber() == magicNumber) {
            return true;
         }
      }
   }
   
   return false;
}

//Generata a random magic number automatically
int GenerateRandomMagicNumbers(int count) {
    int maxMagicNumber = 1000000; // You can adjust this range as needed
    string magicNumbers = "";
    MathSrand((int)TimeCurrent()); // Seed the random number generator with the current time
    
    for (int i = 0; i < count; i++) {
        magicNumbers +=(string) (MathRand() % maxMagicNumber); // Generate and store a random number
    }
    return (int) magicNumbers;
}

//calculates the number of pips between two prices
int CalculatePips(double price1, double price2) {
    double point = MarketInfo(Symbol(), MODE_POINT);
    double difference = MathAbs((price1 - price2) / point);
    return (int)difference/10;
}