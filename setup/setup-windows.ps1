# AI Config Symlink Setup — Windows
# 需要以「系統管理員」身份執行，或開啟開發者模式
# 使用方式: pwsh -ExecutionPolicy Bypass -File setup-windows.ps1

#Requires -RunAsAdministrator
$ErrorActionPreference = "Stop"

# ── 設定 ──────────────────────────────────────────
$GDriveRoot  = "d:\GOOGLE_DRIVE_SYNC\AI_參考資料"   # GDrive 實體路徑，依實際調整
$UserHome    = $env:USERPROFILE                      # C:\Users\martin_wang
$ClaudeHome  = "$UserHome\.claude"
$GeminiHome  = "$UserHome\.gemini"
$CodexHome   = "$UserHome\.codex"
$AiContext   = "$UserHome\.ai-context"
# ────────────────────────────────────────────────

function Write-OK($msg)     { Write-Host "[OK]     $msg" -ForegroundColor Green }
function Write-Skip($msg)   { Write-Host "[SKIP]   $msg" -ForegroundColor Yellow }
function Write-Backup($msg) { Write-Host "[BACKUP] $msg" -ForegroundColor Cyan }
function Write-Err($msg)    { Write-Host "[ERROR]  $msg" -ForegroundColor Red }

function New-Symlink {
    param([string]$LinkPath, [string]$Target, [switch]$IsDir)

    if (Test-Path $LinkPath -ErrorAction SilentlyContinue) {
        $item = Get-Item $LinkPath -Force

        # 已是 symlink，跳過
        if ($item.LinkType -eq "SymbolicLink") {
            Write-Skip "$LinkPath (已是 symlink)"
            return
        }

        # 偵測到現有檔案，詢問用戶
        Write-Host ""
        Write-Host "[!] 偵測到現有檔案: $LinkPath" -ForegroundColor Yellow
        Write-Host "    此檔案將被備份，並以 symlink 取代。" -ForegroundColor Yellow
        Write-Host "    建議之後將舊內容合併進: $Target" -ForegroundColor Yellow
        Write-Host ""
        $ans = Read-Host "    是否需要我開啟兩個檔案供你比對合併？(y/n)"

        # 備份現有檔案
        $ts = Get-Date -Format "yyyyMMdd-HHmmss"
        $backup = "${LinkPath}.backup-${ts}"
        Move-Item $LinkPath $backup -Force
        Write-Backup "備份完成: $backup"

        # 若用戶要合併，用 VSCode 並排開啟
        if ($ans -match "^[Yy]") {
            Write-Host "    開啟 VSCode 比對中..." -ForegroundColor Cyan
            # 先建立 symlink，再用 diff 開啟備份 vs 新目標
            New-Item -ItemType SymbolicLink -Path $LinkPath -Target $Target -Force | Out-Null
            code --diff $backup $Target
            Write-Host "    合併完成後請儲存 $Target，備份可手動刪除。" -ForegroundColor Cyan
            Write-OK "$LinkPath -> $Target"
            return
        }
    }

    $type = if ($IsDir) { "Directory" } else { "Junction" }
    New-Item -ItemType SymbolicLink -Path $LinkPath -Target $Target -Force | Out-Null
    Write-OK "$LinkPath -> $Target"
}

Write-Host ""
Write-Host "=== AI Config Symlink Setup (Windows) ===" -ForegroundColor Cyan
Write-Host ""

# 確認 GDrive 存在
if (-not (Test-Path $GDriveRoot)) {
    Write-Err "GDrive 路徑不存在: $GDriveRoot"
    Write-Err "請修改腳本頂端的 `$GDriveRoot 變數"
    exit 1
}

# 1. ~/.ai-context  →  GDrive 根（所有 AI 共用的進入點）
New-Symlink -LinkPath $AiContext -Target $GDriveRoot -IsDir

# 2. Claude: ~/.claude/CLAUDE.md
New-Symlink -LinkPath "$ClaudeHome\CLAUDE.md" -Target "$GDriveRoot\rules\claude-global.md"

# 3. Claude: ~/.claude/skills/gdrive  →  skills 目錄（讓 Claude Code 能讀到 context-loader）
$skillsDir = "$ClaudeHome\skills"
if (-not (Test-Path $skillsDir)) { New-Item -ItemType Directory -Path $skillsDir | Out-Null }
New-Symlink -LinkPath "$skillsDir\gdrive" -Target "$GDriveRoot\skills" -IsDir

# 4. Gemini CLI: ~/.gemini/GEMINI.md
if (-not (Test-Path $GeminiHome)) { New-Item -ItemType Directory -Path $GeminiHome | Out-Null }
New-Symlink -LinkPath "$GeminiHome\GEMINI.md" -Target "$GDriveRoot\rules\gemini-global.md"

# 5. Codex CLI: ~/.codex/instructions.md
if (-not (Test-Path $CodexHome)) { New-Item -ItemType Directory -Path $CodexHome | Out-Null }
New-Symlink -LinkPath "$CodexHome\instructions.md" -Target "$GDriveRoot\rules\codex-global.md"

# ── 驗證 ─────────────────────────────────────────
Write-Host ""
Write-Host "=== 驗證結果 ===" -ForegroundColor Cyan
@(
    $AiContext,
    "$ClaudeHome\CLAUDE.md",
    "$ClaudeHome\skills\gdrive",
    "$GeminiHome\GEMINI.md",
    "$CodexHome\instructions.md"
) | ForEach-Object {
    $item = Get-Item $_ -Force -ErrorAction SilentlyContinue
    if ($item -and $item.LinkType) {
        Write-Host "  $_ -> $($item.Target)" -ForegroundColor Green
    } else {
        Write-Host "  [MISSING] $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "完成！請重啟 Claude Code / Gemini CLI / Codex CLI 讓變更生效。" -ForegroundColor Green
