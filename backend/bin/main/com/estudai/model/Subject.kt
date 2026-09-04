package com.estudai.model

import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "subjects")
data class Subject(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null,

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "group_id", nullable = true)
    var group: StudyGroup? = null,

    @Column(nullable = false)
    var name: String = "",

    @Column(nullable = false)
    var color: String = "#4F46E5",

    @Column(name = "cycle_order", nullable = false)
    var cycleOrder: Int = 0,

    @Column(nullable = false)
    var active: Boolean = true,

    @Column(name = "target_minutes", nullable = false)
    var targetMinutes: Int = 60,

    @Column(name = "created_at", nullable = false)
    var createdAt: LocalDateTime = LocalDateTime.now()
)
