# 證照題庫練習系統

一個功能完整的證照題庫練習應用程式，使用 Flutter 開發，支援題庫匯入、題目練習、錯題複習等功能。

## 功能特色

### 📚 題庫管理
- **匯入題庫**：支援 JSON 格式題庫檔案匯入
- **範例題目**：內建 Flutter/Dart 相關範例題目
- **清空題庫**：可一鍵清空所有題目

### 📝 題目練習
- **隨機練習**：題目隨機打亂，每次練習都不一樣
- **即時回饋**：提交答案後立即顯示正確與否
- **詳細解析**：每題都有解答說明
- **進度追蹤**：顯示答對/答錯數量和正確率
- **分類標籤**：題目依類別分類

### ❌ 錯題複習
- **錯題記錄**：自動記錄所有答錯的題目
- **錯題練習**：可專門針對錯題進行練習
- **錯題清單**：查看所有錯題記錄

### 📊 學習統計
- 題庫總數統計
- 練習次數統計
- 答對/答錯題數
- 正確率計算

## 使用方式

### 1. 安裝相依套件
```bash
flutter pub get
```

### 2. 執行應用程式
```bash
flutter run
```

### 3. 匯入題庫

#### 方式一：使用範例題目
1. 進入「匯入題庫」頁面
2. 點擊「匯入範例題目」按鈕
3. 系統會自動匯入內建的範例題目

#### 方式二：匯入 JSON 檔案
1. 準備符合格式的 JSON 題庫檔案（可參考 `sample_questions.json`）
2. 進入「匯入題庫」頁面
3. 點擊「從檔案匯入」按鈕
4. 選擇您的 JSON 檔案

### 4. 開始練習
1. 回到首頁
2. 點擊「開始練習」按鈕
3. 依序作答題目
4. 查看統計結果

### 5. 錯題複習
1. 首頁點擊「錯題複習」
2. 查看錯題清單
3. 點擊「開始錯題練習」重新練習

## JSON 題庫格式

題庫檔案應為 JSON 陣列格式，每個題目包含以下欄位：

```json
[
  {
    "questionText": "題目內容",
    "options": [
      "選項1",
      "選項2",
      "選項3",
      "選項4"
    ],
    "correctAnswer": 0,
    "explanation": "解析說明（選填）",
    "category": "類別名稱"
  }
]
```

### 欄位說明
- **questionText** (必填)：題目內容文字
- **options** (必填)：選項陣列，至少 2 個選項
- **correctAnswer** (必填)：正確答案的索引（0, 1, 2, 3...）
- **explanation** (選填)：答案解析說明
- **category** (必填)：題目分類

範例檔案請參考 `sample_questions.json`

## 技術架構

### 使用的套件
- **sqflite**: 本地資料庫儲存
- **path_provider**: 取得裝置檔案路徑
- **file_picker**: 檔案選擇器
- **provider**: 狀態管理（預留）

### 專案結構
```
lib/
├── main.dart                    # 應用程式入口
├── models/                      # 資料模型
│   ├── question.dart           # 題目模型
│   └── practice_record.dart    # 練習記錄模型
├── services/                    # 服務層
│   └── database_service.dart   # 資料庫服務
└── screens/                     # 畫面
    ├── home_screen.dart        # 首頁
    ├── practice_screen.dart    # 練習頁面
    ├── wrong_questions_screen.dart  # 錯題複習頁面
    └── import_questions_screen.dart # 匯入題庫頁面
```

### 資料庫設計
- **questions 表**：儲存題目資料
- **practice_records 表**：儲存練習記錄

## 開發說明

### 新增功能建議
- [ ] 支援多種題型（是非題、多選題等）
- [ ] 匯出學習報告
- [ ] 題目收藏功能
- [ ] 模擬考試模式（計時、隨機抽題）
- [ ] 雲端同步題庫
- [ ] 題目搜尋功能

### 已知限制
- 目前僅支援單選題
- 題庫儲存在本地，無雲端備份
- 錯題記錄不會自動清理

## 授權
此專案僅供學習使用。

## 聯絡資訊
如有問題或建議，歡迎提出 Issue。


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
