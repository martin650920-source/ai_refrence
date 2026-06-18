# 專案進度

## ✅ 已完成

### 架構與檔案
- [x] 目錄結構建立（`context/`, `projects/`, `rules/`, `skills/`, `setup/`）
- [x] `context/global.md` — 已填入實際內容（OS、工具、慣例、AI 偏好）
- [x] `rules/claude-global.md` — 含 bootstrap 指令，指向 context-loader
- [x] `rules/gemini-global.md` — 同上
- [x] `rules/codex-global.md` — 同上
- [x] `skills/context-loader/SKILL.md` — 自動偵測專案類型，fallback 列表選擇
- [x] `projects/_template.md` — 新增專案用的範本
- [x] `setup/setup-windows.ps1` — Windows 管理員 PowerShell 一鍵建 symlink
- [x] `setup/setup-wsl.sh` — WSL 一鍵建 symlink
- [x] `setup/setup-ssh.sh` — SSH 主機 git clone + symlink
- [x] Git repo 初始化，push 到 GitHub (`martin650920-source/ai_refrence`)
- [x] `README.md` — 安裝與使用說明

---

## ❌ 未完成

### 內容填寫（最重要）
- [ ] `projects/nagra-tntsat.md` — 只有佔位符，需填入：
  - 系統架構、sym6/mt_unf_ 術語說明
  - build 指令、toolchain 設定
  - 測試策略（Ceedling 單元 + Robot HIL）
  - 已知限制
- [ ] `projects/android-aosp.md` — 只有佔位符，需填入實際 AOSP 內容

### Setup 腳本尚未執行（symlink 尚未建立）
- [ ] **Windows**：以管理員執行 `setup\setup-windows.ps1`
  - 執行後：`~/.claude/CLAUDE.md` 會變成 symlink 指向 GDrive
  - 執行後：`~/.ai-context/` 會建立
- [ ] **WSL**：執行 `bash setup/setup-wsl.sh`
- [ ] **SSH 主機**：執行 `bash setup/setup-ssh.sh <github-repo-url>`

### 驗證
- [ ] 重開 Claude Code，說「load context」確認 context-loader 正常觸發
- [ ] 在 nagra 專案目錄下開 session，確認自動偵測到正確專案

---

## 下次繼續的建議順序

1. 填 `projects/nagra-tntsat.md`（最常用的，優先）
2. 跑 `setup-windows.ps1` 讓 Windows 側 symlink 生效
3. 跑 `setup-wsl.sh`
4. 驗證 context-loader 觸發
5. 之後再填 `projects/android-aosp.md`
