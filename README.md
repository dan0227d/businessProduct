\# 金融商品喜好清單管理系統



\## 1. 專案介紹



本專案為金融商品喜好清單管理系統，使用 Spring Boot 建立 RESTful API，搭配 Vue 3 開發前端介面，並使用 MySQL 儲存資料。



資料庫操作透過 MyBatis 呼叫 Stored Procedures 執行，支援金融商品與喜好清單的新增、查詢、修改及刪除。



系統可根據商品價格、手續費率及預計購買數量，自動計算商品總金額、手續費及預計扣款總金額。



\## 2. 使用技術



| 分類 | 技術 |

|---|---|

| 後端 | Java 17、Spring Boot |

| 前端 | Vue 3、Vite、JavaScript |

| API | RESTful API |

| HTTP 請求 | Axios |

| 資料庫 | MySQL 8.0 |

| 資料存取 | MyBatis |

| SQL | Stored Procedures |

| 交易管理 | Spring `@Transactional` |

| 專案建置 | Maven、npm |

| API 測試 | Postman |



\## 3. 系統架構



系統採用三層式架構：



```text

Presentation Layer

Vue 3 + Axios

&#x20;       |

&#x20;       | HTTP / JSON

&#x20;       v

Application Layer

Spring Boot

&#x20;       |

&#x20;       v

Controller

&#x20;       |

&#x20;       v

Service

&#x20;       |

&#x20;       v

MyBatis Mapper

&#x20;       |

&#x20;       | CALL Stored Procedure

&#x20;       v

Data Layer

MySQL

```



前端負責使用者介面及資料顯示；後端負責業務邏輯與交易管理；資料庫透過 Stored Procedures 執行資料操作與金額計算。



\## 4. 主要功能



\### 商品管理



\- 查詢商品清單

\- 新增商品

\- 修改商品名稱、價格及手續費率

\- 刪除未被喜好清單引用的商品

\- 修改商品價格或手續費率時，同步更新相關喜好清單金額



\### 喜好清單管理



\- 查詢喜好清單

\- 將既有商品加入喜好清單

\- 新增商品並同時加入喜好清單

\- 設定預計扣款帳號及購買數量

\- 修改喜好清單資料

\- 刪除喜好清單資料

\- 顯示使用者電子郵件、商品資訊與預計扣款金額



\### 金額計算



系統依照以下公式計算：



```text

商品總金額 = 商品價格 × 購買數量



手續費 = 商品總金額 × 手續費率



預計扣款總金額 = 商品總金額 + 手續費

```



計算由資料庫 Stored Procedures 執行，避免由前端自行決定最終儲存金額。



\## 5. 專案目錄



建議將前後端及資料庫腳本整理為：



```text

business-product/

├── BusinessProductManagement/

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

├── DB/

│   ├── 01\_schema.sql

│   ├── 02\_data.sql

│   └── 03\_procedures.sql

│

└── README.md

```



\## 6. 資料庫建立



\### 6.1 建立資料庫



使用 MySQL Workbench，依序執行 `DB` 資料夾內的 SQL：



1\. `01\_schema.sql`：建立資料庫及資料表。

2\. `02\_data.sql`：新增測試資料。

3\. `03\_procedures.sql`：建立 Stored Procedures。



資料庫名稱：



```sql

business\_product

```



\### 6.2 資料表



| 資料表 | 說明 |

|---|---|

| `user` | 使用者基本資料及扣款帳號 |

| `product` | 商品名稱、價格、手續費率 |

| `like\_list` | 喜好清單、購買數量及預計扣款金額 |



`like\_list.account` 關聯 `user.account`，`like\_list.no` 關聯 `product.no`。



\### 6.3 Stored Procedures



共使用 9 支 Stored Procedures：



```text

sp\_get\_all\_users

sp\_get\_all\_products

sp\_add\_product

sp\_update\_product

sp\_delete\_product

sp\_get\_all\_like\_list

sp\_add\_like\_list

sp\_update\_like\_list

sp\_delete\_like\_list

```



\## 7. 後端啟動方式



\### 7.1 環境需求



\- JDK 17

\- Maven

\- MySQL 8.0



\### 7.2 設定資料庫連線



修改：



```text

BusinessProductManagement/src/main/resources/application.properties

```



資料庫設定範例：



```properties

spring.application.name=BusinessProductManagement



spring.datasource.url=jdbc:mysql://localhost:3306/business\_product

spring.datasource.username=root

spring.datasource.password=${DB\_PASSWORD}



spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver



mybatis.mapper-locations=classpath:mappers/\*.xml

mybatis.configuration.map-underscore-to-camel-case=true

```



