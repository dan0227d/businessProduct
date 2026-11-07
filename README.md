# 金融商品喜好清單管理系統（V2.0）

以 **Vue 3、Spring Boot、MyBatis、MySQL 8** 建立的金融商品喜好清單管理系統。使用者可登入、註冊、管理金融商品，並使用自己的扣款帳號新增、查詢、修改及刪除喜好清單。專案僅供程式設計測驗與展示，**不執行真實扣款**。

## 1. 技術與架構

| 類別 | 技術 |
| --- | --- |
| 前端 | Vue 3、Vite、JavaScript、Axios |
| 後端 | Java 17、Spring Boot 4、Spring Security、RESTful API |
| 登入驗證 | HTTP Session、BCrypt 密碼雜湊 |
| 資料存取 | MyBatis Mapper XML 呼叫 MySQL Stored Procedures |
| 資料庫 | MySQL 8、InnoDB |
| 交易管理 | Spring `@Transactional` |
| 建置 | Maven、npm |

```text
瀏覽器
  │
  ▼
Vue 3 / Axios（展示層；開發時由 Vite 提供）
  │ HTTP / JSON（Session Cookie）
  ▼
Spring Boot / Spring Security（應用層）
  ├─ Controller：API / DTO
  ├─ Service：業務邏輯 / Transaction
  ├─ DAO + MyBatis XML：資料存取
  └─ Config / Exception Handler：共用設定與錯誤處理
  │ CALL Stored Procedure
  ▼
MySQL 8（資料庫層）
```

上述為應用程式的邏輯三層架構。**開發環境使用 Vite 開發伺服器，不代表已另外部署正式 Web Server**；正式部署可將 Vue 編譯結果交由 Nginx 等 Web Server 提供，並以 Spring Boot 作為 Application Server、MySQL 作為資料庫。

## 2. 主要功能

- **帳號功能**：註冊、登入、登出；使用 HTTP Session 維持登入狀態，密碼使用 BCrypt 雜湊。
- **商品管理**：查詢、新增、修改及刪除商品名稱、價格與手續費率；已被喜好清單引用的商品不得直接刪除。
- **喜好清單**：選擇商品或新增商品並加入清單；設定扣款帳號及購買數量；查詢、修改、刪除自己的喜好清單。
- **多扣款帳號**：同一使用者可對應多個 `user_account` 帳號；新增或修改喜好清單時檢查帳號歸屬。
- **金額計算**：由 Stored Procedure 計算並儲存，不信任前端傳入的總金額。

計算規則：

```text
商品總金額 = 商品價格 × 購買數量
總手續費   = 商品總金額 × 手續費率
預計扣款總金額 = 商品總金額 + 總手續費
```

修改商品價格或費率時，`sp_update_product` 會重新計算引用該商品的喜好清單金額。

## 3. 資料庫設計

| 資料表 | 用途 |
| --- | --- |
| `user` | 使用者編號、姓名、Email、主要扣款帳號、BCrypt 密碼雜湊 |
| `user_account` | 使用者與多個扣款帳號的對應 |
| `product` | 商品名稱、價格、手續費率 |
| `like_list` | 使用者選擇的商品、扣款帳號、數量與金額 |

主要關聯：

```text
user.userid ──< user_account.userid
user_account.account ──< like_list.account
product.no ──< like_list.no
```

`user.account` 仍保留為使用者的主要帳號；**喜好清單的外鍵應指向 `user_account.account`**，以支援多帳號。資料庫的 `password` 欄位為 `VARCHAR(255)`。

### SQL 初始化檔案

位於 `BusinessProductManagement/DB/`：

| 檔案 | 用途 |
| --- | --- |
| `01_schema.sql` | 建立 `business_product` 及四張資料表、主鍵、唯一鍵、外鍵 |
| `02_data.sql` | 匯入示範資料（2026-11-07 資料庫快照） |
| `03_procedures.sql` | 建立 15 支 Stored Procedures |

**請在全新、空白的 MySQL 資料庫依序執行**：

1. `01_schema.sql`
2. `02_data.sql`
3. `03_procedures.sql`

### 測試帳號

系統提供以下測試帳號，方便展示登入及喜好金融商品管理功能。

| 使用者 | Email | 密碼 |
|---|---|---|
| 王小明 | test01@example.com | 1234 |
| 陳小華 | test02@example.com | 1234 |
| 林小美 | test03@example.com | 1234 |

登入後可操作金融商品及個人的喜好清單。

其中王小明擁有三個扣款帳號（1111、1114、1115），可用於測試多帳號選擇功能。

**注意：** 以上帳號及密碼僅供本機測試與專案展示使用，請勿用於正式環境。


### Stored Procedures（15 支）

| 名稱 | 功能 |
| --- | --- |
| `sp_get_all_users` | 查詢使用者資料 |
| `sp_get_user_by_email` | 依 Email 查詢登入所需使用者資料 |
| `sp_register_user` | 新增使用者及其主要扣款帳號對應 |
| `sp_get_user_accounts` | 查詢指定使用者的扣款帳號 |
| `sp_get_all_products` | 查詢商品 |
| `sp_add_product` | 新增商品 |
| `sp_update_product` | 更新商品及引用商品的清單金額 |
| `sp_delete_product` | 刪除未被引用的商品 |
| `sp_get_all_like_list` | 查詢所有喜好清單（不應直接開放一般使用者） |
| `sp_get_user_like_list` | 查詢指定使用者的喜好清單 |
| `sp_add_like_list` | 新增喜好清單並計算金額 |
| `sp_update_like_list` | 更新喜好清單並重新計算金額 |
| `sp_delete_like_list` | 刪除喜好清單 |
| `sp_check_account_owner` | 檢查扣款帳號是否屬於使用者 |
| `sp_check_like_list_owner` | 檢查喜好清單是否屬於使用者 |

