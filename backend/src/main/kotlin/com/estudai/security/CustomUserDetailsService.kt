package com.estudai.security

import com.estudai.repository.UserRepository
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.stereotype.Service

@Service
class CustomUserDetailsService(
    private val userRepository: UserRepository
) : UserDetailsService {

    override fun loadUserByUsername(usernameOrEmail: String): UserDetails {
        return userRepository.findByUsernameOrEmail(usernameOrEmail, usernameOrEmail)
            .orElseThrow {
                UsernameNotFoundException("Usuário não encontrado com o login: $usernameOrEmail")
            }
    }
}
