package com.estudai.security

import com.estudai.dto.LoginRequest
import com.estudai.dto.RegisterRequest
import com.fasterxml.jackson.databind.ObjectMapper
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.MediaType
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.get
import org.springframework.test.web.servlet.post

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("h2")
class SecurityIntegrationTest {

    @Autowired
    private lateinit var mockMvc: MockMvc

    @Autowired
    private lateinit var objectMapper: ObjectMapper

    @Test
    fun `unauthenticated request to protected endpoint should return 401 Unauthorized`() {
        mockMvc.get("/api/subjects")
            .andExpect {
                status { isUnauthorized() }
            }
    }

    @Test
    fun `public auth endpoints should allow registration, login and access protected routes with Bearer token`() {
        // 1. Register a new user
        val registerRequest = RegisterRequest(
            name = "Test User",
            username = "testuser",
            email = "testuser@estudai.com",
            phone = "11987654321",
            password = "password123"
        )

        val regResult = mockMvc.post("/api/auth/register") {
            contentType = MediaType.APPLICATION_JSON
            content = objectMapper.writeValueAsString(registerRequest)
        }.andExpect {
            status { isCreated() }
            jsonPath("$.token") { exists() }
            jsonPath("$.user.username") { value("testuser") }
            jsonPath("$.user.email") { value("testuser@estudai.com") }
        }.andReturn()

        // Extract token
        val regJson = objectMapper.readTree(regResult.response.contentAsString)
        val token = regJson.get("token").asText()

        // 2. Access protected endpoint with Bearer token
        mockMvc.get("/api/subjects") {
            header("Authorization", "Bearer $token")
        }.andExpect {
            status { isOk() }
        }

        // 3. Login with credentials
        val loginRequest = LoginRequest(
            login = "testuser",
            password = "password123"
        )

        mockMvc.post("/api/auth/login") {
            contentType = MediaType.APPLICATION_JSON
            content = objectMapper.writeValueAsString(loginRequest)
        }.andExpect {
            status { isOk() }
            jsonPath("$.token") { exists() }
            jsonPath("$.user.username") { value("testuser") }
        }
    }
}
