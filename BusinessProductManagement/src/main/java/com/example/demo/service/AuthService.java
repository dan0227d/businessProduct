package com.example.demo.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.example.demo.dao.UserMapper;
import com.example.demo.dto.RegisterRequest;
import com.example.demo.model.User;

@Service
public class AuthService {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;

    public AuthService(
            UserMapper userMapper,
            PasswordEncoder passwordEncoder) {

        this.userMapper = userMapper;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public void register(RegisterRequest request) {

        String passwordHash =
                passwordEncoder.encode(request.getPassword());

        userMapper.register(
                request.getUserid(),
                request.getUsername(),
                request.getEmail(),
                passwordHash,
                request.getAccount()
        );
    }

    public User validateLogin(String email, String password) {

    	//System.out.println(password);
    	
        User user = userMapper.findByEmail(email);
        
        System.out.println(user.getPassword());

        if (user == null ||
            user.getPassword() == null ||
            !passwordEncoder.matches(
                    password, user.getPassword())) {

            throw new IllegalArgumentException(
                    "Email 或密碼錯誤");
        }

        return user;
    }
}