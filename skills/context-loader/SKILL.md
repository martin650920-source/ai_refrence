---
name: context-loader
description: >
  Auto-detect the project type from cwd and load the appropriate context files
  from ~/.ai-context/context/. Trigger at session start (via CLAUDE.md bootstrap),
  when the user says "load context", "bootstrap session", or "載入 context".
---

# Context Loader

## Step 1: Resolve Context Root

Determine `AI_CONTEXT` path based on environment:

| Environment | Path |
|---|---|
| Windows (Claude Code / VSCode) | `C:\Users\<user>\.ai-context\` |
| WSL / Linux | `~/.ai-context/` |
| SSH remote | `~/.ai-context/` |

If the path doesn't exist, report the issue and stop — the setup script has not been run yet.

## Step 2: Detect Project Type

Check for these marker files in cwd:

| Marker | Project Type |
|---|---|
| `CMakeLists.txt` AND any `mt_unf_*.h` in `include/` | `sym6-porting` |
| `robot/` directory AND `*.robot` files | `hil-robot` |
| `project.yml` (Ceedling) | `unit-test` |
| none of the above | `generic` |

## Step 3: Load Context by Type

### sym6-porting
Read in order:
1. `<AI_CONTEXT>/context/nagra-tntsat.md`
2. `<AI_CONTEXT>/context/test-strategy.md`
3. List headers in `include/` — ask which modules are in scope today

### hil-robot
Read in order:
1. `<AI_CONTEXT>/context/nagra-tntsat.md`
2. List all `.robot` and `.resource` files under `robot/resources/` — ask which to load

### unit-test
Read in order:
1. `<AI_CONTEXT>/context/test-strategy.md`
2. List test suites under `test/` — ask which are in scope

### generic
1. `<AI_CONTEXT>/context/global.md`

## Step 4: Confirm and Proceed

Output exactly this summary, then wait:

```
## Session Context Loaded
- Environment: <Windows / WSL / SSH>
- Project type: <type>
- Files loaded:
  - <file1>
  - <file2>
Ready. What are we working on today?
```
