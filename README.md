# 金融商品喜好清單管理系統

## 1. 專案介紹

本專案為金融商品喜好清單管理系統，使用 **Spring Boot + Vue 3 + MyBatis + MySQL** 開發，提供金融商品及喜好清單的新增、查詢、修改與刪除功能。

系統透過 RESTful API 進行前後端資料交換，所有資料庫操作均透過 MyBatis 呼叫 Stored Procedures 執行。

使用者可以選擇金融商品、指定預計扣款帳號與購買數量，系統會自動計算商品總金額、手續費及預計扣款總金額。

## 2. 使用技術

| 分類 | 技術 |
|---|---|
| 後端 | Java 17、Spring Boot 4 |
| 前端 | Vue 3、Vite、JavaScript |
| API | RESTful API、JSON |
| HTTP 請求 | Axios |
| 資料庫 | MySQL 8.0 |
| 資料存取 | MyBatis |
| SQL | Stored Procedures |
| 交易管理 | Spring `@Transactional` |
| 專案建置 | Maven、npm |
| API 測試 | Postman |
| 版本控制 | Git、GitHub |

## 3. 系統架構

系統採用三層式架構：

```text
Presentation Layer（前端）
Vue 3 + Axios
        |
        | HTTP / JSON
        v
Application Layer（後端）
Spring Boot
        |
        v
Controller
        |
        v
Service
        |
        v
DAO / MyBatis Mapper
        |
        | CALL Stored Procedure
        v
Data Layer（資料庫）
MySQL
```

各層職責：

- **Controller**：接收 HTTP Request，回傳 API Response。
- **Service**：處理業務邏輯及 Transaction。
- **DAO / Mapper**：透過 MyBatis 呼叫 Stored Procedures。
- **Database**：執行資料查詢、修改、驗證及金額計算。
- **Vue**：提供使用者操作介面及資料顯示。

## 4. 專案目錄結構

```text
business-product/
├── BusinessProductManagement/
│   ├── DB/
│   │   ├── 01_schema.sql
│   │   ├── 02_data.sql
│   │   └── 03_procedures.sql
│   ├── src/
│   │   └── main/
│   │       ├── java/
│   │       │   └── com/example/demo/
│   │       │       ├── controller/
│   │       │       ├── service/
│   │       │       ├── dao/
│   │       │       ├── dto/
│   │       │       └── model/
│   │       └── resources/
│   │           ├── mappers/
│   │           └── application.properties
│   └── pom.xml
│
├── business-product-frontend/
│   ├── src/
│   │   ├── api/
│   │   ├── views/
│   │   └── App.vue
│   └── package.json
│
└── README.md
```

## 5. 主要功能

### 5.1 商品管理

- 查詢所有商品
- 新增商品
- 修改商品名稱、價格及手續費率
- 刪除商品
- 修改商品價格或手續費率時，同步更新相關喜好清單的金額
- 已被喜好清單使用的商品不可直接刪除

### 5.2 喜好清單管理

- 查詢所有喜好清單
- 選擇既有商品加入喜好清單
- 新增商品並同時加入喜好清單
- 指定預計扣款帳號
- 設定預計購買數量
- 修改喜好清單資料
- 刪除喜好清單資料
- 顯示使用者電子郵件及商品相關資訊

### 5.3 金額計算

系統根據商品價格、購買數量及手續費率，自動計算：

```text
商品總金額 = 商品價格 × 購買數量

手續費 = 商品總金額 × 手續費率

預計扣款總金額 = 商品總金額 + 手續費
```

金額計算由 Stored Procedures 執行，前端不直接決定儲存的金額。

## 6. 資料庫建立方式

### 6.1 環境需求

- MySQL 8.0
- MySQL Workbench（建議）

資料庫名稱：

```sql
business_product
```

### 6.2 執行 SQL

進入：

```text
BusinessProductManagement/DB/
```

依序執行：

1. `01_schema.sql`：建立資料庫及資料表。
2. `02_data.sql`：建立測試資料。
3. `03_procedures.sql`：建立 Stored Procedures。

請在全新資料庫執行初始化腳本，避免與既有資料衝突。

### 6.3 資料表

| 資料表 | 功能 |
|---|---|
| `user` | 儲存使用者基本資料、電子郵件及扣款帳號 |
| `product` | 儲存商品名稱、價格及手續費率 |
| `like_list` | 儲存喜好商品、購買數量及預計扣款金額 |

資料表關聯：

- `like_list.account` → `user.account`
- `like_list.no` → `product.no`

使用 InnoDB 儲存引擎，支援外鍵約束及 Transaction。

### 6.4 Stored Procedures

共使用 9 支 Stored Procedures：

| Stored Procedure | 功能 |
|---|---|
| `sp_get_all_users` | 查詢所有使用者 |
| `sp_get_all_products` | 查詢所有商品 |
| `sp_add_product` | 新增商品 |
| `sp_update_product` | 修改商品 |
| `sp_delete_product` | 刪除商品 |
| `sp_get_all_like_list` | 查詢喜好清單 |
| `sp_add_like_list` | 新增喜好清單 |
| `sp_update_like_list` | 修改喜好清單 |
| `sp_delete_like_list` | 刪除喜好清單 |

## 7. 後端啟動方式

### 7.1 環境需求

- JDK 17
- Maven
- MySQL 8.0

### 7.2 設定資料庫連線

修改：

```text
BusinessProductManagement/src/main/resources/application.properties
```

