//+------------------------------------------------------------------+
//|                                            RSI Bands Breaker.mq4 |
//|                                                     Syahmul Aziz |
//|                                      https://www.SyahmulAziz.com |
//+------------------------------------------------------------------+
#property copyright "Syahmul Aziz"
#property link      "https://www.SyahmulAziz.com"
#property version   "1.00"
#property description "The EA mainly uses Bollinger Bands, RSI, and SMA./n"
                      "The objective of this EA is to trade AUD/JPY on H1./n"
#property strict
#property show_inputs
#include <Common_Functions.mqh>

//Bollinger Bands
//SL would either be set based on the upper band of the entry candle or the high of the previous candle if the the SL is more than 20 pips.
//If both SL is above 20 pips, take whichever is lower.
input int bb_period = 20;
input int bb_standard_deviation = 2;
double bb_upper_band;
double bb_lower_band;
int bb_shift = 1; //MA reading at 1 candle before the current candle.
int bar_shift = 0; //This is the shift of the indicator itself. Positive number will shift/draw the indicator to the right side of the current price.
input int bb_squeeze_pips = 20;  //BB squeeze distance between the upper and the lower band.
int bb_distance = 0; //Check for consolidation

//RSI
double rsi;
input int rsi_period = 14;
int rsi_shift = 1;

//SMA
double sma;
input int ma_period = 50;
int ma_shift = 1;

//Trade variables
extern int magicNumber = 21102023;
double stopLossPricePrevCandle; //SL based on the previous candle.
double stopLossBB;  //SL based on the upper/lower BB.
double stopLossPrice; //The SL that we chose after comparing both
double takeProfitPrice;
int takeProfitPips; //Is calculated based on the SL.
double lot_size = 0.03;
double entry_price = 0;
int order_id = 0;
extern float risk = 1; //1% risk
input int reward_ratio = 2; //Reward Ratio as compared to risk.
int openOrders = 0;
input int slippage = 10; //Slippage
double prev_candle_close;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//magicNumber = GenerateRandomMagicNumbers(6);
   risk /= 100;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
   openOrders = OrdersTotal(); //Check how many open orderrs
   prev_candle_close = iClose(NULL, PERIOD_CURRENT, 1);
   //current_candle_open = Open[0];

   //Bollinger Band
   bb_upper_band = iBands(NULL,PERIOD_CURRENT, bb_period, bb_standard_deviation, bb_shift, PRICE_CLOSE, MODE_UPPER, bar_shift);
   bb_lower_band = iBands(NULL,PERIOD_CURRENT, bb_period, bb_standard_deviation, bb_shift, PRICE_CLOSE, MODE_LOWER, bar_shift);

   //RSI
   rsi = iRSI(NULL, PERIOD_CURRENT, rsi_period, PRICE_CLOSE, rsi_shift);

   //SMA
   sma = iMA(NULL, PERIOD_CURRENT, ma_period, ma_shift, MODE_SMA, PRICE_CLOSE, ma_shift);

 
   //Check if we already have an open order? If no, we can assess if we need to open order.
   if(!CheckIfOpenOrdersByMagicNumber(magicNumber)) {
      bb_distance = CalculatePips(bb_upper_band, bb_lower_band); //Find consolidation
      //Assess the BB consolidation
    
      if(bb_distance <= bb_squeeze_pips) {
         if((prev_candle_close > bb_upper_band) && (rsi>50) && (sma>ma_period)) {
            stopLossPricePrevCandle = iLow(NULL, PERIOD_CURRENT,bb_shift) ; //High of one candle before the current candle.
            stopLossBB = bb_lower_band;
            entry_price = Ask;
            stopLossPrice = DecideSL(stopLossPricePrevCandle, stopLossBB, entry_price);
            takeProfitPrice = calculate_take_profit(true, stopLossPrice, entry_price, reward_ratio);

            //Send buy order
            lot_size = OptimalLotSize(risk,entry_price,stopLossPrice);
            order_id = OrderSend(Symbol(), OP_BUY, lot_size, entry_price, slippage, stopLossPrice, takeProfitPrice, NULL, magicNumber);
            
         } else if((prev_candle_close < bb_lower_band) && (rsi<50) && (sma<ma_period)){
               stopLossPricePrevCandle = iHigh(NULL, PERIOD_CURRENT,bb_shift) ; //High of one candle before the current candle.
               stopLossBB = bb_upper_band;
               entry_price = Bid;
               stopLossPrice = DecideSL(stopLossPricePrevCandle, stopLossBB, entry_price);
               takeProfitPrice = calculate_take_profit(false, stopLossPrice, entry_price, reward_ratio);

               //Send sell order
               lot_size = OptimalLotSize(risk,entry_price,stopLossPrice);
               order_id = OrderSend(Symbol(), OP_SELL, lot_size, entry_price, slippage, stopLossPrice, takeProfitPrice, NULL, magicNumber);
               
         }
        } //Assess consolidation
     } //Check open orders
  }
//+------------------------------------------------------------------+

//Something wrong with SL
//compare 2 SL, and decide which SL to use.
double DecideSL(double prev_candle_sl, double bb_sl, double entry_price)
  {
//First we need to find the pip distance.
   double prev_candle_sl_pip_distance = CalculatePips(prev_candle_sl, entry_price);
   double bb_sl_pip_distance = CalculatePips(bb_sl, entry_price);

//BB is within the BB squeeze range.
   if(bb_sl_pip_distance <= bb_squeeze_pips)
      return bb_sl;

//BB SL is big. Check if preious candle high is more than the BB squeeze range.
   else
      if(prev_candle_sl_pip_distance <= bb_squeeze_pips)
         return prev_candle_sl;

      //Previous candle SL is big too. Now, we check which SL is lower.
      else
         if(prev_candle_sl_pip_distance < bb_sl_pip_distance)
            return prev_candle_sl;
         else
            return bb_sl;
  }
//+------------------------------------------------------------------+
