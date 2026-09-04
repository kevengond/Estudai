package com.estudai.dto

import jakarta.validation.constraints.NotBlank
import java.time.LocalDateTime

data class StudyGroupRequest(
    @field:NotBlank(message = "Nome do subgrupo é obrigatório")
    val name: String,
    val description: String? = null,
    val color: String = "#6366F1",
    val active: Boolean = true
)

data class StudyGroupResponse(
    val id: Long,
    val name: String,
    val description: String?,
    val color: String,
    val active: Boolean,
    val totalSubjects: Long = 0,
    val totalSessions: Long = 0,
    val totalStudySeconds: Long = 0,
    val createdAt: LocalDateTime
)
