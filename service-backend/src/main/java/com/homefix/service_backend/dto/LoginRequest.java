package com.homefix.service_backend.dto;

import jakarta.validation.constraints.*;

public class LoginRequest {

    @NotBlank(message = "Role is required")
    @Pattern(regexp = "user|worker", flags = Pattern.Flag.CASE_INSENSITIVE,
            message = "Role must be user or worker")
    public String role;

    @NotBlank(message = "Email or Phone is required")
    public String emailOrPhone;

    @NotBlank(message = "Password is required")
    public String password;
}
