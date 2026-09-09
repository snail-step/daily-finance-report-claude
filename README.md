# Codex Desktop Daily Finance Report

A Codex desktop task that generates a daily morning market briefing, used to track custom stocks, ETFs, cryptocurrencies, exchange rates, and regional market instruments.

## Manual Setup
- **Market data**: FMP is preferred when configured. If it is unavailable, the task uses live web price sources and labels the source and date.
- **Codex Desktop Schedule**: Set a Codex desktop scheduled task for **weekdays at 05:00 Taiwan time**. The Mac must be awake, online, signed in, and running Codex.
- **Tracked Instruments**: Adjust the tracked instruments and news search keywords in `instructions.md` according to your own portfolio.
- **Git authentication**: Configure local Git authentication with write access to this repo. Claude GitHub App authorization is not used by the desktop workflow. Verify access before the initial report run.

## `instructions.md` Rules
- **Monday News Window**: Automatically extends to 72 hours (covering Friday through Monday); other weekdays use 18 hours.
- **Price Fallback**: Every FMP result is automatically validated — if it's N/A or the timestamp is more than 3 trading days old, automatically fall back to `web_search`; for `.TW` tickers, prioritize searching Yahoo Finance TW / CNYES (鉅亨網).
- **Fallback Labeling**: For any price sourced from something other than FMP, the report must clearly indicate the source and date (e.g., `NT$113.50 as of 2026-06-13 (web)`).
- **Signal Logic** (applied in order of severity):
  - 🔴 `REVIEW`: BEARISH (HIGH/MED confidence) **OR** 1D ≤ −3% **OR** thesis-breaking news
  - 🟡 `WATCH`: NEUTRAL **OR** BULLISH (LOW confidence) **OR** −3% < 1D ≤ −1% **OR** new developments with unclear impact
  - 🟢 `HOLD / ADD`: BULLISH (HIGH/MED) **AND** 1D > −1% **AND** no new risks
  - 🟡 `WATCH` (default): Insufficient price and news data — flag the data gap

## Output
The report is output to:
```text
reports/{YYYY-MM-DD}-brief.md
```
- The English summary is retained, with a Traditional Chinese translation appended below.
- The content produced by this routine is for informational purposes only and does not constitute investment advice.


## Codex desktop workflow

The desktop workflow preserves the original research rules and report history. No GitHub Actions workflow is required.

Each run reads `instructions.md`, fetches current prices and news, writes `reports/YYYY-MM-DD-brief.md`, commits that report, and pushes `main`. It skips the run if that date's report already exists.

Run `./scripts/setup-local.sh` once in the checkout to select the `snail-step` GitHub SSH identity and repo-local commit author. Keep the Mac awake, connected, and the app running during scheduled execution.
