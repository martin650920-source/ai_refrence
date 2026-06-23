# AI Config Symlink Setup — Windows
# 需要以「系統管理員」身份執行，或開啟開發者模式
# 使用方式: pwsh -ExecutionPolicy Bypass -File setup-windows.ps1

#Requires -RunAsAdministrator
$ErrorActionPreference = "Stop"

# ── 設定 ──────────────────────────────────────────
$GDriveRoot  = "d:\GOOGLE_DRIVE_SYNC\AI_參考資料"   # GDrive 實體路徑，依實際調整
$UserHome    = $env:USERPROFILE                      # e.g. C:\Users\martin_wang
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
    param([string]$LinkPath, [string]$Target)

    if (Test-Path $LinkPath -ErrorAction SilentlyContinue) {
        $item = Get-Item $LinkPath -Force

        # 已是 symlink，跳過
        if ($item.LinkType -eq "SymbolicLink") {
            Write-Skip "$LinkPath (已是 symlink)"
            return
        }

        # 偵測到現有檔案/目錄，讓 user 決定
        Write-Host ""
        Write-Host "[!] 偵測到現有路徑: $LinkPath" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "    1) 蓋過  (備份後建立 symlink 指向 $Target)" -ForegroundColor White
        Write-Host "    2) 忽略  (保留現有內容，跳過此步驟)" -ForegroundColor White
        Write-Host ""
        $choice = Read-Host "    請選擇 [1/2]"

        if ($choice -ne "1") {
            Write-Skip "$LinkPath (忽略)"
            return
        }

        # 備份現有檔案/目錄
        $ts = Get-Date -Format "yyyyMMdd-HHmmss"
        $backup = "${LinkPath}.backup-${ts}"
        Move-Item $LinkPath $backup -Force
        Write-Backup "備份完成: $backup"
    }

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
New-Symlink -LinkPath $AiContext -Target $GDriveRoot

# 2. Claude: ~/.claude/CLAUDE.md
if (-not (Test-Path $ClaudeHome)) { New-Item -ItemType Directory -Path $ClaudeHome | Out-Null }
New-Symlink -LinkPath "$ClaudeHome\CLAUDE.md" -Target "$GDriveRoot\rules\claude-global.md"

# 3. Claude: ~/.claude/skills/gdrive  →  skills 目錄（讓 Claude Code 能讀到 context-loader）
$skillsDir = "$ClaudeHome\skills"
if (-not (Test-Path $skillsDir)) { New-Item -ItemType Directory -Path $skillsDir | Out-Null }
New-Symlink -LinkPath "$skillsDir\gdrive" -Target "$GDriveRoot\skills"

# 4. Gemini CLI: ~/.gemini/GEMINI.md
if (-not (Test-Path $GeminiHome)) { New-Item -ItemType Directory -Path $GeminiHome | Out-Null }
New-Symlink -LinkPath "$GeminiHome\GEMINI.md" -Target "$GDriveRoot\rules\gemini-global.md"

# 5. Codex CLI: ~/.codex/instructions.md
if (-not (Test-Path $CodexHome)) { New-Item -ItemType Directory -Path $CodexHome | Out-Null }
New-Symlink -LinkPath "$CodexHome\instructions.md" -Target "$GDriveRoot\rules\codex-global.md"

# 6. Claude: ~/.claude/statusline.sh
New-Symlink -LinkPath "$ClaudeHome\statusline.sh" -Target "$GDriveRoot\config\statusline.sh"

# ── 驗證 ─────────────────────────────────────────
Write-Host ""
Write-Host "=== 驗證結果 ===" -ForegroundColor Cyan
@(
    $AiContext,
    "$ClaudeHome\CLAUDE.md",
    "$ClaudeHome\skills\gdrive",
    "$ClaudeHome\statusline.sh",
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
