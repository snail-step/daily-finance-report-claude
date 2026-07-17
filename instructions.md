# Morning Market Brief — routine instructions

## Pre-flight — Monday extended window
Resolve "now" in Taiwan Time (UTC+8). The news window is a single variable `WINDOW`:
- **Monday**: `WINDOW = 72h` (covers Friday–Monday).
- **All other weekdays**: `WINDOW = 18h`.

Every "past WINDOW" reference below uses this one value. Do not hard-code hours anywhere else.

---

## Tracked universe (single source of truth)
Every step below (prices, news, report) iterates over these blocks. Do not research or report any ticker outside this table.

| # | Block | Tickers | Role |
|---|-------|---------|------|
| 1 | US broad market | SPY, SPMO | Beta + momentum factor |
| 2 | Space & defense | NASA, UFO | Thematic space/defense |
| 3 | Energy | XLE, VDE | Oil & gas sector |
| 4 | US single stocks | ORCL, AAPL, TSLA | Idiosyncratic large caps |
| 5 | SpaceX | SPCX | Speculative sleeve |
| 6 | **Semiconductor / AI supply chain (半導體產業鏈)** | see sub-tiers below | Core theme — research deepest |
| 7 | Crypto | BTC/USD | — |
| 8 | FX & rates | USD/TWD | Fed / dollar / TWD |
| 9 | Taiwan ETFs | 0050.TW, 00947.TW | Taiwan beta |
| 10 | Taiwan single stocks | 2464.TW (Mirle 盟立) | Idiosyncratic |
| 11 | Taiwan index | ^TWII (TAIEX 加權指數) | Benchmark |
| 12 | Gold (price watch only) | IAU, GLD | no news research |

**Block 6 — semiconductor / AI supply chain, by tier:**
| Tier | Tickers |
|------|---------|
| 上游 Upstream — 設計 / IP / 設備 / 記憶體 | NVDA, ARM, ASML, MU (Micron 美光), 2454.TW (MediaTek 聯發科), 2408.TW (Nanya 南亞科) |
| 中游 Midstream — 晶圓代工 | 2330.TW (TSMC 台積電) |
| 下游 Downstream — 伺服器 / 組裝 / 零組件 | 2308.TW (Delta 台達電), 2317.TW (Hon Hai 鴻海), 2382.TW (Quanta 廣達), 6669.TW (Wiwynn 緯穎), 2327.TW (Yageo 國巨), 2368.TW (GCE 金像電), 2383.TW (EMC 台光電) |
| 需求端 Hyperscalers — 雲端 / AI capex | GOOG, META, AMZN, MSFT |

---

## Data-quality markers (use everywhere)
When data is missing, incomplete, or too old, never guess or leave a cell blank — write one of these exact markers:
- `No material news.` — no relevant news found inside `WINDOW`.
- `stale` — a value exists but is out of date (price older than 3 trading days, or the only news available is older than `WINDOW`). Show the value together with the marker and its date, e.g. `NT$113.50 · 2026-06-13 · stale`.
- `data gap` — data could not be obtained at all (null/unavailable even after fallback, or an API error).

Any `stale` or `data gap` on a block feeds the data-gap handling in Step 3.

---

## Step 1 — Prices
1. Fetch CURRENT price + 1-day % change for **every** ticker in the universe in **one parallel batch** via the FMP MCP. Do not fetch one at a time.
2. Fallback only when a result is bad (do not web-search tickers FMP already returned cleanly):
   - Bad = price is null / N/A / empty, **or** timestamp older than 3 trading days.
   - Taiwan tickers (`.TW`): `web_search("{TICKER} 股價 site:tw.stock.yahoo.com OR site:cnyes.com")`
   - Others: `web_search("{TICKER} current price")`
   - Take the most recent price + date; in the report label it as fallback, e.g. `NT$113.50 · 2026-06-13 (web)`.
   - If the fallback returns only an out-of-date price, show it with the `stale` marker; if it returns nothing at all, write `data gap` in both the Price and 1D% cells. (See Data-quality markers.)
3. Store everything in `PRICES`.

## Step 2 — News research (grouped, one parallel pass)
Run the queries below **once, all in parallel**. The plan is organised by block so that macro/sector context and single-name news are gathered together — there is no separate macro step and no cross-referencing.

