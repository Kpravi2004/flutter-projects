package com.homefix.service_backend.controller;

import com.homefix.service_backend.dto.AuthResponse;
import com.homefix.service_backend.dto.LoginRequest;
import com.homefix.service_backend.dto.RegisterRequest;
import com.homefix.service_backend.service.AuthService;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public AuthResponse register(@Valid @RequestBody RegisterRequest request) {
        String msg = authService.register(request);
        return new AuthResponse(true, msg);
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest request) {
        authService.login(request);
        return new AuthResponse(true, "Login successful");
    }
}
