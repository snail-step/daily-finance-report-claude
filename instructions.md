## Pre-flight check — Monday extended window
If today is **Monday** (Taiwan Time, UTC+8): expand **all** news search windows to **72 hours** (covering Friday–Monday). Replace every mention of "past 18 hours" with "past 72 hours" for today only.
All other weekdays: proceed normally with 18-hour news windows.

---

Step 1 — Price snapshot
Using the FMP MCP, fetch the CURRENT price and 1-day % change for:
  US broad ETFs  : SPY, VT, VEA, IWY, SPMO
  US sector ETFs : NASA, UFO, IAU, GLD, XLE, VDE, SPCX
  US equities    : GOOG, ORCL, LHX, PURR, AAPL
  Crypto         : BTC/USD
  FX             : USD/TWD, DXY (US Dollar Index)
  Taiwan ETFs    : 0050.TW, 00910.TW, 00947.TW
  Taiwan stocks  : 2330.TW, 2454.TW, 2464.TW
  Taiwan index   : ^TWII (TAIEX)

**Fallback rule (applies to every ticker automatically):**
After each FMP fetch, evaluate the result:
- If price is null / N/A / empty → **stale or unsupported**
- If the price timestamp is older than 3 trading days → **stale**

For any stale/unsupported result, run a web search fallback:
- Taiwan-listed tickers (suffix `.TW`): `web_search("{TICKER} 股價 site:tw.stock.yahoo.com OR site:cnyes.com")`
- All other tickers: `web_search("{TICKER} current price")`

Extract the most recent price and its date from the search result. In the report, always label the source and date for any fallback price (e.g. "NT$113.50 as of 2026-06-13 (web)").

Store all values in a variable called PRICES.

Step 2A — Macro & Sector Trends (past 18 hours only, or 72 hours on Monday)
Run these broad market searches in parallel:

a) "crypto regulation bitcoin DeFi market"
b) "AI capex data center chips market"
c) "defense space satellite contracts"
d) "Fed rates Taiwan semiconductor macro"
e) "global ETF flows VT VEA"
f) "gold ETF dollar inflation"
g) "energy ETF oil gas prices"
h) "Taiwan semiconductor TSMC MediaTek"


Step 2B — Position-Specific News (past 18 hours only, or 72 hours on Monday)
Run these ticker-focused searches in parallel:

1) "SPY S&P 500 market news"
2) "VT VEA ETF flows"
3) "IWY SPMO growth momentum ETF"
4) "NASA UFO space ETF news"
5) "IAU GLD gold ETF news"
6) "XLE VDE energy ETF news"
7) "GOOG Alphabet AI news"
7b) "AAPL Apple earnings product news"
8) "ORCL Oracle earnings guidance"
9) "LHX defense contract news"
10) "PURR HYPE Hyperliquid news"
10b) "SPCX SPAC new issue ETF news"
11) "BTC bitcoin overnight news"
12) "USD TWD dollar policy Fed"
13) "TAIEX Taiwan stock market news"
14) "0050 00910 00947 Taiwan ETF news"
15) "2330.TW TSMC news"
16) "2454.TW MediaTek news"
17) "2464.TW Mirle news"

For each category, extract:
  - 1–2 sentence summary of the most market-moving development
  - Sentiment: BULLISH / NEUTRAL / BEARISH
  - Confidence: HIGH / MED / LOW
  - 在英文原文下面，翻譯一個中文版（英文保留不刪）

Skip any result older than 18 hours (or 72 hours on Monday). If nothing is found, write "No material news."

Step 3 — Decision signal
For each position, combine price data from Step 1 and news sentiment from Step 2 using these rules:

**Signal logic (apply the highest-severity rule that matches):**

| Condition | Signal |
|-----------|--------|
| BEARISH sentiment (HIGH or MED confidence) **OR** 1D price change ≤ −3% **OR** thesis-breaking news | 🔴 REVIEW |
| NEUTRAL sentiment **OR** BULLISH with LOW confidence **OR** −1% < 1D price ≤ −3% **OR** notable new development with unclear impact | 🟡 WATCH |
| BULLISH sentiment (HIGH or MED confidence) **AND** 1D price change > −1% **AND** no new material risk | 🟢 HOLD/ADD |
| Insufficient data (price N/A and no news) | 🟡 WATCH (default; note data gap) |

If the 1D price change is unavailable (N/A), weight sentiment alone and note the data gap.

Also output one "Focus today" item: the single asset most likely to require attention today, with a one-line reason.


Step 4 — Assemble report
Generate a Markdown file with this exact structure:

# Morning Market Brief — {YYYY-MM-DD} 05:00 TWN

## 🎯 Focus today
{one sentence from Step 3}

  - 在英文原文下面，翻譯一個中文版（英文保留不刪）

## 📊 Price snapshot
| Asset (Ticker) | Fund Name | Price | 1D % | Signal |
|-------|-----------|-------|------|--------|
(fill from PRICES + signals)

## 📰 News highlights
  - 關於以下內容：在英文原文下面，翻譯一個中文版（英文保留不刪）

### Macro & Sector Trends
#### a) "crypto regulation bitcoin DeFi market"
#### b) "AI capex data center chips market"
#### c) "defense space satellite contracts"
#### d) "Fed rates Taiwan semiconductor macro"
#### e) "global ETF flows VT VEA"
#### f) "gold ETF dollar inflation"
#### g) "energy ETF oil gas prices"
#### h) "Taiwan semiconductor TSMC MediaTek"

### Position Highlights
#### SPY / VT / VEA / IWY / SPMO — {signal}
{summary}

#### NASA / UFO — {signal}
{summary}

#### IAU / GLD — {signal}
{summary}

#### XLE / VDE — {signal}
{summary}

#### GOOG / ORCL / LHX / PURR / AAPL — {signal}
{summary}

#### SPCX — {signal}
{summary}

#### BTC  — {BULLISH/NEUTRAL/BEARISH}
{1–2 sentence summary}

#### USD/TWD / DXY — {signal}
{summary}

#### 0050.TW / 00910.TW / 00947.TW — {signal}
{summary}

#### 2330.TW / 2454.TW / 2464.TW — {signal}
{summary}

... (repeat for all tracked assets) ...

## 💡 Key risk today
{1 sentence: biggest macro or position-specific risk to watch}

---
*Auto-generated by Morning Market Brief routine. Not financial advice.*

Save the file as reports/{YYYY-MM-DD}-brief.md and commit to the default branch.
Push directly to main (not a feature branch) — do not create a PR.
Then save the full report content to github repo (if possible) #morning-brief.
