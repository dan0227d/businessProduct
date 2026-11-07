//package com.example.demo.config;
//
//import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
//
//public class BCryptTest {
//
//    public static void main(String[] args) {
//
//        BCryptPasswordEncoder encoder =
//                new BCryptPasswordEncoder();
//
//        String password = "1234";
//
//        String hash = encoder.encode(password);
//
//        System.out.println(hash);
//
//        System.out.println(
//                encoder.matches(password, hash)
//        );
//    }
//}