<script setup>
import { ref } from "vue";
import ProductView from "./views/ProductView.vue";
import LikeListView from "./views/LikeListView.vue";

const currentPage = ref("likeList");
</script>

<template>
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
  </header>

  <LikeListView v-if="currentPage === 'likeList'" />
  <ProductView v-else />
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

nav button {
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
</style>