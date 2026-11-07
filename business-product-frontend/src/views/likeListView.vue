
<script setup>
import { ref, computed, onMounted } from "vue";
import {
  getProducts,
  getMyAccounts,
  getLikeList,
  addLikeList,
  addLikeListWithProduct,
  updateLikeList,
  deleteLikeList
} from "../api/apiService";

const products = ref([]);
const accounts = ref([]);
const likeList = ref([]);

const loading = ref(false);
const saving = ref(false);
const editingSn = ref(null);
const message = ref("");
const productMode = ref("existing");

const newProduct = ref({
  productName: "",
  price: "",
  feeRate: ""
});

const form = ref({
  account: "",
  no: "",
  purchaseQuantity: 1
});

const selectedProduct = computed(() =>
  products.value.find(
    product => product.no === Number(form.value.no)
  )
);

const estimatedAmount = computed(() => {
  const isNew = editingSn.value === null
    && productMode.value === "new";

  const price = isNew
    ? Number(newProduct.value.price)
    : Number(selectedProduct.value?.price);

  const feeRate = isNew
    ? Number(newProduct.value.feeRate)
    : Number(selectedProduct.value?.feeRate);

  const quantity = Number(form.value.purchaseQuantity);

  if (isNew &&
      (newProduct.value.price === "" ||
       newProduct.value.feeRate === "")) {
    return null;
  }

  if (!Number.isFinite(price) ||
      !Number.isFinite(feeRate) ||
      !Number.isInteger(quantity) ||
      price <= 0 ||
      feeRate < 0 ||
      feeRate > 1 ||
      quantity <= 0) {
    return null;
  }

  const amount = price * quantity;
  const fee = amount * feeRate;

  return {
    productAmount: amount,
    totalFee: fee,
    totalAmount: amount + fee
  };
});

function getErrorMessage(error) {
  return error.response?.data?.message
    || error.message
    || "操作失敗";
}

function resetForm() {
  editingSn.value = null;
  productMode.value = "existing";

  form.value = {
    account: "",
    no: "",
    purchaseQuantity: 1
  };

  newProduct.value = {
    productName: "",
    price: "",
    feeRate: ""
  };
}

async function loadData() {
  loading.value = true;

  try {
    const [productsResponse, accountsResponse, likeListResponse] =
      await Promise.all([
        getProducts(),
        getMyAccounts(),
        getLikeList()
      ]);

    products.value = productsResponse.data;
    accounts.value = accountsResponse.data;
    likeList.value = likeListResponse.data;

  } catch (error) {
    window.alert(getErrorMessage(error));
  } finally {
    loading.value = false;
  }
}

async function refreshLikeList() {
  const response = await getLikeList();
  likeList.value = response.data;
}

function editItem(item) {
  editingSn.value = item.sn;
  message.value = "";

  form.value = {
    account: item.account,
    no: item.no,
    purchaseQuantity: item.purchaseQuantity
  };

  window.scrollTo({ top: 0, behavior: "smooth" });
}

function cancelEdit() {
  resetForm();
  message.value = "";
}

