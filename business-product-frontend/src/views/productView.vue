
<script setup>
import { ref, onMounted } from "vue";
import {
  getProducts,
  addProduct,
  updateProduct,
  deleteProduct
} from "../api/apiService";

const products = ref([]);
const loading = ref(false);
const saving = ref(false);
const message = ref("");
const errorMessage = ref("");
const editingNo = ref(null);

const form = ref({
  productName: "",
  price: "",
  feeRate: ""
});

function clearMessages() {
  message.value = "";
  errorMessage.value = "";
}

function resetForm() {
  editingNo.value = null;
  form.value = {
    productName: "",
    price: "",
    feeRate: ""
  };
}

function getErrorMessage(error) {
  return error.response?.data?.message
    || error.message
    || "操作失敗";
}

async function loadProducts() {
  loading.value = true;
  clearMessages();

  try {
    const response = await getProducts();
    products.value = response.data;
  } catch (error) {
    errorMessage.value = getErrorMessage(error);
  } finally {
    loading.value = false;
  }
}

function editProduct(product) {
  clearMessages();
  editingNo.value = product.no;

  form.value = {
    productName: product.productName,
    price: product.price,
    feeRate: product.feeRate
  };
}

function cancelEdit() {
  resetForm();
  clearMessages();
}

async function saveProduct() {
  clearMessages();

  if (!form.value.productName.trim()) {
    errorMessage.value = "商品名稱不能為空";
    return;
  }

  if (form.value.price === "" ||
      !Number.isInteger(Number(form.value.price)) ||
      Number(form.value.price) <= 0) {
    errorMessage.value = "商品價格必須為大於 0 的整數";
    return;
  }

  if (form.value.feeRate === "" ||
      !Number.isFinite(Number(form.value.feeRate)) ||
      Number(form.value.feeRate) < 0 ||
      Number(form.value.feeRate) > 1) {
    errorMessage.value = "手續費率必須介於 0 到 1";
    return;
  }

  const payload = {
    productName: form.value.productName.trim(),
    price: Number(form.value.price),
    feeRate: Number(form.value.feeRate)
  };

  saving.value = true;

  try {
    const isEditing = editingNo.value !== null;

    if (isEditing) {
      await updateProduct(editingNo.value, payload);
    } else {
      await addProduct(payload);
    }

    resetForm();
    await loadProducts();

    message.value = isEditing
      ? "商品修改成功"
      : "商品新增成功";

  } catch (error) {
    errorMessage.value = getErrorMessage(error);
  } finally {
    saving.value = false;
  }
}

async function removeProduct(product) {
  clearMessages();

  if (!window.confirm(`確定要刪除「${product.productName}」嗎？`)) {
    return;
  }

  try {
    await deleteProduct(product.no);

    if (editingNo.value === product.no) {
      resetForm();
    }

    await loadProducts();
    window.alert("商品刪除成功");

  } catch (error) {
    window.alert(getErrorMessage(error));
  }
}

onMounted(loadProducts);
</script>

<template>
  <main class="product-page">
    <h1>金融商品管理</h1>

    <p v-if="message" class="success">{{ message }}</p>
    <p v-if="errorMessage" class="error">{{ errorMessage }}</p>

    <section class="panel">
      <h2>{{ editingNo === null ? "新增商品" : "修改商品" }}</h2>

      <form @submit.prevent="saveProduct">
        <div class="form-grid">
          <label>
            商品名稱
            <input
              v-model="form.productName"
              type="text"
              maxlength="45"
              required
            />
          </label>

          <label>
            商品價格
            <input
              v-model="form.price"
              type="number"
              min="1"
              step="1"
              required
            />
          </label>

          <label>
            手續費率（0～1）
            <input
              v-model="form.feeRate"
              type="number"
              min="0"
              max="1"
              step="0.0001"
              required
            />
          </label>
        </div>

        <div class="actions">
          <button type="submit" :disabled="saving">
            {{ saving ? "處理中..." : editingNo === null ? "新增" : "儲存修改" }}
          </button>

          <button
            v-if="editingNo !== null"
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
      <h2>商品清單</h2>

      <p v-if="loading">資料載入中...</p>

      <div v-else class="table-wrapper">
        <table>
          <thead>
            <tr>
              <th>商品編號</th>
              <th>商品名稱</th>
              <th>價格</th>
              <th>手續費率</th>
              <th>操作</th>
            </tr>
          </thead>

          <tbody>
            <tr v-for="product in products" :key="product.no">
              <td>{{ product.no }}</td>
              <td>{{ product.productName }}</td>
              <td>{{ Number(product.price).toLocaleString() }}</td>
              <td>{{ (Number(product.feeRate) * 100).toFixed(2) }}%</td>
              <td class="table-actions">
                <button
                  type="button"
                  class="secondary"
                  @click="editProduct(product)"
                >
                  修改
                </button>
                <button
                  type="button"
                  class="danger"
                  @click="removeProduct(product)"
                >
                  刪除
                </button>
              </td>
            </tr>

            <tr v-if="products.length === 0">
              <td colspan="5">目前沒有商品資料</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </main>
</template>

<style scoped>
.product-page {
  max-width: 1100px;
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
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 16px;
}

label {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

input {
  padding: 10px;
  border: 1px solid #bbb;
  border-radius: 6px;
  font-size: 15px;
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

.error {
  color: #dc2626;
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
</style>
