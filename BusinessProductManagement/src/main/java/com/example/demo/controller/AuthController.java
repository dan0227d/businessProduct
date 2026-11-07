package com.example.demo.controller;

import com.example.demo.dto.LoginRequest;
import com.example.demo.dto.RegisterRequest;
import com.example.demo.model.User;
import com.example.demo.service.AuthService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;
import org.springframework.security.web.context.SecurityContextRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;
    private final SecurityContextRepository securityContextRepository;

    public AuthController(
            AuthService authService,
            SecurityContextRepository securityContextRepository) {

        this.authService = authService;
        this.securityContextRepository = securityContextRepository;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(
            @RequestBody LoginRequest request,
            HttpServletRequest httpRequest,
            HttpServletResponse httpResponse) {

        if (request.getEmail() == null ||
            request.getPassword() == null) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "請輸入 Email 與密碼"));
        }

        User user;

        try {
            user = authService.validateLogin(
                    request.getEmail(),
                    request.getPassword()
            );
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(401)
                    .body(Map.of("message", "Email 或密碼錯誤"));
        }
        
        System.out.println("密碼正確");

        httpRequest.getSession(true);
        httpRequest.changeSessionId();

        Authentication authentication =
                new UsernamePasswordAuthenticationToken(
                        user.getUserid(),
                        null,
                        List.of()
                );

        SecurityContext context =
                SecurityContextHolder.createEmptyContext();

        context.setAuthentication(authentication);

        System.out.println("====================");
        
        SecurityContextHolder.setContext(context);

        securityContextRepository.saveContext(
                context,
                httpRequest,
                httpResponse
        );

        return ResponseEntity.ok(Map.of(
                "userid", user.getUserid(),
                "username", user.getUsername(),
                "email", user.getEmail()
        ));
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout(
            HttpServletRequest request,
            HttpServletResponse response,
            Authentication authentication) {

        new SecurityContextLogoutHandler().logout(
                request,
                response,
                authentication
        );

        return ResponseEntity.ok(
                Map.of("message", "登出成功")
        );
    }

    @GetMapping("/me")
    public ResponseEntity<?> me(Authentication authentication) {

        return ResponseEntity.ok(
                Map.of("userid", authentication.getName())
        );
    }
    
    @PostMapping("/register")
    public ResponseEntity<?> register(
            @RequestBody RegisterRequest request) {

        if (request.getUserid() == null ||
            request.getUsername() == null ||
            request.getEmail() == null ||
            request.getPassword() == null ||
            request.getPassword().isBlank() ||
            request.getAccount() == null) {

            return ResponseEntity.badRequest()
                    .body(Map.of("message", "註冊資料不可為空"));
        }

        authService.register(request);

        return ResponseEntity.status(201)
                .body(Map.of("message", "註冊成功"));
    }
}