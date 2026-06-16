# Android AOSP

## 專案概述
<!-- 填入：這個 AOSP 專案的用途、裝置平台 -->

## 系統架構
<!-- 填入：相關 layer（HAL、framework、app）、主要模組 -->

## 關鍵術語
| 術語 | 說明 |
|---|---|
| AOSP | Android Open Source Project |
| HAL | Hardware Abstraction Layer |
| <!-- 填入 --> | <!-- 填入 --> |

## 開發環境設定
<!-- 填入：lunch target、repo sync 指令、出 build 的環境 -->

```bash
# build
source build/envsetup.sh
lunch <target>
make -j$(nproc)
```

## 常用指令
```bash
# 刷機
fastboot flashall

# logcat
adb logcat
```

## 測試策略
<!-- 填入：CTS/VTS、單元測試、手動測試項目 -->

## 已知限制與注意事項
<!-- 填入 -->

## Marker Files
- `Android.bp` 或路徑中含 `aosp` / `android`
