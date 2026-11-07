package com.example.demo.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import com.example.demo.dto.LikeListRequest;
import com.example.demo.dto.LikeListResponse;
import com.example.demo.model.LikeList;
import com.example.demo.service.LikeListService;

@RestController
@RequestMapping("/api/like-list")
public class LikeListController {

    private final LikeListService likeListService;

    public LikeListController(LikeListService likeListService) {
        this.likeListService = likeListService;
    }

    // 查詢登入者自己的喜好清單
    @GetMapping
    public List<LikeListResponse> findAll(
            Authentication authentication) {

        String userid = authentication.getName();

        return likeListService.findByUserid(userid);
    }

    // 新增喜好清單
    @PostMapping
    public ResponseEntity<String> insert(
            @RequestBody LikeList likeList,
            Authentication authentication) {

        String userid = authentication.getName();

        likeListService.insert(likeList, userid);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body("商品清單新增成功");
    }

    // 刪除喜好清單
    @DeleteMapping("/{sn}")
    public ResponseEntity<Void> delete(
            @PathVariable Integer sn,
            Authentication authentication) {

        String userid = authentication.getName();

        likeListService.delete(sn, userid);

        return ResponseEntity.noContent().build();
    }

    // 修改喜好清單
    @PutMapping("/{sn}")
    public ResponseEntity<String> update(
            @PathVariable Integer sn,
            @RequestBody LikeList likeList,
            Authentication authentication) {

        String userid = authentication.getName();

        likeList.setSn(sn);

        likeListService.update(likeList, userid);

        return ResponseEntity.ok("喜好商品修改成功");
    }

    // 新增商品並加入喜好清單
    @PostMapping("/with-product")
    public ResponseEntity<String> addWithProduct(
            @RequestBody LikeListRequest request,
            Authentication authentication) {

        String userid = authentication.getName();

        likeListService.addWithProduct(request, userid);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body("商品及喜好清單新增成功");
    }

    // 查詢登入者自己的喜好清單
    @GetMapping("/my")
    public List<LikeListResponse> getMyLikeList(
            Authentication authentication) {

        String userid = authentication.getName();

        return likeListService.findByUserid(userid);
    }
}