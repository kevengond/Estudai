package com.estudai.service

import com.estudai.dto.*
import com.estudai.model.Role
import com.estudai.model.User
import com.estudai.repository.UserRepository
import com.estudai.security.JwtService
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
class AuthService(
    private val userRepository: UserRepository,
    private val passwordEncoder: PasswordEncoder,
    private val jwtService: JwtService,
    private val authenticationManager: AuthenticationManager
) {

    @Transactional
    fun register(request: RegisterRequest): AuthResponse {
        val normalizedUsername = request.username.trim().lowercase()
        val normalizedEmail = request.email.trim().lowercase()

        if (userRepository.existsByUsername(normalizedUsername)) {
            throw IllegalArgumentException("O nome de usuário '$normalizedUsername' já está em uso.")
        }

        if (userRepository.existsByEmail(normalizedEmail)) {
            throw IllegalArgumentException("O e-mail '$normalizedEmail' já está cadastrado no sistema.")
        }

        val newUser = User(
            name = request.name.trim(),
            username = normalizedUsername,
            email = normalizedEmail,
            phone = request.phone?.trim()?.ifBlank { null },
            passwordHash = passwordEncoder.encode(request.password),
            role = Role.ROLE_USER
        )

        val savedUser = userRepository.save(newUser)
        val token = jwtService.generateToken(savedUser)

        return AuthResponse(
            token = token,
            type = "Bearer",
            user = savedUser.toSummary()
        )
    }

    @Transactional(readOnly = true)
    fun login(request: LoginRequest): AuthResponse {
        val loginKey = request.login.trim().lowercase()

        val user = userRepository.findByUsernameOrEmail(loginKey, loginKey)
            .orElseThrow { BadCredentialsException("Usuário ou senha inválidos.") }

        try {
            authenticationManager.authenticate(
                UsernamePasswordAuthenticationToken(user.username, request.password)
            )
        } catch (e: Exception) {
            throw BadCredentialsException("Usuário ou senha inválidos.")
        }

        val token = jwtService.generateToken(user)

        return AuthResponse(
            token = token,
            type = "Bearer",
            user = user.toSummary()
        )
    }

    @Transactional(readOnly = true)
    fun getCurrentUser(): UserSummaryResponse {
        val auth = SecurityContextHolder.getContext().authentication
            ?: throw IllegalStateException("Nenhum usuário autenticado no contexto.")

        val username = auth.name
        val user = userRepository.findByUsername(username)
            .orElseThrow { NoSuchElementException("Usuário não encontrado: $username") }

        return user.toSummary()
    }

    private fun User.toSummary(): UserSummaryResponse {
        return UserSummaryResponse(
            id = this.id,
            name = this.name,
            username = this.username,
            email = this.email,
            phone = this.phone,
            role = this.role.name
        )
    }
}