## 4. 專案結構

```text
business-product/
├── BusinessProductManagement/
│   ├── DB/
│   │   ├── 01_schema.sql
│   │   ├── 02_data.sql
│   │   └── 03_procedures.sql
│   ├── src/main/java/com/example/demo/
│   │   ├── controller/
│   │   ├── service/
│   │   ├── dao/
│   │   ├── dto/
│   │   ├── model/
│   │   └── config/
│   ├── src/main/resources/
│   │   ├── mappers/
│   │   └── application.properties
│   └── pom.xml
├── business-product-frontend/
│   ├── src/api/
│   ├── src/views/
│   ├── src/App.vue
│   └── package.json
└── README.md
```

## 5. 執行方式

**需求**：JDK 17、Maven、MySQL 8、Node.js/npm（Node.js 版本依專案 Vite 的需求）。

### 5.1 初始化資料庫

在 MySQL Workbench 依第 3 節順序執行三個 SQL 檔。確認資料庫名稱為 `business_product`。

### 5.2 啟動後端

在 `BusinessProductManagement/src/main/resources/application.properties` 設定資料庫連線，以下為**範例**，實際以專案設定為準：

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/business_product
spring.datasource.username=root
spring.datasource.password=${DB_PASSWORD}
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
mybatis.mapper-locations=classpath:mappers/*.xml
```

PowerShell 設定密碼並啟動：

```powershell
$env:DB_PASSWORD="你的本機MySQL密碼"
cd BusinessProductManagement
mvn spring-boot:run
```

後端預設為 `http://localhost:8080`。

### 5.3 啟動前端

另開終端機：

```bash
cd business-product-frontend
npm install
npm run dev
```

Vite 預設網址為 `http://localhost:5173`。前端 Axios 呼叫 `/api` 後端服務，使用 `withCredentials: true` 傳送 Session Cookie；請確認後端 CORS 設定允許前端來源。

## 6. RESTful API

| Method | Endpoint | 功能 |
| --- | --- | --- |
| POST | `/api/auth/register` | 註冊 |
| POST | `/api/auth/login` | 登入 |
| GET | `/api/auth/me` | 查詢目前登入身分 |
| POST | `/api/auth/logout` | 登出 |
| GET | `/api/users/accounts` | 查詢目前登入使用者的扣款帳號 |
| GET | `/api/products` | 查詢商品 |
| POST | `/api/products` | 新增商品 |
| PUT | `/api/products/{no}` | 修改商品 |
| DELETE | `/api/products/{no}` | 刪除商品 |
| GET | `/api/like-list` | 查詢目前登入使用者的喜好清單 |
| POST | `/api/like-list` | 新增喜好清單 |
| PUT | `/api/like-list/{sn}` | 修改喜好清單 |
| DELETE | `/api/like-list/{sn}` | 刪除喜好清單 |
| POST | `/api/like-list/with-product` | 新增商品並加入喜好清單 |

範例：

```json
{
  "account": "1111",
  "no": 2,
  "purchaseQuantity": 2
}
```

## 7. 安全性與交易設計

- **SQL Injection**：MyBatis 使用 `#{}` 綁定參數；Stored Procedures 使用參數化值，避免直接拼接不可信任 SQL 字串。
- **XSS**：Vue 使用 `{{ }}` 文字插值，依賴框架預設的 HTML 跳脫；不應對不可信任輸入使用 `v-html`。
- **認證**：Spring Security + HTTP Session，密碼以 BCrypt 驗證。
- **資料隔離**：使用登入者身分查詢喜好清單；新增、修改、刪除時由 Service 檢查帳號或清單歸屬。
- **Transaction**：新增商品並加入清單、註冊時的多表異動，以及商品更新與清單金額重算，應由 Spring `@Transactional` 確保原子性。

**安全性注意**：開發階段若仍使用 `.csrf(csrf -> csrf.disable())`，代表 Session 架構的 CSRF 防護尚未完成；正式部署前應啟用並讓前端傳送 CSRF Token。另需檢查所有使用者查詢與商品管理 API 的授權限制。此處描述設計與待驗證事項，不宣稱已通過完整資安測試。

## 8. 建議測試項目

1. 註冊後登入、重新整理頁面保留 Session、登出後不可存取受保護 API。
2. 不同使用者僅能讀取及操作自己的喜好清單。
3. 多個扣款帳號可選擇，不能使用其他使用者的帳號。
4. 商品與喜好清單 CRUD；商品被引用時不可刪除。
5. 修改商品價格或費率後，引用該商品的清單金額重新計算。
6. 商品新增成功但清單新增失敗時，確認 Transaction Rollback。
7. 檢查 MyBatis Mapper 是否使用 `#{}` 而非不安全的 `${}`。
8. 在全新資料庫依序執行 DB 腳本，確認所有資料表、測試資料及 15 支 Stored Procedures 建立成功。

> 本專案僅供技術展示與測試，不涉及真實金融帳戶或資金交易。
