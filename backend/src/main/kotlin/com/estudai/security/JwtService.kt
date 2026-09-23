package com.estudai.security

import com.estudai.model.User
import io.jsonwebtoken.Claims
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.security.Keys
import org.springframework.beans.factory.annotation.Value
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.stereotype.Service
import java.nio.charset.StandardCharsets
import java.security.MessageDigest
import java.util.*
import javax.crypto.SecretKey

@Service
class JwtService(
    @Value("\${security.jwt.secret-key}")
    private val secretKeyString: String,

    @Value("\${security.jwt.expiration-time:86400000}")
    private val jwtExpiration: Long
) {

    private val signingKey: SecretKey by lazy {
        val keyBytes = secretKeyString.toByteArray(StandardCharsets.UTF_8)
        // HMAC-SHA256 requires at least 256 bits (32 bytes). If provided key is shorter or raw, hash it with SHA-256.
        val finalBytes = if (keyBytes.size < 32) {
            val sha256 = MessageDigest.getInstance("SHA-256")
            sha256.digest(keyBytes)
        } else {
            keyBytes
        }
        Keys.hmacShaKeyFor(finalBytes)
    }

    fun extractUsername(token: String): String? {
        return extractClaim(token) { it.subject }
    }

    fun <T> extractClaim(token: String, claimsResolver: (Claims) -> T): T {
        val claims = extractAllClaims(token)
        return claimsResolver(claims)
    }

    fun generateToken(user: User, extraClaims: Map<String, Any> = emptyMap()): String {
        val allClaims = HashMap<String, Any>(extraClaims)
        user.id?.let { allClaims["userId"] = it }
        allClaims["email"] = user.email
        allClaims["name"] = user.name
        allClaims["role"] = user.role.name

        val now = Date()
        val expiryDate = Date(now.time + jwtExpiration)

        return Jwts.builder()
            .claims(allClaims)
            .subject(user.username)
            .issuedAt(now)
            .expiration(expiryDate)
            .signWith(signingKey)
            .compact()
    }

    fun isTokenValid(token: String, userDetails: UserDetails): Boolean {
        return try {
            val username = extractUsername(token)
            username != null && username == userDetails.username && !isTokenExpired(token)
        } catch (e: Exception) {
            false
        }
    }

    private fun isTokenExpired(token: String): Boolean {
        return extractExpiration(token).before(Date())
    }

    private fun extractExpiration(token: String): Date {
        return extractClaim(token) { it.expiration }
    }

    private fun extractAllClaims(token: String): Claims {
        return Jwts.parser()
            .verifyWith(signingKey)
            .build()
            .parseSignedClaims(token)
            .payload
    }
}
