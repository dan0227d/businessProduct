package com.example.demo.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.dao.LikeListMapper;
import com.example.demo.dao.ProductMapper;
import com.example.demo.dto.LikeListRequest;
import com.example.demo.dto.LikeListResponse;
import com.example.demo.model.LikeList;
import com.example.demo.model.Product;

@Service
public class LikeListService {

    private final LikeListMapper likeListMapper;
    private final ProductMapper productMapper;

    public LikeListService(
            LikeListMapper likeListMapper,
            ProductMapper productMapper) {

        this.likeListMapper = likeListMapper;
        this.productMapper = productMapper;
    }

    public List<LikeListResponse> findAll() {
        return likeListMapper.findAll();
    }

    @Transactional
    public void insert(LikeList likeList) {
        likeListMapper.insert(likeList);
    }

    @Transactional
    public void update(LikeList likeList) {
        likeListMapper.update(likeList);
    }

    @Transactional
    public void delete(Integer sn) {
        likeListMapper.delete(sn);
    }

    @Transactional
    public void addWithProduct(LikeListRequest request) {

        // 1. 建立商品
        Product product = new Product();

        product.setProductName(request.getProductName());
        product.setPrice(request.getPrice());
        product.setFeeRate(request.getFeeRate());

        // 2. 新增 product
        productMapper.insert(product);

        // 3. 取得新增商品的編號
        Integer no = product.getNo();

        if (no == null) {
            throw new IllegalStateException("無法取得新增商品編號");
        }

        // 4. 建立喜好清單
        LikeList likeList = new LikeList();

        likeList.setAccount(request.getAccount());
        likeList.setNo(no);
        likeList.setPurchaseQuantity(request.getPurchaseQuantity());

        // 5. 新增 like_list
        likeListMapper.insert(likeList);
    }
}