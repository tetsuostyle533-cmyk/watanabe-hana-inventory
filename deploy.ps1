# 渡辺花屋在庫 — GitHub Pages へ公開
# 使い方: .\deploy.ps1 -GitHubUsername "あなたのGitHubユーザー名"

param(
  [Parameter(Mandatory = $true)]
  [string]$GitHubUsername,

  [string]$RepoName = "watanabe-hana-inventory"
)

$ErrorActionPreference = "Stop"
$repoRoot = $PSScriptRoot
Set-Location $repoRoot

# PATH 更新（新規インストール直後用）
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Error "Git が見つかりません。ターミナルを開き直してください。"
}
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  Write-Error "GitHub CLI (gh) が見つかりません。"
}

$auth = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
  Write-Host ""
  Write-Host "GitHub にログインしてください:" -ForegroundColor Yellow
  Write-Host "  gh auth login" -ForegroundColor Cyan
  Write-Host "（ブラウザで認証 → HTTPS → Yes で git 連携）" -ForegroundColor Gray
  exit 1
}

$email = "$GitHubUsername@users.noreply.github.com"

if (-not (Test-Path .git)) { git init }

git add -A
$status = git status --porcelain
if ($status) {
  git -c user.name="$GitHubUsername" -c user.email="$email" commit -m "Deploy: 渡辺花屋在庫アプリ"
}

git branch -M main

$remoteUrl = "https://github.com/$GitHubUsername/$RepoName.git"
$hasOrigin = git remote get-url origin 2>$null
if (-not $hasOrigin) {
  git remote add origin $remoteUrl
} else {
  git remote set-url origin $remoteUrl
}

$repoExists = gh repo view "$GitHubUsername/$RepoName" 2>$null
if ($LASTEXITCODE -ne 0) {
  Write-Host "リポジトリを作成しています..." -ForegroundColor Green
  gh repo create $RepoName --public --source=. --remote=origin --push
} else {
  Write-Host "リポジトリへ push しています..." -ForegroundColor Green
  git push -u origin main
}

Write-Host "GitHub Pages を有効化しています..." -ForegroundColor Green
gh api -X PUT "repos/$GitHubUsername/$RepoName/pages" `
  -f "build_type=legacy" `
  -f "source[branch]=main" `
  -f "source[path]=/" 2>$null

if ($LASTEXITCODE -ne 0) {
  Write-Host "Pages API が使えない場合は、ブラウザで設定してください:" -ForegroundColor Yellow
  Write-Host "  https://github.com/$GitHubUsername/$RepoName/settings/pages" -ForegroundColor Cyan
  Write-Host "  Source: Deploy from branch → main → / (root)" -ForegroundColor Gray
}

$pagesUrl = "https://$GitHubUsername.github.io/$RepoName/"
Write-Host ""
Write-Host "完了！" -ForegroundColor Green
Write-Host "公開URL（反映まで1〜3分）: $pagesUrl" -ForegroundColor Cyan
