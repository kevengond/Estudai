package com.estudai.model

import jakarta.persistence.*
import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.userdetails.UserDetails
import java.time.LocalDateTime

@Entity
@Table(
    name = "users",
    indexes = [
        Index(name = "idx_users_username", columnList = "username", unique = true),
        Index(name = "idx_users_email", columnList = "email", unique = true)
    ]
)
data class User(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null,

    @Column(name = "name", nullable = false)
    var name: String = "",

    @Column(name = "username", nullable = false, unique = true, length = 60)
    @get:JvmName("userUsername")
    var username: String = "",

    @Column(name = "email", nullable = false, unique = true, length = 120)
    var email: String = "",

    @Column(name = "phone", nullable = true, length = 30)
    var phone: String? = null,

    @Column(name = "password", nullable = false)
    var passwordHash: String = "",

    @Enumerated(EnumType.STRING)
    @Column(name = "role", nullable = false)
    var role: Role = Role.ROLE_USER,

    @Column(name = "created_at", nullable = false)
    var createdAt: LocalDateTime = LocalDateTime.now()
) : UserDetails {

    override fun getAuthorities(): Collection<GrantedAuthority> {
        return listOf(SimpleGrantedAuthority(role.name))
    }

    override fun getPassword(): String {
        return passwordHash
    }

    override fun getUsername(): String {
        return username
    }

    override fun isAccountNonExpired(): Boolean = true

    override fun isAccountNonLocked(): Boolean = true

    override fun isCredentialsNonExpired(): Boolean = true

    override fun isEnabled(): Boolean = true
}
