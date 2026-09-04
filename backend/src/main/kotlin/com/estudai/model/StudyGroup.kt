package com.estudai.model

import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "study_groups")
data class StudyGroup(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null,

    @Column(nullable = false)
    var name: String = "",

    @Column(length = 500)
    var description: String? = null,

    @Column(nullable = false)
    var color: String = "#6366F1",

    @Column(nullable = false)
    var active: Boolean = true,

    @Column(name = "created_at", nullable = false)
    var createdAt: LocalDateTime = LocalDateTime.now()
)
