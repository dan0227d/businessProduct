package com.example.demo.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.model.Product;
import com.example.demo.service.ProductService;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    @GetMapping
    public List<Product> findAll() {
        return productService.findAll();
    }
    
    @PostMapping
    public ResponseEntity<Product> insert(@RequestBody Product product) {
        productService.insert(product);
        return ResponseEntity.status(201).body(product);
    }
    
    @PutMapping("/{no}")
    public ResponseEntity<String> update(
            @PathVariable Integer no,
            @RequestBody Product product) {

        product.setNo(no);

        productService.update(product);

        return ResponseEntity.ok("商品修改成功");
    }
    
    @DeleteMapping("/{no}")
    public ResponseEntity<Void> delete(@PathVariable Integer no) {

        productService.delete(no);

        return ResponseEntity.noContent().build();
    }
}