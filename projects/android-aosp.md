# Android AOSP — RTD1319D / PESI

## 專案概述

Realtek RTD1319D（Parker 晶片）Android 14 ATV set-top-box BSP。
主要工作目錄：`/src/martin_wang/1319D_Q3Q4/realtek_a14/`
目標 product：`DADA_1319D`（userdebug）

## 系統架構

```
Android App (DMGLauncher APK)
        │
        ▼
HIDL HAL  vendor/prime/hal/interfaces/dtvservice/1.0/
        │
        ▼
Plugin bridge  vendor/prime/dtv/PesiDtvPlugin.cpp  →  libPesiDtvPlugin.so
        │
        ▼
PESI DTV middleware  vendor/prime/dtv/pesi/
        │
        ├── DoCmdInterface/     # App ↔ middleware command 路由
        ├── ca_cloak/           # Irdeto CloakedCA SPI 整合
        │   ├── spi/            # SPI 函式實作（spi_toplevel.c, spi_device.c …）
        │   ├── cl/             # CA callback 處理（cloak_ca_user.c）
        │   └── lib/            # CloakedCAAgent_*.a 預編靜態庫
        ├── driver/             # DMX / tuner / CA / PVR 驅動介面
        ├── mid/                # 中間層（scan / SI table / PVR）
        └── oemmake/            # 編譯 flag、CA type config
```

## 關鍵術語

| 術語 | 說明 |
|---|---|
| PESI | Prime Embedded Software Integration，DTV middleware |
| CloakedCA / Irdeto | CA 系統，以靜態庫 `CloakedCAAgent_*.a` 鏈結進 libPesiDtvPlugin.so |
| SPI | CloakedCA 要求平台實作的 System Platform Interface |
| FlexiFlash | Irdeto OTA firmware update 機制 |
| INVERTO | 客戶名稱，同時是 overlay 名稱，build 時套用 `device/prime/INVERTO/` |
| OVERLAY | build_android_app.sh 執行時把 overlay 檔複製進 base 目錄，uncommitted 變更會觸發 OVERLAY CONFLICT |
| Parker | RTD1319D 晶片代號 |

## CA 設定

- `vendor/prime/dtv/pesi/oemmake/customercfg.h` — `PESI_CA_TYPE` 定義
- `vendor/prime/dtv/pesiplugin.mk` 第 1–9 行 — CloakedCAAgent 預編靜態庫宣告
- 目前使用：`PESI_CA_TYPE = PESI_CA_CLOAK`（Irdeto），lib = `CloakedCAAgent_511.a`

## 開發環境設定

```bash
# 進入 SDK 根目錄
cd /src/martin_wang/1319D_Q3Q4/realtek_a14/

# Full image build
bash build_all.sh INVERTO

# 只 build PESI middleware（最常用）
bash build_android_app.sh vendor/prime/dtv/ INVERTO

# output
out/target/product/DADA_1319D/vendor/lib/libPesiDtvPlugin.so
```

## 常用指令

```bash
# push libPesiDtvPlugin.so（IP 每次動態詢問）
adb connect <IP>:5555
adb -s <IP>:5555 root
adb -s <IP>:5555 remount
adb -s <IP>:5555 push out/target/product/DADA_1319D/vendor/lib/libPesiDtvPlugin.so /vendor/lib/

# 重啟 media service（push 後生效）
adb shell stop media && adb shell start media

# 還原 overlay 殘留（build 前若有 OVERLAY CONFLICT）
git checkout -- device/realtek flash_writer image_file kernel packages vendor/realtek build/make/target/product/security/
```

## Full Image 升級流程

Build full image（`bash build_all.sh INVERTO`）完成後：

```bash
# 複製到隨身碟（替換為實際掛載點）
cp /src/martin_wang/1319D_Q3Q4/realtek_a14/image_file/out/* <隨身碟掛載點>/
```

接上 STB，**按住 Tab 鍵開機**進行 USB 升級。

## 已知限制與注意事項

- **絕對不要** `git add / commit` realtek_a14 裡的任何變更
- Push 前一定要問使用者裝置 IP，不可假設或沿用舊 IP
- overlay build residue 會汙染 base 目錄，build 前先確認 `git status` 乾淨
- `vendor/prime/` 是開發目錄，不可一起 `git checkout --` 還原

## Marker Files

- `Android.bp` 或路徑中含 `aosp` / `android` / `1319D`