async function saveItem() {
  message.value = "";

  if (!form.value.account) {
    window.alert("請選擇扣款帳號");
    return;
  }

  const quantity = Number(form.value.purchaseQuantity);

  if (!Number.isInteger(quantity) || quantity <= 0) {
    window.alert("購買數量必須為大於 0 的整數");
    return;
  }

  const isEditing = editingSn.value !== null;

  if ((isEditing || productMode.value === "existing") && !form.value.no) {
    window.alert("請選擇金融商品");
    return;
  }

  if (!isEditing && productMode.value === "new") {
    if (!newProduct.value.productName.trim()) {
      window.alert("商品名稱不能為空");
      return;
    }

    if (newProduct.value.price === "" ||
        !Number.isInteger(Number(newProduct.value.price)) ||
        Number(newProduct.value.price) <= 0) {
      window.alert("商品價格必須為大於 0 的整數");
      return;
    }

    if (newProduct.value.feeRate === "" ||
        !Number.isFinite(Number(newProduct.value.feeRate)) ||
        Number(newProduct.value.feeRate) < 0 ||
        Number(newProduct.value.feeRate) > 1) {
      window.alert("手續費率必須介於 0 到 1");
      return;
    }
  }

  saving.value = true;

  try {
    if (isEditing) {
      await updateLikeList(editingSn.value, {
        account: form.value.account,
        no: Number(form.value.no),
        purchaseQuantity: quantity
      });

    } else if (productMode.value === "new") {
      await addLikeListWithProduct({
        productName: newProduct.value.productName.trim(),
        price: Number(newProduct.value.price),
        feeRate: Number(newProduct.value.feeRate),
        account: form.value.account,
        purchaseQuantity: quantity
      });

    } else {
      await addLikeList({
        account: form.value.account,
        no: Number(form.value.no),
        purchaseQuantity: quantity
      });
    }

    // 重新取得商品及喜好清單
    const [productsResponse, likeListResponse] =
      await Promise.all([
        getProducts(),
        getLikeList()
      ]);

    products.value = productsResponse.data;
    likeList.value = likeListResponse.data;

    resetForm();

    message.value = isEditing
      ? "喜好商品修改成功"
      : "喜好商品新增成功";

  } catch (error) {
    window.alert(getErrorMessage(error));
  } finally {
    saving.value = false;
  }
}

async function removeItem(item) {
  if (!window.confirm(`確定刪除「${item.productName}」嗎？`)) {
    return;
  }

  try {
    await deleteLikeList(item.sn);

    if (editingSn.value === item.sn) {
      resetForm();
    }

    await refreshLikeList();
    message.value = "喜好商品刪除成功";

  } catch (error) {
    window.alert(getErrorMessage(error));
  }
}

function formatMoney(value) {
  if (value === null || value === undefined) {
    return "-";
  }

  return Number(value).toLocaleString("zh-TW", {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  });
}

onMounted(loadData);
</script>

