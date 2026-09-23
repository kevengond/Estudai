package com.estudai.controller

import com.estudai.dto.AuthResponse
import com.estudai.dto.LoginRequest
import com.estudai.dto.RegisterRequest
import com.estudai.dto.UserSummaryResponse
import com.estudai.service.AuthService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = ["*"])
class AuthController(
    private val authService: AuthService
) {

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    fun register(@Valid @RequestBody request: RegisterRequest): AuthResponse {
        return authService.register(request)
    }

    @PostMapping("/login")
    fun login(@Valid @RequestBody request: LoginRequest): AuthResponse {
        return authService.login(request)
    }

    @GetMapping("/me")
    fun getCurrentUser(): UserSummaryResponse {
        return authService.getCurrentUser()
    }
}
