package com.example.demo.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
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

    @GetMapping
    public List<LikeListResponse> findAll() {
        return likeListService.findAll();
    }
    
    @PostMapping
    public ResponseEntity<String> insert(@RequestBody LikeList likeList) {

        likeListService.insert(likeList);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body("商品清單新增成功");
    }
    
    @DeleteMapping("/{sn}")
    public ResponseEntity<Void> delete(@PathVariable Integer sn) {

        likeListService.delete(sn);

        return ResponseEntity.noContent().build();
    }
    
    @PutMapping("/{sn}")
    public ResponseEntity<String> update(
            @PathVariable Integer sn,
            @RequestBody LikeList likeList) {

        likeList.setSn(sn);

        likeListService.update(likeList);

        return ResponseEntity.ok("喜好商品修改成功");
    }
    
    @PostMapping("/with-product")
    public ResponseEntity<String> addWithProduct(
            @RequestBody LikeListRequest request) {

        likeListService.addWithProduct(request);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body("商品及喜好清單新增成功");
    }
}