<template>
  <main class="like-page">
    <h1>喜好金融商品管理</h1>

    <p v-if="message" class="success">{{ message }}</p>

    <section class="panel">
      <h2>
        {{ editingSn === null ? "新增喜好金融商品" : "修改喜好金融商品" }}
      </h2>

      <form @submit.prevent="saveItem">
        <div class="form-grid">
          <label>
            扣款帳號
            <select v-model="form.account" required>
              <option value="">請選擇帳號</option>

              <option
                v-for="account in accounts"
                :key="account"
                :value="account"
              >
                {{ account }}
              </option>
            </select>
          </label>

          <div class="product-section">
            <div v-if="editingSn === null" class="mode-switch">
              <label>
                <input
                  v-model="productMode"
                  type="radio"
                  value="existing"
                />
                選擇既有商品
              </label>

              <label>
                <input
                  v-model="productMode"
                  type="radio"
                  value="new"
                />
                建立新商品
              </label>
            </div>

            <label v-if="editingSn !== null || productMode === 'existing'">
              金融商品
              <select v-model="form.no" required>
              <option value="">請選擇商品</option>
              <option
                v-for="product in products"
                :key="product.no"
                :value="product.no"
              >
                {{ product.productName }}
              </option>
              </select>
            </label>

            <div v-else class="new-product-fields">
              <label>
              商品名稱
              <input
                v-model="newProduct.productName"
                type="text"
                maxlength="45"
                required
              />
              </label>

              <label>
              商品價格
              <input
                v-model="newProduct.price"
                type="number"
                min="1"
                step="1"
                required
              />
              </label>

              <label>
                手續費率（0～1）
                <input
                  v-model="newProduct.feeRate"
                  type="number"
                  min="0"
                  max="1"
                  step="0.0001"
                  required
                />
              </label>
            </div>
          </div>

          <label>
            購買數量
            <input
              v-model.number="form.purchaseQuantity"
              type="number"
              min="1"
              step="1"
              required
            />
          </label>
        </div>

        <div v-if="estimatedAmount" class="estimate">
          <p>商品總金額：{{ formatMoney(estimatedAmount.productAmount) }}</p>
          <p>預估手續費：{{ formatMoney(estimatedAmount.totalFee) }}</p>
          <p>
            <strong>
              預計扣款總金額：{{ formatMoney(estimatedAmount.totalAmount) }}
            </strong>
          </p>
        </div>

        <div class="actions">
          <button type="submit" :disabled="saving || loading">
            {{ saving ? "處理中..." : editingSn === null ? "新增" : "儲存修改" }}
          </button>

          <button
            v-if="editingSn !== null"
            type="button"
            class="secondary"
            @click="cancelEdit"
          >
            取消修改
          </button>
        </div>
      </form>
    </section>

    <section class="panel">
      <h2>喜好商品清單</h2>

      <p v-if="loading">資料載入中...</p>

      <div v-else class="table-wrapper">
        <table>
          <thead>
            <tr>
              <th>編號</th>
              <th>使用者</th>
              <th>金融商品</th>
              <th>扣款帳號</th>
              <th>購買數量</th>
              <th>商品總金額</th>
              <th>手續費</th>
              <th>預計扣款總額</th>
              <th>Email</th>
              <th>操作</th>
            </tr>
          </thead>

          <tbody>
            <tr v-for="item in likeList" :key="item.sn">
              <td>{{ item.sn }}</td>
              <td>{{ item.username }}</td>
              <td>{{ item.productName }}</td>
              <td>{{ item.account }}</td>
              <td>{{ item.purchaseQuantity }}</td>
              <td>{{ formatMoney(item.productAmount) }}</td>
              <td>{{ formatMoney(item.totalFee) }}</td>
              <td>{{ formatMoney(item.totalAmount) }}</td>
              <td>{{ item.email }}</td>
              <td class="table-actions">
                <button
                  type="button"
                  class="secondary"
                  @click="editItem(item)"
                >
                  修改
                </button>

                <button
                  type="button"
                  class="danger"
                  @click="removeItem(item)"
                >
                  刪除
                </button>
              </td>
            </tr>

            <tr v-if="likeList.length === 0">
              <td colspan="10">目前沒有喜好商品資料</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </main>
</template>

<style scoped>
.like-page {
  max-width: 1400px;
  margin: 35px auto;
  padding: 0 20px;
  font-family: Arial, sans-serif;
}

h1 {
  text-align: center;
}

.panel {
  background: white;
  border: 1px solid #ddd;
  border-radius: 10px;
  padding: 24px;
  margin-bottom: 24px;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
}

label {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

input, select {
  padding: 10px;
  border: 1px solid #bbb;
  border-radius: 6px;
  font-size: 15px;
  width: 100%;
}

.estimate {
  background: #f1f5f9;
  border-radius: 8px;
  padding: 12px 20px;
  margin-top: 20px;
}

.estimate p {
  margin: 8px 0;
}

.actions {
  display: flex;
  gap: 10px;
  margin-top: 20px;
}

button {
  padding: 9px 16px;
  border: none;
  border-radius: 6px;
  background: #2563eb;
  color: white;
  cursor: pointer;
}

button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.secondary {
  background: #64748b;
}

.danger {
  background: #dc2626;
}

.success {
  color: #15803d;
}

.table-wrapper {
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th, td {
  border-bottom: 1px solid #ddd;
  padding: 12px;
  text-align: center;
}

th {
  background: #f1f5f9;
}

.table-actions {
  white-space: nowrap;
}

.table-actions button {
  margin: 3px;
}

.product-section {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.mode-switch {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
}

.mode-switch label {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.mode-switch input[type="radio"] {
  width: auto;
  margin: 0;
}

.new-product-fields {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
</style>
