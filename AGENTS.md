# AGENTS.md

## Cursor Cloud specific instructions

### Product overview

Single-page **渡辺花屋 在庫管理** app: one file (`index.html`) with vanilla HTML/CSS/JS. No backend, build step, or package manager. Data persists in browser `localStorage` (keys like `wh_s_v4`, `wh_h_v4`).

### Running locally

Preferred for agents (clipboard API, closer to production):

```bash
python3 -m http.server 8080 --directory /workspace
```

Then open `http://localhost:8080/index.html`.

You can also open `index.html` via `file://`, but some features (clipboard) work more reliably on `http://localhost`.

Use a **tmux** session for the static server so it stays up across shell commands (see repo root `/workspace`).

### Lint / test / build

There are **no** in-repo lint, test, or build scripts (`package.json`, `Makefile`, etc. are absent). Verification is manual in a browser: change stock with +/-, confirm UI updates, refresh and confirm `localStorage` persistence.

### Optional deploy

`deploy.ps1` is a Windows PowerShell helper for GitHub Pages (`gh` CLI). Not required for local development. See `README.md` for Netlify Drop and GitHub Pages hosting.

### External services (optional)

- Google Fonts (CDN) when online
- LINE share and Web Speech API are browser features; no local services to start
