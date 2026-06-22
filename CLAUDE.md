# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

渡辺花屋 (Watanabe Flower Shop) — a set of standalone static HTML pages, no build step, no package manager, no backend framework.

- `index.html` — the main product: a single-page inventory management app (在庫管理) for the flower shop. Vanilla HTML/CSS/JS in one file.
- `manual.html` — a static work manual page (棺前飾り作業マニュアル) for staff, unrelated to the inventory app's state.
- `shop.html` — a customer-facing shop introduction/landing page (店舗紹介サイト), styled to match `index.html`'s visual language but with no JS state — pure marketing content with placeholder copy/images until real shop details are supplied.
- `images/manual/` — reference photos used by `manual.html`.
- `deploy.ps1` — Windows PowerShell helper to push to GitHub and enable GitHub Pages via the `gh` CLI. Not needed for local development.

## Commands

There is no build, lint, or test tooling (no `package.json`, no `Makefile`). Everything is static HTML/CSS/JS opened directly or served as static files.

Run locally:
```bash
python3 -m http.server 8080
```
Then open `http://localhost:8080/index.html` (or `manual.html` / `shop.html`).

`index.html` can also be opened directly via `file://`, but the clipboard API and other browser features are more reliable over `http://localhost`.

Verification is manual in a browser — there are no automated tests:
- `index.html`: adjust stock with +/-, switch tabs/filters, confirm `localStorage` persistence across a refresh, and (if testing real-time sync) open the same `?room=` URL in two tabs.
- `shop.html`: check responsive layout (mobile nav toggle) and that anchor nav links scroll to the right section.

## Architecture: `index.html` (inventory app)

Everything lives in one file: inline `<style>`, inline `<script>`, no modules.

**Data model**
- `FLOWERS` (const): the catalog, grouped by category (`菊`, `ラン`, `ユリ`, `その他の花`, `グリーンなど`). Each entry has `id`, `name`, `emoji`, `unit`, `tab`. `ALL = Object.values(FLOWERS).flat()`.
- `customFlowers`: user-added flowers not in the static catalog, looked up via `byId()` which checks `ALL` then `customFlowers`.
- Mutable state: `stocks` (qty by id), `unitStocks` (unit override by id), `memos` (per-flower notes), `globalMemo`, `history` (action log), `currentTab`, `hideZero`.

**Persistence — two layers**
1. `localStorage` (always): keys are versioned (`wh_s_v4`, `wh_h_v4`, `wh_t_v4`, `wh_custom_v4`, `wh_units_v4`, `wh_memos_v4`, `wh_gmemo_v4`). `saveLocal()` / `loadLocal()` handle read/write. Bump the `_v4` suffix (and migrate) if the shape of persisted data changes.
2. Firebase Firestore (optional, real-time multi-device sync): only active if the `firebase` SDK is loaded; otherwise the app falls back to `setSyncDot("offline")` and stays local-only.
   - Each browser session joins a "room" via `?room=<id>` query param (defaults to `"default"`); all clients in the same room share one Firestore document (`inventoryRooms/<roomId>`).
   - Writes are debounced through `queueCloudSave()` → `doCloudSave()` (300ms), and flushed immediately on `pagehide`/tab-hidden via `flushCloudSave()`.
   - Incoming snapshots are ignored while `localDirty` is true, to avoid clobbering unsent local edits with stale remote data.
   - `save`, `saveUnits`, `saveGlobalMemo`, `saveMemos` are monkey-patched (`oldSave = save; save = function(){ oldSave(); queueCloudSave(); }`) to add cloud sync on top of the local-only versions — when editing these functions, preserve this wrapping order.
   - The global memo textarea has special handling: if the user is actively focused on it, an incoming remote snapshot does not overwrite their in-progress typing.

**Rendering**: `render()` rebuilds the flower list/cards for the active tab; `renderStats()` updates the header counts; `renderHistory()` rebuilds the history tab. `refreshCard(id)` does a targeted DOM update for a single card (used after remote sync) instead of a full re-render.

**Other features**: voice input via the Web Speech API (`recognition`, `isListening`), a numpad-style quantity editor (`_numpadId`/`_numpadVal`), long-press handling (`_lpTimer`/`_lpMoved`), and LINE share/report generation (`🌸 渡辺花屋 在庫レポート` text export).

## Architecture: `shop.html`

Independent of `index.html` — no shared state, no localStorage, no Firebase. Pure presentational sections (hero, story, products, shop info, contact) using the same CSS custom properties (`--moss`, `--sakura`, `--paper`, etc.) and fonts (Shippori Mincho B1 / Noto Sans JP) as the inventory app, so visual changes to one should be considered for the other if shop branding changes. Address, phone, hours, and product photos are placeholders — look for the `.note` disclaimer and `写真準備中`/`サンプルです` text when updating with real shop data.

## CI / deploy

- `.github/workflows/pages.yml`: deploys the repo root to GitHub Pages on every push to `main`.
- `.github/workflows/fix-inventory-sync.yml`: a one-off, manually-triggered (`workflow_dispatch`) Node script that patches specific known bugs in `index.html` (null-checks on `.flower-tags`, malformed closing tags from a pasted Firebase snippet, share-modal copy, and the Firestore "first empty snapshot" overwrite bug). Treat it as a historical fix already applied rather than a pattern to extend — prefer editing `index.html` directly for new changes.
