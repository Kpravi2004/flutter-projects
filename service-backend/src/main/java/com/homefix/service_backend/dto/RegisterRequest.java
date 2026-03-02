package com.homefix.service_backend.dto;

import jakarta.validation.constraints.*;

public class RegisterRequest {

    @NotBlank(message = "Role is required")
    @Pattern(regexp = "user|worker", flags = Pattern.Flag.CASE_INSENSITIVE,
            message = "Role must be user or worker")
    public String role;

    @NotBlank(message = "Name is required")
    public String name;

    @Email(message = "Invalid email format")
    public String email;

    @Pattern(regexp = "^[0-9]{10}$", message = "Phone must be 10 digits")
    public String phone;

    @NotBlank(message = "Password is required")
    @Size(min = 6, message = "Password must be at least 6 characters")
    public String password;
}

