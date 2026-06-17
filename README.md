# AI Reference

各 AI 工具（Claude Code / Gemini CLI / Codex）共用的設定與專案 context 倉庫。

---

## 架構說明

```
ai_refrence/
├── context/
│   └── global.md          # 所有專案共用的個人背景（環境、工具、偏好）
├── projects/
│   ├── _template.md       # 新增專案的模板
│   ├── android-aosp.md    # Android AOSP 專案 context
│   └── nagra-tntsat.md    # Nagra/TNTSAT 專案 context
├── rules/
│   ├── claude-global.md   # Claude Code 全域指令
│   ├── gemini-global.md   # Gemini CLI 全域指令
│   └── codex-global.md    # Codex CLI 全域指令
├── setup/
│   ├── setup-windows.ps1  # Windows 環境初始化
│   ├── setup-wsl.sh       # WSL 環境初始化
│   └── setup-ssh.sh       # SSH Remote 環境初始化
└── skills/
    └── context-loader/    # AI 自動偵測並載入專案 context 的技能
```

---

## 初次安裝

### Windows

```powershell
# 1. clone repo 到你選擇的位置（只做一次）
git clone https://github.com/martin650920-source/ai_refrence.git C:\ai-refrence

# 2. 以系統管理員身份執行 setup
pwsh -ExecutionPolicy Bypass -File C:\ai-refrence\setup\setup-windows.ps1
```

> 若已有現有的 CLAUDE.md，腳本會提示備份並詢問是否需要協助合併。

---

### WSL

```bash
# 1. clone repo 到你選擇的位置（只做一次）
git clone https://github.com/martin650920-source/ai_refrence.git ~/ai-refrence

# 2. 執行 setup
bash ~/ai-refrence/setup/setup-wsl.sh
```

> 若已有現有的 CLAUDE.md，腳本會提示備份並詢問是否需要協助合併。

---

### SSH Remote

setup-ssh.sh 內建 clone，不需要先手動 clone：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/martin650920-source/ai_refrence/master/setup/setup-ssh.sh) \
  https://github.com/martin650920-source/ai_refrence.git
```

> 腳本會自動 clone 到 `~/.ai-context-git`，並建立所有必要的 symlink。
> 可選擇設定每日 09:00 自動 `git pull` 保持最新。

---

## Setup 做了什麼

| 動作 | 路徑 |
|---|---|
| 建立 `~/.ai-context` symlink | → repo 根目錄 |
| Claude 全域指令 | `~/.claude/CLAUDE.md` → `rules/claude-global.md` |
| Claude skills | `~/.claude/skills/gdrive` → `skills/` |
| Gemini 全域指令 | `~/.gemini/GEMINI.md` → `rules/gemini-global.md` |
| Codex 全域指令 | `~/.codex/instructions.md` → `rules/codex-global.md` |

Setup 只需執行**一次**，之後直接開 Claude Code / Gemini CLI 即可。

---

## 日常使用

```bash
# cd 到任意專案資料夾
cd ~/work/my-project

# 啟動 Claude Code
claude
```

Claude 啟動時會自動：
1. 讀取 `global.md`（個人環境與偏好）
2. 偵測當前資料夾的 Marker Files
3. 載入對應的 `projects/<name>.md`
4. 輸出 Session 摘要，準備開始工作

---

## 新增專案 Context

```bash
# 複製模板
cp projects/_template.md projects/my-project.md

# 填入專案資訊後 push
git add projects/my-project.md
git commit -m "feat: add my-project context"
git push
```

---

## 更新 Context

```bash
# Windows / WSL
git -C C:\ai-refrence pull        # Windows
git -C ~/ai-refrence pull         # WSL

# SSH Remote（若有設定 cron 則自動更新）
git -C ~/.ai-context-git pull
```
