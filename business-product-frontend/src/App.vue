
<script setup>
import { ref, onMounted } from "vue";
import ProductView from "./views/ProductView.vue";
import LikeListView from "./views/LikeListView.vue";
import { login, register, logout, getMe } from "./api/apiService";

const currentPage = ref("likeList");

const user = ref(null);
const email = ref("");
const password = ref("");
const message = ref("");
const messageType = ref("error");
const loading = ref(true);
const submitting = ref(false);

// 登入 / 註冊畫面切換
const authMode = ref("login");

// 註冊表單
const registerForm = ref({
  userid: "",
  username: "",
  email: "",
  account: "",
  password: "",
  confirmPassword: ""
});

// 頁面初始化：確認 Session 是否仍有效
onMounted(async () => {
  try {
    const response = await getMe();
    user.value = response.data;
  } catch (error) {
    user.value = null;
  } finally {
    loading.value = false;
  }
});

// 切換登入 / 註冊
const switchAuthMode = (mode) => {
  authMode.value = mode;
  message.value = "";
  messageType.value = "error";
};

// 登入
const handleLogin = async () => {
  message.value = "";
  submitting.value = true;

  try {
    const response = await login({
      email: email.value.trim(),
      password: password.value
    });

    user.value = response.data;
    password.value = "";
    currentPage.value = "likeList";
  } catch (error) {
    messageType.value = "error";
    message.value =
      error.response?.data?.message || "登入失敗，請稍後再試";
  } finally {
    submitting.value = false;
  }
};

// 註冊
const handleRegister = async () => {
  message.value = "";
  messageType.value = "error";

  const form = registerForm.value;

  // 檢查空白資料
  if (
    !form.userid.trim() ||
    !form.username.trim() ||
    !form.email.trim() ||
    !form.account.trim() ||
    !form.password
  ) {
    message.value = "請完整填寫註冊資料";
    return;
  }

  // 檢查密碼長度
  if (form.password.length < 8) {
    message.value = "密碼至少需要 8 個字元";
    return;
  }

  // 檢查確認密碼
  if (form.password !== form.confirmPassword) {
    message.value = "兩次輸入的密碼不一致";
    return;
  }

  submitting.value = true;

  try {
    await register({
      userid: form.userid.trim(),
      username: form.username.trim(),
      email: form.email.trim(),
      account: form.account.trim(),
      password: form.password
    });

    // 註冊成功後預先填入 Email
    email.value = form.email.trim();
    password.value = "";

    // 清空註冊資料
    registerForm.value = {
      userid: "",
      username: "",
      email: "",
      account: "",
      password: "",
      confirmPassword: ""
    };

    // 返回登入畫面
    authMode.value = "login";

    messageType.value = "success";
    message.value = "註冊成功，請使用新帳號登入";

  } catch (error) {
    messageType.value = "error";
    message.value =
      error.response?.data?.message || "註冊失敗，請稍後再試";
  } finally {
    submitting.value = false;
  }
};

// 登出
const handleLogout = async () => {
  submitting.value = true;
  message.value = "";

  try {
    await logout();

    user.value = null;
    email.value = "";
    password.value = "";
    currentPage.value = "likeList";
    authMode.value = "login";

  } catch (error) {
    messageType.value = "error";
    message.value = "登出失敗，請稍後再試";
  } finally {
    submitting.value = false;
  }
};
</script>

