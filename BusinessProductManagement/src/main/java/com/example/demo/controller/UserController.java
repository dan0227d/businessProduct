package com.example.demo.controller;

import java.util.List;

import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import com.example.demo.model.User;
import com.example.demo.service.UserService;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public List<User> findAll() {
        return userService.findAll();
    }
    
//    @GetMapping("/{userid}/accounts")
//    public List<String> findAccountsByUserid(
//            @PathVariable String userid) {
//
//        return userService.findAccountsByUserid(userid);
//    }
    
    @GetMapping("/accounts")
    public List<String> getMyAccounts(
            Authentication authentication) {

        String userid = authentication.getName();

        return userService.findAccountsByUserid(userid);
    }
}