資料庫連線設定範例：

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/business_product
spring.datasource.username=root
spring.datasource.password=${DB_PASSWORD}
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

mybatis.mapper-locations=classpath:mappers/*.xml
mybatis.configuration.map-underscore-to-camel-case=true
```

其中 `DB_PASSWORD` 為環境變數，請設定為本機 MySQL 密碼。

Windows PowerShell：

```powershell
$env:DB_PASSWORD="你的MySQL密碼"
```

### 7.3 啟動 Spring Boot

進入後端專案：

```bash
cd BusinessProductManagement
```

執行：

```bash
mvn spring-boot:run
```

後端預設網址：

```text
http://localhost:8080
```

## 8. 前端啟動方式

### 8.1 環境需求

- Node.js（版本需符合專案 Vite 的要求）
- npm

### 8.2 安裝與啟動

進入前端專案：

```bash
cd business-product-frontend
```

安裝套件：

```bash
npm install
```

啟動開發伺服器：

```bash
npm run dev
```

前端預設網址：

```text
http://localhost:5173
```

前端透過 Axios 呼叫 Spring Boot REST API。

啟動順序建議：

1. MySQL
2. Spring Boot
3. Vue

## 9. RESTful API 說明

### 9.1 使用者 API

| Method | Endpoint | 功能 |
|---|---|---|
| GET | `/api/users` | 查詢所有使用者 |

### 9.2 商品 API

| Method | Endpoint | 功能 |
|---|---|---|
| GET | `/api/products` | 查詢所有商品 |
| POST | `/api/products` | 新增商品 |
| PUT | `/api/products/{no}` | 修改商品 |
| DELETE | `/api/products/{no}` | 刪除商品 |

新增商品範例：

```json
{
  "productName": "測試金融商品",
  "price": 10000,
  "feeRate": 0.05
}
```

### 9.3 喜好清單 API

| Method | Endpoint | 功能 |
|---|---|---|
| GET | `/api/like-list` | 查詢喜好清單 |
| POST | `/api/like-list` | 新增喜好清單 |
| PUT | `/api/like-list/{sn}` | 修改喜好清單 |
| DELETE | `/api/like-list/{sn}` | 刪除喜好清單 |
| POST | `/api/like-list/with-product` | 新增商品並加入喜好清單 |

新增喜好清單範例：

```json
{
  "account": "1111",
  "no": 2,
  "purchaseQuantity": 2
}
```

新增商品並加入喜好清單範例：

```json
{
  "productName": "新金融商品",
  "price": 10000,
  "feeRate": 0.05,
  "account": "1111",
  "purchaseQuantity": 2
}
```

## 10. Transaction 設計

系統使用 Spring `@Transactional` 管理跨資料表操作。

### 10.1 新增商品並加入喜好清單

執行流程：

```text
前端送出新增請求
        |
        v
LikeListController
        |
        v
LikeListService (@Transactional)
        |
        +-- 呼叫 sp_add_product
        |       |
        |       +-- 新增商品
        |       +-- 回傳商品編號
        |
        +-- 呼叫 sp_add_like_list
                |
                +-- 新增喜好清單
```

若新增喜好清單時發生例外，整個交易回滾，商品也不會保留。

### 10.2 修改商品

修改商品時，除了更新 `product` 資料表，也會重新計算所有引用該商品的 `like_list` 金額。

透過 Transaction 確保相關資料修改的一致性。

## 11. 資料驗證與安全性

### 11.1 SQL Injection

MyBatis Mapper 使用 `#{}` 參數綁定，避免直接將使用者輸入拼接進 SQL 指令。

### 11.2 XSS

Vue 使用 `{{ }}` 顯示一般文字資料，利用框架預設的 HTML 跳脫機制降低 XSS 風險。

### 11.3 輸入驗證

Stored Procedures 包含以下驗證：

- 商品名稱不可為空
- 商品價格必須大於 0
- 手續費率必須介於 0 至 1
- 購買數量必須大於 0
- 扣款帳號必須存在
- 商品必須存在
- 修改喜好清單前確認資料存在
- 已被喜好清單使用的商品不可直接刪除

系統透過 `SIGNAL SQLSTATE '45000'` 回傳資料驗證錯誤，並由後端例外處理機制轉換為 HTTP 回應。

## 12. 測試方式

使用 Postman 測試 RESTful API，並使用 MySQL Workbench 確認資料庫操作結果。

主要測試項目：

1. 商品新增、查詢、修改、刪除
2. 喜好清單新增、查詢、修改、刪除
3. 修改商品價格後，喜好清單金額同步更新
4. 商品價格及購買數量輸入驗證
5. 不存在的商品與扣款帳號驗證
6. 商品被喜好清單引用時的刪除限制
7. Transaction Rollback
8. 資料庫初始化與 Stored Procedures 還原測試

### Transaction Rollback 測試

使用不存在的扣款帳號新增商品及喜好清單：

```json
{
  "productName": "Rollback測試商品",
  "price": 10000,
  "feeRate": 0.05,
  "account": "NOT_EXIST",
  "purchaseQuantity": 2
}
```

預期結果：

- API 回傳扣款帳號不存在的錯誤。
- 商品與喜好清單不會新增成功。
- 可透過資料庫查詢確認交易回滾。

## 13. 補充說明

本專案以金融商品喜好清單管理為實作範圍，使用預先建立的測試使用者及扣款帳號。

目前未實作使用者登入、JWT 驗證、實際金融交易或真實帳戶扣款功能。

本系統僅供程式設計實作及功能展示使用。
