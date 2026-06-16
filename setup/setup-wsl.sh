#!/usr/bin/env bash
# AI Config Symlink Setup — WSL
# 使用方式: bash setup-wsl.sh
set -euo pipefail

# ── 設定 ──────────────────────────────────────────
GDRIVE="/mnt/d/GOOGLE_DRIVE_SYNC/AI_參考資料"   # D: 磁碟掛載路徑，依實際調整
CLAUDE_HOME="$HOME/.claude"
GEMINI_HOME="$HOME/.gemini"
CODEX_HOME="$HOME/.codex"
AI_CONTEXT="$HOME/.ai-context"
# ────────────────────────────────────────────────

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RED='\033[0;31m'; NC='\033[0m'
ok()     { echo -e "${GREEN}[OK]    ${NC} $*"; }
skip()   { echo -e "${YELLOW}[SKIP]  ${NC} $*"; }
backup() { echo -e "${CYAN}[BACKUP]${NC} $*"; }
err()    { echo -e "${RED}[ERROR] ${NC} $*"; }

# 建立 symlink，若目標已存在則備份
link() {
    local src="$1" target="$2"
    if [ -L "$src" ]; then
        skip "$src (已是 symlink)"
        return
    fi
    if [ -e "$src" ]; then
        local bak="${src}.backup-$(date +%Y%m%d-%H%M%S)"
        mv "$src" "$bak"
        backup "備份 $src -> $bak"
    fi
    mkdir -p "$(dirname "$src")"
    ln -s "$target" "$src"
    ok "$src -> $target"
}

echo ""
echo -e "${CYAN}=== AI Config Symlink Setup (WSL) ===${NC}"
echo ""

# 確認 GDrive 掛載
if [ ! -d "$GDRIVE" ]; then
    err "GDrive 路徑不存在: $GDRIVE"
    err "請確認 D: 磁碟已掛載到 /mnt/d/，或修改腳本頂端的 GDRIVE 變數"
    echo ""
    echo "WSL 掛載 D 磁碟的方式（若未自動掛載）:"
    echo "  sudo mkdir -p /mnt/d && sudo mount -t drvfs D: /mnt/d"
    exit 1
fi

# 1. ~/.ai-context  →  GDrive 根（所有 AI 共用的進入點）
link "$AI_CONTEXT" "$GDRIVE"

# 2. Claude: ~/.claude/CLAUDE.md
link "$CLAUDE_HOME/CLAUDE.md" "$GDRIVE/rules/claude-global.md"

# 3. Claude: ~/.claude/skills/gdrive  →  skills 目錄
mkdir -p "$CLAUDE_HOME/skills"
link "$CLAUDE_HOME/skills/gdrive" "$GDRIVE/skills"

# 4. Gemini CLI: ~/.gemini/GEMINI.md
mkdir -p "$GEMINI_HOME"
link "$GEMINI_HOME/GEMINI.md" "$GDRIVE/rules/gemini-global.md"

# 5. Codex CLI: ~/.codex/instructions.md
mkdir -p "$CODEX_HOME"
link "$CODEX_HOME/instructions.md" "$GDRIVE/rules/codex-global.md"

# ── 驗證 ─────────────────────────────────────────
echo ""
echo -e "${CYAN}=== 驗證結果 ===${NC}"
for f in \
    "$AI_CONTEXT" \
    "$CLAUDE_HOME/CLAUDE.md" \
    "$CLAUDE_HOME/skills/gdrive" \
    "$GEMINI_HOME/GEMINI.md" \
    "$CODEX_HOME/instructions.md"
do
    if [ -L "$f" ]; then
        echo -e "  ${GREEN}$f${NC} -> $(readlink "$f")"
    else
        echo -e "  ${RED}[MISSING] $f${NC}"
    fi
done

echo ""
echo -e "${GREEN}完成！請重啟 Claude Code / Gemini CLI / Codex CLI 讓變更生效。${NC}"
