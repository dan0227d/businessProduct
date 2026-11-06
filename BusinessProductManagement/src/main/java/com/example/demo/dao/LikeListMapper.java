package com.example.demo.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.demo.dto.LikeListResponse;
import com.example.demo.model.LikeList;

@Mapper
public interface LikeListMapper {

    void insert(LikeList likeList);

    List<LikeListResponse> findAll();
    
    void delete(@Param("sn") Integer sn);
    
    void update(LikeList likeList);
}