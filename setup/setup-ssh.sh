#!/usr/bin/env bash
# AI Config Setup — SSH Remote Host
# 使用方式: bash setup-ssh.sh <git-remote-url>
# 範例:     bash setup-ssh.sh git@github.com:yourname/ai-config.git
set -euo pipefail

# ── 設定 ──────────────────────────────────────────
GIT_REMOTE="${1:-}"
AI_CONTEXT_GIT="$HOME/.ai-context-git"   # git clone 的位置
AI_CONTEXT="$HOME/.ai-context"           # 各 AI 實際讀取的路徑（symlink）
CLAUDE_HOME="$HOME/.claude"
GEMINI_HOME="$HOME/.gemini"
CODEX_HOME="$HOME/.codex"
# ────────────────────────────────────────────────

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RED='\033[0;31m'; NC='\033[0m'
ok()   { echo -e "${GREEN}[OK]   ${NC} $*"; }
skip() { echo -e "${YELLOW}[SKIP] ${NC} $*"; }
err()  { echo -e "${RED}[ERR]  ${NC} $*"; }

if [ -z "$GIT_REMOTE" ]; then
    echo "用法: $0 <git-remote-url>"
    echo "範例: $0 git@github.com:yourname/ai-config.git"
    exit 1
fi

link() {
    local src="$1" target="$2"
    if [ -L "$src" ]; then skip "$src (已是 symlink)"; return; fi
    [ -e "$src" ] && mv "$src" "${src}.backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$(dirname "$src")"
    ln -s "$target" "$src"
    ok "$src -> $target"
}

echo ""
echo -e "${CYAN}=== AI Config Setup (SSH Remote) ===${NC}"
echo ""

# 1. Clone 或 pull git repo
if [ -d "$AI_CONTEXT_GIT/.git" ]; then
    echo "[GIT] 更新 $AI_CONTEXT_GIT ..."
    git -C "$AI_CONTEXT_GIT" pull --ff-only
    ok "git pull 完成"
else
    echo "[GIT] Clone $GIT_REMOTE ..."
    git clone "$GIT_REMOTE" "$AI_CONTEXT_GIT"
    ok "git clone 完成"
fi

# 2. ~/.ai-context  →  git clone 目錄
link "$AI_CONTEXT" "$AI_CONTEXT_GIT"

# 3. Claude: ~/.claude/CLAUDE.md
link "$CLAUDE_HOME/CLAUDE.md" "$AI_CONTEXT/rules/claude-global.md"

# 4. Claude: ~/.claude/skills/gdrive
mkdir -p "$CLAUDE_HOME/skills"
link "$CLAUDE_HOME/skills/gdrive" "$AI_CONTEXT/skills"

# 5. Gemini CLI: ~/.gemini/GEMINI.md
mkdir -p "$GEMINI_HOME"
link "$GEMINI_HOME/GEMINI.md" "$AI_CONTEXT/rules/gemini-global.md"

# 6. Codex CLI: ~/.codex/instructions.md
mkdir -p "$CODEX_HOME"
link "$CODEX_HOME/instructions.md" "$AI_CONTEXT/rules/codex-global.md"

# 7. 設定 cron 自動 git pull
echo ""
read -rp "是否設定每日 09:00 自動 git pull？[y/N] " ans
if [[ "${ans,,}" == "y" ]]; then
    CRON_CMD="0 9 * * * git -C $AI_CONTEXT_GIT pull --ff-only --quiet 2>/dev/null"
    ( crontab -l 2>/dev/null | grep -v "ai-context-git"; echo "$CRON_CMD" ) | crontab -
    ok "cron 已設定: $CRON_CMD"
else
    echo "跳過 cron 設定。手動更新: git -C $AI_CONTEXT_GIT pull"
fi

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
echo "日後更新 context: git -C $AI_CONTEXT_GIT pull"