<template>
  <!-- 確認 Session 中 -->
  <div v-if="loading" class="loading">
    正在確認登入狀態...
  </div>

  <!-- 未登入 -->
  <div v-else-if="!user" class="login-page">

    <!-- 登入表單 -->
    <form
      v-if="authMode === 'login'"
      class="login-box"
      @submit.prevent="handleLogin"
    >
      <h1>金融商品管理系統</h1>
      <h2>使用者登入</h2>

      <label for="email">Email</label>
      <input
        id="email"
        v-model="email"
        type="email"
        autocomplete="username"
        required
      />

      <label for="password">密碼</label>
      <input
        id="password"
        v-model="password"
        type="password"
        autocomplete="current-password"
        required
      />

      <p
        v-if="message"
        :class="messageType === 'success' ? 'success' : 'error'"
      >
        {{ message }}
      </p>

      <button type="submit" :disabled="submitting">
        {{ submitting ? "登入中..." : "登入" }}
      </button>

      <button
        type="button"
        class="switch-button"
        :disabled="submitting"
        @click="switchAuthMode('register')"
      >
        註冊新帳號
      </button>
    </form>

    <!-- 註冊表單 -->
    <form
      v-else
      class="login-box"
      @submit.prevent="handleRegister"
    >
      <h1>金融商品管理系統</h1>
      <h2>使用者註冊</h2>

      <label for="userid">使用者編號</label>
      <input
        id="userid"
        v-model="registerForm.userid"
        type="text"
        maxlength="20"
        required
      />

      <label for="username">使用者姓名</label>
      <input
        id="username"
        v-model="registerForm.username"
        type="text"
        maxlength="45"
        required
      />

      <label for="registerEmail">Email</label>
      <input
        id="registerEmail"
        v-model="registerForm.email"
        type="email"
        maxlength="45"
        autocomplete="email"
        required
      />

      <label for="registerAccount">扣款帳號</label>
      <input
        id="registerAccount"
        v-model="registerForm.account"
        type="text"
        maxlength="45"
        required
      />

      <label for="registerPassword">密碼</label>
      <input
        id="registerPassword"
        v-model="registerForm.password"
        type="password"
        minlength="8"
        autocomplete="new-password"
        required
      />

      <label for="confirmPassword">確認密碼</label>
      <input
        id="confirmPassword"
        v-model="registerForm.confirmPassword"
        type="password"
        minlength="8"
        autocomplete="new-password"
        required
      />

      <p
        v-if="message"
        :class="messageType === 'success' ? 'success' : 'error'"
      >
        {{ message }}
      </p>

      <button type="submit" :disabled="submitting">
        {{ submitting ? "註冊中..." : "註冊" }}
      </button>

      <button
        type="button"
        class="switch-button"
        :disabled="submitting"
        @click="switchAuthMode('login')"
      >
        返回登入
      </button>
    </form>
  </div>

  <!-- 已登入 -->
  <template v-else>
    <header class="navbar">
      <div class="brand">金融商品管理系統</div>

      <nav>
        <button
          :class="{ active: currentPage === 'likeList' }"
          @click="currentPage = 'likeList'"
        >
          喜好金融商品
        </button>

        <button
          :class="{ active: currentPage === 'products' }"
          @click="currentPage = 'products'"
        >
          商品管理
        </button>
      </nav>

      <div class="user-actions">
        <span>{{ user.username || user.userid }}</span>

        <button
          class="logout-button"
          :disabled="submitting"
          @click="handleLogout"
        >
          {{ submitting ? "登出中..." : "登出" }}
        </button>
      </div>
    </header>

    <p v-if="message" class="error logout-error">
      {{ message }}
    </p>

    <LikeListView v-if="currentPage === 'likeList'" />
    <ProductView v-else />
  </template>
</template>

<style scoped>
.navbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
  padding: 16px 30px;
  background: #1e293b;
  color: white;
  flex-wrap: wrap;
}

.brand {
  font-size: 22px;
  font-weight: bold;
}

nav {
  display: flex;
  gap: 10px;
}

nav button,
.logout-button {
  border: 1px solid #64748b;
  border-radius: 6px;
  background: transparent;
  color: white;
  padding: 10px 16px;
  cursor: pointer;
}

nav button.active {
  background: #2563eb;
  border-color: #2563eb;
}

.user-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.logout-button {
  background: #dc2626;
  border-color: #dc2626;
}

.loading {
  padding: 80px 20px;
  text-align: center;
}

.login-page {
  min-height: 80vh;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 24px;
  box-sizing: border-box;
}

.login-box {
  width: 100%;
  max-width: 400px;
  padding: 32px;
  border-radius: 12px;
  background: white;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  gap: 12px;
  box-sizing: border-box;
}

.login-box h1,
.login-box h2 {
  text-align: center;
  margin: 0 0 12px;
}

.login-box label {
  font-weight: 500;
}

.login-box input {
  padding: 12px;
  border: 1px solid #cbd5e1;
  border-radius: 6px;
  box-sizing: border-box;
  width: 100%;
}

.login-box button {
  padding: 12px;
  background: #2563eb;
  border: none;
  border-radius: 6px;
  color: white;
  cursor: pointer;
}

.switch-button {
  background: #64748b !important;
}

.switch-button:hover {
  background: #475569 !important;
}

button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.error {
  color: #dc2626;
  text-align: center;
}

.success {
  color: #15803d;
  text-align: center;
}

.logout-error {
  margin: 16px;
}
</style>