啟動前需設定環境變數 `DB\_PASSWORD`，填入本機 MySQL 密碼。



Windows PowerShell 範例：



```powershell

$env:DB\_PASSWORD="你的MySQL密碼"

```



\### 7.3 啟動後端



進入後端資料夾：



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



\## 8. 前端啟動方式



環境需求：Node.js 與 npm，建議使用符合 Vite 8 要求的 Node.js 版本。



進入前端資料夾：



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



預設開發網址：



```text

http://localhost:5173

```



前端透過 Axios 呼叫後端 API：



```javascript

const api = axios.create({

&#x20;   baseURL: "http://localhost:8080/api",

&#x20;   timeout: 10000

});

```



請先確認 MySQL 與 Spring Boot 已啟動，再操作前端。



\## 9. REST API



\### 使用者



| Method | API | 功能 |

|---|---|---|

| GET | `/api/users` | 查詢所有使用者 |



\### 商品管理



| Method | API | 功能 |

|---|---|---|

| GET | `/api/products` | 查詢商品 |

| POST | `/api/products` | 新增商品 |

| PUT | `/api/products/{no}` | 修改商品 |

| DELETE | `/api/products/{no}` | 刪除商品 |



新增商品 Request Body：



```json

{

&#x20; "productName": "測試金融商品",

&#x20; "price": 10000,

&#x20; "feeRate": 0.05

}

```



\### 喜好清單管理



| Method | API | 功能 |

|---|---|---|

| GET | `/api/like-list` | 查詢喜好清單 |

| POST | `/api/like-list` | 新增喜好清單 |

| PUT | `/api/like-list/{sn}` | 修改喜好清單 |

| DELETE | `/api/like-list/{sn}` | 刪除喜好清單 |

| POST | `/api/like-list/with-product` | 新增商品並加入喜好清單 |



新增喜好清單 Request Body：



```json

{

&#x20; "account": "1111",

&#x20; "no": 1,

&#x20; "purchaseQuantity": 2

}

```



新增商品並加入喜好清單 Request Body：



```json

{

&#x20; "productName": "新金融商品",

&#x20; "price": 10000,

&#x20; "feeRate": 0.05,

&#x20; "account": "1111",

&#x20; "purchaseQuantity": 2

}

```



\## 10. Transaction 設計



當使用者新增商品並同時加入喜好清單時，系統需要執行兩項資料庫操作：



1\. 新增 `product`，取得新商品編號。

2\. 新增 `like\_list`，關聯剛建立的商品。



Service 使用 Spring `@Transactional` 管理交易：



```java

@Transactional

public void addWithProduct(LikeListRequest request) {

&#x20;   // 新增商品

&#x20;   // 取得商品編號

&#x20;   // 新增喜好清單

}

```



若第二項操作發生例外，整筆交易會回滾，避免只新增商品卻未成功建立喜好清單。



修改商品時也使用 Transaction，確保商品資料與相關喜好清單金額更新的一致性。



\## 11. 資料驗證與安全性



\### SQL Injection



MyBatis Mapper 使用 `#{}` 進行參數綁定，避免直接拼接使用者輸入的 SQL 字串。



\### XSS



Vue 使用文字插值 `{{ }}` 顯示使用者及商品資料，避免將一般輸入內容直接當成 HTML 執行。



\### 資料驗證



Stored Procedures 包含以下驗證：



\- 商品名稱不可為空。

\- 商品價格必須大於 0。

\- 手續費率必須介於 0 與 1。

\- 購買數量必須大於 0。

\- 扣款帳號必須存在。

\- 商品必須存在。

\- 修改喜好清單前，確認資料存在。

\- 被喜好清單引用的商品不可直接刪除。



上述措施為目前實作的基本防護，不代表已完成完整安全性滲透測試。



\## 12. 測試方式



使用 Postman 測試 REST API，並透過 MySQL Workbench 檢查資料結果。



測試內容包含：



\- 商品 CRUD

\- 喜好清單 CRUD

\- 商品價格與費率修改後的金額同步

\- 無效購買數量

\- 不存在的商品及扣款帳號

\- 被引用商品的刪除限制

\- 新增商品與喜好清單失敗時的 Transaction Rollback

\- 資料庫 DDL、DML 與 Stored Procedures 還原測試



Transaction Rollback 測試可使用不存在的扣款帳號，確認 API 回傳錯誤後，新增的商品不會殘留在資料庫中。



\## 13. 補充說明



本專案以金融商品喜好清單管理為實作範圍，使用預先建立的測試使用者及扣款帳號。



目前未實作使用者登入、實際金融交易或真實帳戶扣款功能。



本系統僅供程式設計實作與功能展示使用。



