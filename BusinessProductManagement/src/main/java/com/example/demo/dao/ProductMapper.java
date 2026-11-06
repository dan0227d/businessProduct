package com.example.demo.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.demo.model.Product;

@Mapper
public interface ProductMapper {

    List<Product> findAll();
    
    void insert(Product product);
    
    void update(Product product);
    
    void delete(@Param("no") Integer no);

}