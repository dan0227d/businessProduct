package com.example.demo.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.dao.ProductMapper;
import com.example.demo.model.Product;

@Service
public class ProductService {

    private final ProductMapper productMapper;

    public ProductService(ProductMapper productMapper) {
        this.productMapper = productMapper;
    }

    public List<Product> findAll() {
        return productMapper.findAll();
    }
    
    @Transactional
    public void insert(Product product) {
        productMapper.insert(product);
    }
    
    @Transactional
    public void update(Product product) {
        productMapper.update(product);
    }
    
    @Transactional
    public void delete(Integer no) {
        productMapper.delete(no);
    }
}