**Efficiency rules (深入但不繞路):**
- One pass. Only re-query a topic if it returned nothing usable, and then at most **one** refined retry.
- Keep only results inside `WINDOW`; discard older hits immediately.
- Stop scanning a query once you have its most market-moving item (≈ top 5 results is enough).
- Spend depth where it matters: block 6 gets the most queries; single-name blocks get one each.

| Block | Queries |
|-------|---------|
| 1 US broad market | `"S&P 500 market breadth + global equity ETF flows"` |
| 2 Space & defense | `"space defense satellite ETF contracts NASA UFO"` |
| 3 Energy | `"energy sector oil gas prices XLE VDE"` |
| 4 US single stocks | `"ORCL Oracle earnings guidance"` · `"AAPL Apple product earnings"` · `"TSLA Tesla news"` |
| 5 SpaceX | `"SPCX SpaceX Space Exploration Technologies news"` |
| 6 上游 Upstream | `"NVDA Nvidia AI GPU demand"` · `"ASML ARM lithography chip IP equipment"` · `"MU Micron 2408 Nanya memory HBM DRAM"` · `"2454 MediaTek news"` |
| 6 中游 Midstream | `"2330 TSMC foundry demand pricing"` |
| 6 下游 Downstream | `"Taiwan AI server supply chain Hon Hai Quanta Wiwynn"` · `"Delta Electronics Yageo components 台達電 國巨"` · `"2368 金像電 2383 台光電 AI server PCB CCL"` |
| 6 需求端 Hyperscalers | `"GOOG META AMZN MSFT AI capex cloud"` |
| 7 Crypto | `"crypto market news today bitcoin ethereum"` · `"crypto regulation policy news"` · `"bitcoin ethereum spot ETF flows institutional"` · `"crypto exchange stablecoin depeg insolvency hack exploit"` |
| 8 FX & rates | `"USD TWD Fed rate policy dollar"` |
| 9 Taiwan ETFs | `"0050 00947 Taiwan ETF flows"` |
| 10 Taiwan single stocks | `"2464 Mirle 盟立 news"` |
| 11 Taiwan index | `"TAIEX Taiwan stock market"` · `"台股 三大法人 買賣超 site:tw.stock.yahoo.com OR site:cnyes.com"` |
| 12 Gold | _price watch only — no news query_ |

For each block, distil (not per query — **per block**):
- **Development**: 1–2 sentences on the single most market-moving item.
- **Sentiment**: BULLISH / NEUTRAL / BEARISH.
- **Confidence**: HIGH / MED / LOW.
- Data quality (see Data-quality markers): nothing inside `WINDOW` → `No material news.`; only older-than-`WINDOW` items available → note it with `stale`; a source/query failed entirely → `data gap`.

**Block 7 extra — impact scoring for crypto news:**
- For regulatory items, first tag the stage: rumor / proposed / committee passed / floor passed / signed into law. The later the stage, the larger the impact — but if the outcome was widely expected, passage itself may be priced in ("sell the news").
- Impact = scope (whole market > sector > single coin) × certainty (done deal > in progress > rumor) × novelty (not yet priced in).
- Validate against BTC 1D% and spot-ETF flows: a major headline with no price reaction → treat as already digested and downgrade Confidence by one level.
- If BTC 1D% swings beyond ±5%, check whether a derivatives liquidation cascade (mass liquidations, extreme funding rates) drove the move — cascade-driven moves often retrace, so note it and cap Confidence at MED.

**Block 11 extra — institutional flows (三大法人買賣超):**
- From the 三大法人 query, extract the **previous trading day's** figures for each of the three — 外資 (foreign investors), 投信 (investment trusts), 自營商 (dealers) — with **buy amount (買進) and sell amount (賣出) listed separately**, plus the net (買賣超), in NT$億.
- Always show the data date. If the latest available figures are older than the previous trading day, mark `stale`; if unobtainable, `data gap` (see Data-quality markers).
- Output the usual Sentiment + Confidence (HIGH/MED/LOW) so it feeds Step 3 unchanged.

## Step 3 — Signal
For each block (and each tier of block 6), combine `PRICES` 1D% with news sentiment. Apply the highest-severity rule that matches:

