package com.example.demo.dao;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.demo.model.User;

@Mapper
public interface UserMapper {

    List<User> findAll();
    
    List<String> findAccountsByUserid(
            @Param("userid") String userid);
    
    User findByEmail(@Param("email") String email);
    
    void register(
            @Param("userid") String userid,
            @Param("username") String username,
            @Param("email") String email,
            @Param("password") String password,
            @Param("account") String account
    );
}