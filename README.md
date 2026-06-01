# 渡辺花屋 在庫管理

静的HTMLのみ。サーバー不要。

## いちばん簡単：Netlify Drop（Git不要）

1. ブラウザで https://app.netlify.com/drop を開く
2. このフォルダ `watanabe-hana-inventory` をドラッグ＆ドロップ
3. 表示された URL（例: `https://xxxx.netlify.app`）が公開アドレス

`index.html` が含まれている必要があります（済み）。

## GitHub Pages（推奨・Git / gh インストール済み）

### ワンコマンド公開

1. **新しいターミナル**を開く（Git / gh を PATH に反映）
2. GitHub にログイン（初回のみ）:
   ```powershell
   gh auth login
   ```
   - GitHub.com → HTTPS → **Login with a web browser** で認証
3. デプロイ（ユーザー名を自分のものに置き換え）:
   ```powershell
   cd C:\Users\PC002\watanabe-hana-inventory
   .\deploy.ps1 -GitHubUsername "あなたのGitHubユーザー名"
   ```
4. 表示された URL（`https://<ユーザー名>.github.io/watanabe-hana-inventory/`）でアクセス

### 方法A：ブラウザだけ（PCにGitがなくても可）

1. https://github.com/new でリポジトリ作成（Public）
2. **Add file** → **Upload files** で `index.html` をアップロード
3. **Settings** → **Pages** → Source: **Deploy from branch** → branch `main` → folder `/ (root)` → Save
4. 数分後 `https://<ユーザー名>.github.io/<リポジトリ名>/` で公開

### 方法B：Gitを使う（Gitインストール後）

```powershell
cd C:\Users\PC002\watanabe-hana-inventory
git init
git add index.html
git commit -m "Initial deploy"
git branch -M main
git remote add origin https://github.com/<ユーザー名>/<リポジトリ名>.git
git push -u origin main
```

## ローカル確認

`index.html` をダブルクリックするか、ブラウザでファイルを開く。

ローカルサーバー（推奨）:

```bash
python3 -m http.server 8080
```

ブラウザで http://localhost:8080/index.html を開く。

## 他の人と共有する

### アプリのURLを共有（GitHub Pages）

`main` ブランチへ push すると GitHub Actions で Pages に自動公開されます（リポジトリの **Settings → Pages** で有効化されていること）。

公開例: `https://<GitHubユーザー名>.github.io/watanabe-hana-inventory/`

### 在庫データを共有（アプリ内）

右下の **「共有」** から次が使えます。

| 方法 | 内容 |
|------|------|
| **在庫データのリンクをコピー** | 現在の在庫が入ったURLをコピー。相手がリンクを開き「読み込む」で同じ在庫を表示 |
| **LINEで送る** | 在庫レポートのテキスト（＋リンク）をLINEに送る |
| **テキストをコピー** | レポートをクリップボードへ |
| **バックアップを保存 / 読み込む** | JSONファイルで受け渡し |

※ 在庫は端末の `localStorage` にも保存されます。リンクやJSONは**その時点のスナップショット**です。
