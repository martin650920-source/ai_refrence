# Nagra / TNTSAT

## 專案概述
<!-- 填入：這個專案的用途、產品定位 -->

## 系統架構
<!-- 填入：sym6 porting layer 架構、與 TNTSAT 的關係 -->

## 關鍵術語
| 術語 | 說明 |
|---|---|
| sym6 | <!-- 填入 --> |
| mt_unf_ | <!-- 填入 --> |
| TNTSAT | <!-- 填入 --> |
| HIL | Hardware-in-the-Loop，實機測試環境 |

## 開發環境設定
<!-- 填入：repo 路徑、toolchain、環境變數 -->

## 常用指令
```bash
# build

# unit test (Ceedling)
ceedling test:all

# HIL test (Robot Framework)
robot robot/tests/
```

## 測試策略
<!-- 填入：sym6 porting 的單元測試範圍、HIL 驗收測試規範 -->

## 已知限制與注意事項
<!-- 填入 -->

## Marker Files
- `CMakeLists.txt` + `include/mt_unf_*.h` → sym6 porting layer
- `robot/` + `*.robot` → HIL acceptance test
- `project.yml` (Ceedling) → unit test
