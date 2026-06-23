---
name: context-loader
description: >
  Auto-detect the project type from cwd and load the appropriate context files
  from ~/.ai-context/. Trigger at session start (via CLAUDE.md bootstrap),
  or when the user says "load context", "bootstrap session", or "載入 context".
---

# Context Loader

## Step 1: Resolve Context Root

| Environment | `AI_CONTEXT` path |
|---|---|
| Windows (Claude Code / VSCode) | `$env:USERPROFILE\.ai-context` (PowerShell) / `%USERPROFILE%\.ai-context` (cmd) |
| WSL / Linux | `~/.ai-context` |
| SSH remote | `~/.ai-context` |

On Windows, resolve the actual path by expanding `$env:USERPROFILE` — do not assume `C:\Users\<name>`.

If the path doesn't exist, stop and report: "`~/.ai-context` not found — please run the setup script first (setup\setup-windows.ps1 on Windows, setup/setup-wsl.sh on WSL, setup/setup-ssh.sh on SSH)."

## Step 2: Always Load Global Context

Read `<AI_CONTEXT>/context/global.md` first (personal background, applies to all projects).

## Step 3: Detect Project

### Auto-detect from marker files in cwd

| Marker files | Project file to load |
|---|---|
| `CMakeLists.txt` + any `mt_unf_*.h` in `include/` | `projects/nagra-tntsat.md` |
| `robot/` directory + `*.robot` files | `projects/nagra-tntsat.md` |
| `project.yml` (Ceedling) | `projects/nagra-tntsat.md` |
| `Android.bp` or `AOSP` in path | `projects/android-aosp.md` |

If a match is found, confirm with user:
```
Detected project: nagra-tntsat. Load this? [Y/n]
```

### Fallback: list available projects

If no marker matches, list all `.md` files in `<AI_CONTEXT>/projects/` (excluding `_template.md`) and ask:
```
No project auto-detected. Available projects:
1. nagra-tntsat
2. android-aosp
Which project? (enter number or name, or 0 to skip)
```

## Step 4: Load Project Context

Read `<AI_CONTEXT>/projects/<selected>.md`.

## Step 5: Confirm and Proceed

Output this summary, then wait:

```
## Session Context Loaded
- Environment: <Windows / WSL / SSH>
- Global: context/global.md ✓
- Project: projects/<name>.md ✓
Ready. What are we working on today?
```
