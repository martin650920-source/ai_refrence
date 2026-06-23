# 專案進度

## ✅ 已完成

### 架構與檔案
- [x] 目錄結構建立（`context/`, `projects/`, `rules/`, `skills/`, `setup/`, `config/`, `docs/`）
- [x] `context/global.md` — 已填入實際內容（OS、工具、慣例、AI 偏好）
- [x] `rules/claude-global.md` — 含 bootstrap 指令，指向 context-loader；含 ~/.ai-context 不存在時的 fallback 提示
- [x] `rules/gemini-global.md` — 同上
- [x] `rules/codex-global.md` — 同上
- [x] `skills/context-loader/SKILL.md` — 自動偵測專案類型，fallback 列表選擇；Windows path 改用 `$env:USERPROFILE`
- [x] `projects/_template.md` — 新增專案用的範本
- [x] `projects/android-aosp.md` — 已填入 RTD1319D/PESI 專案內容
- [x] `config/statusline.sh` — Claude Code status bar 腳本
- [x] `docs/user-guide.md` — 完整使用者說明書
- [x] `setup/setup-windows.ps1` — Windows 管理員 PowerShell 一鍵建 symlink（含 statusline.sh）
- [x] `setup/setup-wsl.sh` — WSL 一鍵建 symlink（含 statusline.sh）
- [x] `setup/setup-ssh.sh` — SSH 主機 git clone + symlink（含 statusline.sh、per-skill symlink、非互動模式支援）
- [x] Git repo 初始化，push 到 GitHub (`martin650920-source/ai_refrence`)
- [x] `README.md` — 安裝與使用說明

### Setup 執行狀況
- [x] **Windows**：symlink 已建立，Claude Code 正常讀取 context
- [x] **SSH 主機**：setup-ssh.sh 已執行，symlink 已建立
- [ ] **WSL**：尚未執行

### 驗證
- [x] Windows 上 context-loader 正常觸發
- [x] Status bar 顯示正常（model / ctx / cost / rate-limits / effort / cwd）
- [ ] WSL 驗證
- [ ] 在 nagra 專案目錄下開 session，確認自動偵測到正確專案

---

## ❌ 未完成

### 內容填寫
- [ ] `projects/nagra-tntsat.md` — 只有佔位符，需填入：
  - 系統架構、sym6/mt_unf_ 術語說明
  - build 指令、toolchain 設定
  - 測試策略（Ceedling 單元 + Robot HIL）
  - 已知限制

### 環境
- [ ] **WSL**：執行 `bash setup/setup-wsl.sh`

---

## 下次繼續的建議順序

1. 填 `projects/nagra-tntsat.md`（最常用的，優先）
2. 跑 `setup-wsl.sh`
3. 在 nagra 專案目錄下驗證 context-loader 自動偵測
