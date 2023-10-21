# RSI-Bands-Breaker

<b>Objective: </b> Trade AUD/JPY profitably. May work on other currency pairs as well.

<b>Strategy Type:</b> Breakout Trading

<b>Timeframe:</b> 1-Hour (H1) or 4-Hour (H4)

<b>Indicators</b>:
1. Bollinger Bands (20 periods, 2 standard deviations)
2. Relative Strength Index (RSI, 14 periods)
3. Moving Average (50-period Simple Moving Average)

<b>Entry Rules:</b>
1. <b>Bollinger Bands Squeeze:</b> Wait for the Bollinger Bands to contract significantly, indicating a period of low volatility. A squeeze must not be more than X distance defined by the user. Default to 20 pips.
2. <b>RSI Confirmation:</b> When the Bollinger Bands contract, check the RSI. For long trades, the RSI should be above 50, and for short trades, the RSI should be below 50.
3. <b>Breakout Confirmation:</b> Once the Bollinger Bands expand after a squeeze, place a buy order if the price breaks above the upper Bollinger Band for a long trade, or place a sell order if the price breaks below the lower Bollinger Band for a short trade.
4. <b>50 SMA Confirmation:</b> Before executing the trade, you should also confirm the direction of the 50 SMA. The 50 SMA acts as a trend filter to ensure that your trade aligns with the longer-term trend. If the 50 SMA is sloping upwards, it confirms the bullish trend for a long trade, and if it's sloping downwards, it confirms the bearish trend for a short trade.

<b>Position Sizing</b>: Risk no more than a predetermined percentage of your trading capital on each trade (e.g., 1-2%).

<b>Stop-Loss and Take-Profit:</b>
1. Set a fixed stop-loss level just beyond the opposite Bollinger Band (opposite to your trade direction) from your entry point.
2. Set a take-profit level based on your risk-reward ratio, typically aiming for a 2:1 or 3:1 risk-reward ratio.
