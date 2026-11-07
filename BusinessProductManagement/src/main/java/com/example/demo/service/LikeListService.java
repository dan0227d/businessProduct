package com.example.demo.service;

import java.util.List;

import org.springframework.security.access.AccessDeniedException;
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

    // 查詢登入者自己的喜好清單
    public List<LikeListResponse> findByUserid(String userid) {

        return likeListMapper.findByUserid(userid);
    }

    // 新增喜好清單
    @Transactional
    public void insert(LikeList likeList, String userid) {

        validateAccountOwner(
                userid,
                likeList.getAccount()
        );

        likeListMapper.insert(likeList);
    }

    // 修改喜好清單
    @Transactional
    public void update(LikeList likeList, String userid) {

        // 驗證清單是否屬於登入者
        validateLikeListOwner(
                userid,
                likeList.getSn()
        );

        // 驗證修改後的帳號是否屬於登入者
        validateAccountOwner(
                userid,
                likeList.getAccount()
        );

        likeListMapper.update(likeList);
    }

    // 刪除喜好清單
    @Transactional
    public void delete(Integer sn, String userid) {

        validateLikeListOwner(userid, sn);

        likeListMapper.delete(sn);
    }

    // 新增商品並加入喜好清單
    @Transactional
    public void addWithProduct(
            LikeListRequest request,
            String userid) {

        // 先驗證扣款帳號
        validateAccountOwner(
                userid,
                request.getAccount()
        );

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
        likeList.setPurchaseQuantity(
                request.getPurchaseQuantity()
        );

        // 5. 新增 like_list
        likeListMapper.insert(likeList);
    }

    // 驗證扣款帳號所有權
    public void validateAccountOwner(
            String userid,
            String account) {

        if (likeListMapper.checkAccountOwner(
                userid, account) == 0) {

            throw new AccessDeniedException(
                    "無權使用此扣款帳號"
            );
        }
    }

    // 驗證喜好清單所有權
    public void validateLikeListOwner(
            String userid,
            Integer sn) {

        if (likeListMapper.checkLikeListOwner(
                userid, sn) == 0) {

            throw new AccessDeniedException(
                    "無權操作此喜好清單"
            );
        }
    }
}