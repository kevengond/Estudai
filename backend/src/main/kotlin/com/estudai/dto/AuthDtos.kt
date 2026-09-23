package com.estudai.dto

import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size

data class RegisterRequest(
    @field:NotBlank(message = "O nome é obrigatório")
    val name: String,

    @field:NotBlank(message = "O nome de usuário é obrigatório")
    @field:Size(min = 3, max = 50, message = "O usuário deve ter entre 3 e 50 caracteres")
    val username: String,

    @field:NotBlank(message = "O e-mail é obrigatório")
    @field:Email(message = "Formato de e-mail inválido")
    val email: String,

    val phone: String? = null,

    @field:NotBlank(message = "A senha é obrigatória")
    @field:Size(min = 6, message = "A senha deve ter no mínimo 6 caracteres")
    val password: String
)

data class LoginRequest(
    @field:NotBlank(message = "Informe seu usuário ou e-mail")
    val login: String,

    @field:NotBlank(message = "A senha é obrigatória")
    val password: String
)

data class UserSummaryResponse(
    val id: Long?,
    val name: String,
    val username: String,
    val email: String,
    val phone: String?,
    val role: String
)

data class AuthResponse(
    val token: String,
    val type: String = "Bearer",
    val user: UserSummaryResponse
)
