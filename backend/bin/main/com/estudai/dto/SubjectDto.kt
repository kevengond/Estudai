package com.estudai.dto

import jakarta.validation.constraints.NotBlank
import java.time.LocalDateTime

data class SubjectRequest(
    @field:NotBlank(message = "Nome da disciplina é obrigatório")
    val name: String,
    val color: String = "#4F46E5",
    val cycleOrder: Int = 0,
    val active: Boolean = true,
    val targetMinutes: Int = 60,
    val groupId: Long? = null
)

data class SubjectResponse(
    val id: Long,
    val name: String,
    val color: String,
    val cycleOrder: Int,
    val active: Boolean,
    val targetMinutes: Int,
    val groupId: Long?,
    val groupName: String?,
    val totalSessions: Long = 0,
    val totalStudySeconds: Long = 0,
    val lastStudiedAt: LocalDateTime? = null,
    val createdAt: LocalDateTime
)

data class ReorderCycleRequest(
    val subjectIds: List<Long>,
    val groupId: Long? = null
)
