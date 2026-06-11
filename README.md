# Claude Finance Report

每日產生一份晨間市場簡報的 Claude routine，可用於追蹤自訂的股票、ETF、加密貨幣、匯率與區域市場標的。

沒錢 but 產業趨勢還是不能錯過的。

## Workflow

1. 使用 FMP MCP 抓取即時價格與 1 日漲跌幅。
2. 若 FMP 無法取得資料，改用 WebSearch 查詢最新價格。
3. 搜尋過去 18 小時內的市場新聞。
4. 依價格與新聞情緒產生操作訊號：
   - 🟢 `HOLD / ADD`
   - 🟡 `WATCH`
   - 🔴 `REVIEW`
5. 輸出雙語 Markdown 報告。

## Tracked Assets

如需使用此 routine，請依自己的投資組合在 `instructions.md` 中調整追蹤標的與新聞查詢關鍵字。

## Output

報告輸出至：

```text
reports/{YYYY-MM-DD}-brief.md
```

範例：

```text
reports/2026-06-11-brief.md
```

## Notes

- 新聞只採用過去 18 小時內的內容。
- 英文摘要需保留，並在下方附上繁體中文翻譯。
- 若價格或新聞來源互相矛盾，需在報告中明確標註。
- 本 routine 產出的內容僅供資訊參考，不構成投資建議。

