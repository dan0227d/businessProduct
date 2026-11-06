import axios from "axios";

const api = axios.create({
    baseURL: "http://localhost:8080/api",
    timeout: 10000
});

// Product API
export const getProducts = () =>
    api.get("/products");

export const addProduct = (product) =>
    api.post("/products", product);

export const updateProduct = (no, product) =>
    api.put(`/products/${no}`, product);

export const deleteProduct = (no) =>
    api.delete(`/products/${no}`);

// LikeList API
export const getLikeList = () =>
    api.get("/like-list");

export const addLikeList = (likeList) =>
    api.post("/like-list", likeList);

export const updateLikeList = (sn, likeList) =>
    api.put(`/like-list/${sn}`, likeList);

export const deleteLikeList = (sn) =>
    api.delete(`/like-list/${sn}`);

export const addLikeListWithProduct = (data) =>
  api.post("/like-list/with-product", data);

// User API
export const getUsers = () =>
    api.get("/users");

export default api;