| Condition | Signal |
|-----------|--------|
| BEARISH (HIGH/MED) **OR** 1D% ≤ −3% **OR** thesis-breaking news | 🔴 REVIEW |
| NEUTRAL **OR** BULLISH-LOW **OR** −3% < 1D% ≤ −1% **OR** notable but unclear-impact news | 🟡 WATCH |
| BULLISH (HIGH/MED) **AND** 1D% > −1% **AND** no new material risk | 🟢 HOLD/ADD |
| price N/A **and** no news | 🟡 WATCH (note data gap) |

If 1D% is N/A, weight sentiment alone and note the gap.
Then pick one **Focus today**: the single asset most likely to need attention, with a one-line reason.

## Step 4 — Report
All timestamps in Taiwan Time (UTC+8). **Bilingual rule for every summary/narrative in the report: English original first, 中文翻譯 directly below (英文保留不刪).**

Write the file to `reports/{YYYY-MM-DD}-brief.md` with exactly this structure:

```markdown
# Morning Market Brief — {YYYY-MM-DD} HH:mm dddd (Taiwan Time)

## 🎯 Focus today
{one sentence — EN}
{中文}

## 📊 Price snapshot
| Block | Asset (Ticker) | Name | Price | 1D % | Signal |
|-------|----------------|------|-------|------|--------|
{one row per ticker, ordered by the universe blocks 1→12; block 6 grouped by tier.
Bad data uses the markers `stale` / `data gap` in the affected cell — never blank.}

Signal legend: 🟢 HOLD/ADD · 🟡 WATCH · 🔴 REVIEW · data: `No material news.` / `stale` / `data gap`

## 🔍 Analysis by theme
{One subsection per block, in universe order. Prices already shown above — do NOT repeat
price tables here; give signal + development narrative only.}

### 1) US broad market — SPY / SPMO · {signal}
{EN development}
{中文}

### 2) Space & defense — NASA / UFO · {signal}
...

### 3) Energy — XLE / VDE · {signal}
...

### 4) US single stocks — ORCL / AAPL / TSLA · {signal}
...

### 5) SpaceX — SPCX · {signal}
...

### 6) 半導體產業鏈 Semiconductor / AI supply chain
#### 上游 Upstream · NVDA / ARM / ASML / MU / 2454.TW / 2408.TW · {signal}
...
#### 中游 Midstream · 2330.TW · {signal}
...
#### 下游 Downstream · 2308.TW / 2317.TW / 2382.TW / 6669.TW / 2327.TW / 2368.TW / 2383.TW · {signal}
...
#### 需求端 Hyperscalers · GOOG / META / AMZN / MSFT · {signal}
...

### 7) Crypto — BTC · {sentiment}
...

### 8) FX & rates — USD/TWD · {signal}
...

### 9) Taiwan ETFs — 0050.TW / 00947.TW · {signal}
...

### 10) Taiwan single stocks — 2464.TW · {signal}
...

### 11) Taiwan index — ^TWII · {signal}
{EN development}
{中文}
三大法人買賣金額（{data date}）：
| 法人 | 買進 | 賣出 | 買賣超 |
|------|------|------|--------|
| 外資 | NT$xx億 | NT$xx億 | ±NT$xx億 |
| 投信 | NT$xx億 | NT$xx億 | ±NT$xx億 |
| 自營商 | NT$xx億 | NT$xx億 | ±NT$xx億 |

### 12) Gold — IAU / GLD · {signal}
...

## 💡 Key risk today
{1 sentence: biggest macro or position risk — EN}
{中文}

---
*Auto-generated by Morning Market Brief routine. Not financial advice.*
```

## Git workflow
- Develop and commit on the current working branch, following the harness's routine git policy.
- After the work is complete, automatically merge/fast-forward the working branch into `main` and push `main`. Do this automatically, without asking.
- End the commit message with this trailer on its own line:
  `Co-Authored-By: Claude <noreply@anthropic.com>`

## Hard constraints (do NOT violate)
- Do NOT open a pull request. Do NOT create a GitHub issue.
- Do NOT run `gh issue create`, `gh pr create`, or any GitHub API / `gh` command.
