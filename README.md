# Claude Finance Report

每日產生一份晨間市場簡報的 Claude routine，可用於追蹤自訂的股票、ETF、加密貨幣、匯率與區域市場標的。

沒錢 but 產業趨勢還是不能錯過的。

## Manual Setup

- **FMP MCP**：需安裝並設定 Financial Modeling Prep MCP，提供即時報價來源。
- **Claude Routine Trigger**：在 Claude 排程中設定為 **平日 05:00 TWN**（週末不觸發，由排程本身控制，無需在 instructions 中另行判斷）。
- **追蹤標的**：依自己的投資組合在 `instructions.md` 中調整追蹤標的與新聞查詢關鍵字。

## `instructions.md` Rules

- **週一新聞窗口**：自動擴展至 72 小時（涵蓋週五至週一），其餘平日為 18 小時。
- **價格 Fallback**：每個 FMP 回傳結果皆自動驗證——若為 N/A 或時間戳超過 3 個交易日，自動改用 `web_search` 補抓；`.TW` 標的優先搜尋 Yahoo Finance TW / 鉅亨網。
- **Fallback 標注**：所有非 FMP 來源的價格，在報告中明確標示來源與日期（例如：`NT$113.50 as of 2026-06-13 (web)`）。
- **信號邏輯**（依嚴重程度優先套用）：
  - 🔴 `REVIEW`：BEARISH（HIGH/MED 信心）**或** 1D ≤ −3% **或** 論點破壞性新聞
  - 🟡 `WATCH`：NEUTRAL **或** BULLISH（LOW 信心）**或** −3% < 1D ≤ −1% **或** 影響不明的新動態
  - 🟢 `HOLD / ADD`：BULLISH（HIGH/MED）**且** 1D > −1% **且** 無新風險
  - 🟡 `WATCH`（預設）：價格與新聞皆不足，標注資料缺口

## Output

報告輸出至：

```text
reports/{YYYY-MM-DD}-brief.md
```

- 英文摘要保留，下方附繁體中文翻譯。
- 本 routine 產出內容僅供資訊參考，不構成投資建議。

