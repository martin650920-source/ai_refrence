- 請用繁體中文回答

## Session Bootstrap

At the start of every new session, auto-detect the project type and load context:

### Step 1: Detect Project Type

Check for marker files in the current working directory:

| Marker | Project Type |
|---|---|
| `CMakeLists.txt` + any `mt_unf_*.h` in `include/` | `sym6-porting` |
| `robot/` directory + `*.robot` files | `hil-robot` |
| `project.yml` (Ceedling) | `unit-test` |
| none of the above | `generic` |

### Step 2: Load Context

**sym6-porting**: Read `~/.ai-context/context/nagra-tntsat.md` then `~/.ai-context/context/test-strategy.md`

**hil-robot**: Read `~/.ai-context/context/nagra-tntsat.md`, then list `robot/resources/` and ask which files to load

**unit-test**: Read `~/.ai-context/context/test-strategy.md`, then list `test/` suites

**generic**: Read `~/.ai-context/context/global.md`

### Step 3: Confirm

Output:
```
## Session Context Loaded
- Project type: <type>
- Files loaded: <list>
Ready. What are we working on today?
```
