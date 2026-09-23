package com.estudai.service

import com.estudai.dto.LoginRequest
import com.estudai.dto.RegisterRequest
import com.estudai.model.Role
import com.estudai.model.User
import com.estudai.repository.UserRepository
import com.estudai.security.JwtService
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.ArgumentCaptor
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito.*
import org.mockito.junit.jupiter.MockitoExtension
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.security.crypto.password.PasswordEncoder
import java.util.*

@ExtendWith(MockitoExtension::class)
class AuthServiceTest {

    @Mock
    private lateinit var userRepository: UserRepository

    @Mock
    private lateinit var passwordEncoder: PasswordEncoder

    @Mock
    private lateinit var jwtService: JwtService

    @Mock
    private lateinit var authenticationManager: AuthenticationManager

    @InjectMocks
    private lateinit var authService: AuthService

    private val testUser = User(
        id = 1L,
        name = "Keven Gond",
        username = "keven",
        email = "keven@estudai.com",
        phone = "11988887777",
        passwordHash = "\$2a\$10\$encodedPasswordHashMock",
        role = Role.ROLE_USER
    )

    @BeforeEach
    fun setUp() {
    }

    @Test
    fun `register should encode password and return JWT auth response`() {
        val request = RegisterRequest(
            name = "Keven Gond",
            username = "keven",
            email = "keven@estudai.com",
            phone = "11988887777",
            password = "rawPassword123"
        )

        `when`(userRepository.existsByUsername("keven")).thenReturn(false)
        `when`(userRepository.existsByEmail("keven@estudai.com")).thenReturn(false)
        `when`(passwordEncoder.encode("rawPassword123")).thenReturn("\$2a\$10\$encodedPasswordHashMock")
        `when`(userRepository.save(any(User::class.java))).thenReturn(testUser)
        `when`(jwtService.generateToken(testUser)).thenReturn("mocked.jwt.token")

        val response = authService.register(request)

        assertNotNull(response)
        assertEquals("mocked.jwt.token", response.token)
        assertEquals("Bearer", response.type)
        assertEquals("keven", response.user.username)
        assertEquals("keven@estudai.com", response.user.email)

        // Verify that raw password is NEVER stored directly
        val userCaptor = ArgumentCaptor.forClass(User::class.java)
        verify(userRepository).save(userCaptor.capture())
        val capturedUser = userCaptor.value
        assertEquals("\$2a\$10\$encodedPasswordHashMock", capturedUser.passwordHash)
        assertNotEquals("rawPassword123", capturedUser.passwordHash)
    }

    @Test
    fun `register should throw exception when username already exists`() {
        val request = RegisterRequest(
            name = "Outro Usuario",
            username = "keven",
            email = "outro@estudai.com",
            password = "rawPassword123"
        )

        `when`(userRepository.existsByUsername("keven")).thenReturn(true)

        val ex = assertThrows<IllegalArgumentException> {
            authService.register(request)
        }

        assertTrue(ex.message!!.contains("já está em uso"))
        verify(userRepository, never()).save(any(User::class.java))
    }

    @Test
    fun `login should succeed with valid credentials and return JWT`() {
        val request = LoginRequest(
            login = "keven",
            password = "rawPassword123"
        )

        `when`(userRepository.findByUsernameOrEmail("keven", "keven")).thenReturn(Optional.of(testUser))
        `when`(jwtService.generateToken(testUser)).thenReturn("valid.login.jwt")

        val response = authService.login(request)

        assertNotNull(response)
        assertEquals("valid.login.jwt", response.token)
        assertEquals("keven", response.user.username)
        verify(authenticationManager).authenticate(any())
    }

    @Test
    fun `login should throw BadCredentialsException when user not found`() {
        val request = LoginRequest(
            login = "inexistente",
            password = "password"
        )

        `when`(userRepository.findByUsernameOrEmail("inexistente", "inexistente")).thenReturn(Optional.empty())

        assertThrows<BadCredentialsException> {
            authService.login(request)
        }
    }
}
