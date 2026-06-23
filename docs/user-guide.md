# AI Reference 使用者說明書

---

## 目錄

1. [系統概覽](#1-系統概覽)
2. [架構說明](#2-架構說明)
3. [安裝設定](#3-安裝設定)
4. [日常使用](#4-日常使用)
5. [新增／更新專案 Context](#5-新增更新專案-context)
6. [Status Bar 說明](#6-status-bar-說明)
7. [同步更新](#7-同步更新)
8. [疑難排解](#8-疑難排解)

---

## 1. 系統概覽

這個 repo 是 Claude Code（以及 Gemini CLI、Codex CLI）的**設定集中管理系統**。

### 解決什麼問題

- 同一份偏好設定、專案背景，跨 Windows / WSL / SSH 三個環境自動同步
- 每次開新 session 不用重複說明「我的環境是什麼、這個專案在做什麼」
- 修改設定只需改一個地方，下次 pull 所有機器都會更新

### 運作原理

Setup 腳本在本機建立 **symlink**，讓 Claude Code 讀取的設定檔（`~/.claude/CLAUDE.md`）實際上指向這個 repo 的檔案。只要 repo 有更新並 pull，所有設定立刻生效，不需要重新安裝。

---

## 2. 架構說明

```
ai_refrence/
├── config/
│   └── statusline.sh          # Claude Code status bar 腳本
├── context/
│   └── global.md              # 個人背景：OS、工具、偏好（所有專案共用）
├── projects/
│   ├── _template.md           # 新專案用的範本
│   ├── android-aosp.md        # Android AOSP 專案 context
│   └── nagra-tntsat.md        # Nagra/TNTSAT 專案 context
├── rules/
│   ├── claude-global.md       # Claude Code 全域指令（CLAUDE.md 的實體）
│   ├── gemini-global.md       # Gemini CLI 全域指令
│   └── codex-global.md        # Codex CLI 全域指令
├── setup/
│   ├── setup-windows.ps1      # Windows 環境初始化腳本
│   ├── setup-wsl.sh           # WSL 環境初始化腳本
│   └── setup-ssh.sh           # SSH Remote 環境初始化腳本
└── skills/
    └── context-loader/
        └── SKILL.md           # AI 自動偵測並載入專案 context 的技能
```

### 各檔案說明

| 檔案 | 說明 |
|---|---|
| `context/global.md` | 個人通用背景，包含 OS 環境、慣用工具、命名慣例、AI 回答偏好 |
| `rules/claude-global.md` | Claude Code 每次啟動時讀取的指令，內含 Bootstrap 觸發 context-loader |
| `skills/context-loader/SKILL.md` | 偵測當前專案類型並自動載入對應 context 的邏輯 |
| `projects/*.md` | 各專案的詳細背景，包含架構、術語、build 指令、測試策略 |
| `config/statusline.sh` | Claude Code 底部 status bar 的顯示腳本 |

---

## 3. 安裝設定

### 前置條件

- Git 已安裝
- Claude Code 已安裝（`claude` 指令可用）
- 有 GitHub 存取權限（讀取即可）

---

### Windows

在 **系統管理員** PowerShell 執行：

```powershell
# 1. Clone repo（只做一次，路徑可自訂）
git clone https://github.com/martin650920-source/ai_refrence.git D:\GOOGLE_DRIVE_SYNC\AI_參考資料

# 2. 執行 setup
pwsh -ExecutionPolicy Bypass -File "D:\GOOGLE_DRIVE_SYNC\AI_參考資料\setup\setup-windows.ps1"
```

> **注意：** 腳本頂端的 `$GDriveRoot` 變數預設為 `d:\GOOGLE_DRIVE_SYNC\AI_參考資料`，若 clone 到其他位置請先修改。

---

### WSL

```bash
# 執行 setup（D: 磁碟需已掛載到 /mnt/d/）
bash /mnt/d/GOOGLE_DRIVE_SYNC/AI_參考資料/setup/setup-wsl.sh
```

若 D: 磁碟尚未掛載：

```bash
sudo mkdir -p /mnt/d && sudo mount -t drvfs D: /mnt/d
```

---

### SSH Remote

不需要先手動 clone，腳本會自動處理：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/martin650920-source/ai_refrence/master/setup/setup-ssh.sh) \
  https://github.com/martin650920-source/ai_refrence.git
```

---

### Setup 執行後會建立哪些 Symlink

| Symlink | 指向 |
|---|---|
| `~/.ai-context` | repo 根目錄 |
| `~/.claude/CLAUDE.md` | `rules/claude-global.md` |
| `~/.claude/skills/gdrive` | `skills/` |
| `~/.claude/statusline.sh` | `config/statusline.sh` |
| `~/.gemini/GEMINI.md` | `rules/gemini-global.md` |
| `~/.codex/instructions.md` | `rules/codex-global.md` |

### 遇到已有檔案時

若 `~/.claude/CLAUDE.md` 等位置已有現有檔案，腳本會顯示選單：

```
[!] 偵測到現有路徑: /home/user/.claude/CLAUDE.md

    1) 蓋過  (備份後建立 symlink)
    2) 忽略  (保留現有內容，跳過此步驟)

    請選擇 [1/2]:
```

選 **1** 會自動備份成 `CLAUDE.md.backup-YYYYMMDD-HHmmss`，再建立 symlink。

---

## 4. 日常使用

### 啟動 Claude Code

```bash
cd /path/to/your/project
claude
```

### Context Loader 自動運作

Claude Code 啟動時，`CLAUDE.md` 的 Bootstrap 指令會觸發 context-loader，依序：

1. **載入全域 context**：讀取 `context/global.md`（個人環境與偏好）
2. **偵測專案類型**：掃描當前目錄的 Marker Files

| Marker Files | 自動載入的 context |
|---|---|
| `CMakeLists.txt` + `include/mt_unf_*.h` | `projects/nagra-tntsat.md` |
| `robot/` 目錄 + `*.robot` 檔案 | `projects/nagra-tntsat.md` |
| `project.yml`（Ceedling） | `projects/nagra-tntsat.md` |
| `Android.bp` 或路徑含 `AOSP` | `projects/android-aosp.md` |

3. **確認或手動選擇**：

   - 偵測到符合的專案：
     ```
     Detected project: nagra-tntsat. Load this? [Y/n]
     ```

   - 未偵測到時，列出所有可用 context 讓你選：
     ```
     No project auto-detected. Available projects:
     1. nagra-tntsat
     2. android-aosp
     Which project? (enter number or name, or 0 to skip)
     ```

4. **輸出確認訊息**：
   ```
   ## Session Context Loaded
   - Environment: Windows
   - Global: context/global.md ✓
   - Project: projects/nagra-tntsat.md ✓
   Ready. What are we working on today?
   ```

### 手動觸發 Context Loader

若需要重新載入，在 session 中說：

```
load context
```

或

```
載入 context
```

---

## 5. 新增／更新專案 Context

### 新增專案

```bash
# 1. 複製模板
cp projects/_template.md projects/my-project.md

# 2. 編輯填入內容（詳見下方說明）
# 3. 更新 context-loader 的偵測規則
# 4. commit 並 push
git add projects/my-project.md skills/context-loader/SKILL.md
git commit -m "feat: add my-project context"
git push
```

### 專案 Context 模板說明

```markdown
# 專案名稱

## 專案概述
<!-- 這個專案是什麼、做什麼用的 -->

## 系統架構
<!-- 整體架構、主要元件、資料流 -->

## 關鍵術語
| 術語 | 說明 |
|---|---|
| ABC | 說明 |

## 開發環境設定
<!-- repo 路徑、build 指令、環境變數 -->

## 常用指令
# build / test / flash

## 測試策略
<!-- 這個專案用哪種測試、怎麼跑 -->

## 已知限制與注意事項
<!-- 踩過的坑、不能動的東西 -->

## Marker Files
<!-- 填入能識別這個專案的特徵檔案，並更新 SKILL.md 的偵測表 -->
```

### 更新 Context Loader 偵測規則

編輯 `skills/context-loader/SKILL.md` 的 Step 3 表格，加入新專案的 Marker Files：

```markdown
| `my-project.json` 或路徑含 `my-project` | `projects/my-project.md` |
```

---

## 6. Status Bar 說明

Claude Code 底部 status bar 顯示：

```
Sonnet 4.6 | ctx:2% | $0.1799 | 5h:12% 7d:16% | high | /src/martin/project
```

| 欄位 | 顏色 | 說明 |
|---|---|---|
| `Sonnet 4.6` | 黃 | 當前使用的模型名稱 |
| `ctx:2%` | 綠 | Context window **已使用**百分比（2% = 使用了 2%） |
| `$0.1799` | 綠 | 本次 session 累計費用（USD），為 0 時不顯示 |
| `5h:12% 7d:16%` | 橘紅 | Rate limit 使用量（5 小時 / 7 天） |
| `high` | 紫 | 當前 effort 等級（low / medium / high / max） |
| `/src/martin/project` | 白 | 當前工作目錄（超過 3 層時只顯示最後 3 層） |

### Status Bar 設定位置

Status bar 腳本位於 `config/statusline.sh`，setup 後 symlink 到 `~/.claude/statusline.sh`。

要修改顯示格式，直接編輯 `config/statusline.sh` 並 commit push 即可，所有環境下次 pull 後生效。

---

## 7. 同步更新

### Windows / WSL（手動 pull）

```powershell
# Windows
git -C "D:\GOOGLE_DRIVE_SYNC\AI_參考資料" pull

# WSL
git -C /mnt/d/GOOGLE_DRIVE_SYNC/AI_參考資料 pull
```

### SSH Remote（手動 pull）

```bash
git -C ~/.ai-context-git pull
```

### SSH Remote（自動 pull）

setup-ssh.sh 安裝時會詢問是否設定 **每日 09:00 自動 git pull**，選 y 後會加入 crontab：

```
0 9 * * * git -C ~/.ai-context-git pull --ff-only >> ~/.ai-context-pull.log 2>&1
```

查看 pull log：

```bash
cat ~/.ai-context-pull.log
```

---

## 8. 疑難排解

### `~/.ai-context` 不存在

Claude 啟動時若看到：

```
~/.ai-context not found — please run the setup script first
```

代表 setup 尚未執行，依照環境執行對應的腳本即可（參考 §3）。

---

### Context 沒有自動載入

可能原因：

1. **Marker Files 不符**：當前目錄沒有 `skills/context-loader/SKILL.md` 偵測表中列出的檔案。手動說「load context」後手動選擇。

2. **Symlink 失效**：確認 `~/.claude/CLAUDE.md` 是 symlink 且指向正確位置：
   ```bash
   ls -la ~/.claude/CLAUDE.md
   # 應顯示：~/.claude/CLAUDE.md -> /path/to/ai_refrence/rules/claude-global.md
   ```

3. **Repo 內容過舊**：執行 `git pull` 更新後重試。

---

### Symlink 建立失敗（Windows）

Windows 建立 symlink 需要管理員權限或開發者模式。確認以下其中一項：

- 以**系統管理員**身份執行 PowerShell
- 或在 Windows 設定 → 開發人員選項 → 開啟「開發人員模式」

---

### SSH 上 git pull 失敗

若手動 pull 或 cron pull 失敗，查看 log：

```bash
cat ~/.ai-context-pull.log
```

常見原因：
- `--ff-only` 失敗（本地有修改）：`git -C ~/.ai-context-git reset --hard origin/master`
- 網路問題：確認 SSH 機器能連到 github.com

---

### 確認所有 Symlink 狀態

```bash
# Linux / WSL / SSH
for f in ~/.ai-context \
         ~/.claude/CLAUDE.md \
         ~/.claude/skills/gdrive \
         ~/.claude/statusline.sh \
         ~/.gemini/GEMINI.md \
         ~/.codex/instructions.md; do
    [ -L "$f" ] && echo "✓ $f -> $(readlink $f)" || echo "✗ MISSING: $f"
done
```
