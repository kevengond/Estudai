package com.estudai.dto

import com.estudai.model.StudyType
import jakarta.validation.constraints.NotNull
import java.time.LocalDateTime

data class CreateStudySessionRequest(
    @field:NotNull(message = "ID da disciplina é obrigatório")
    val subjectId: Long,

    @field:NotNull(message = "Tipo de estudo é obrigatório (QUESTIONS ou PDF)")
    val studyType: StudyType,

    @field:NotNull(message = "Duração em segundos é obrigatória")
    val durationSeconds: Long,

    val topic: String? = null,
    val notes: String? = null,
    val sessionDate: LocalDateTime? = null,

    // Para tipo QUESTIONS
    val totalQuestions: Int? = null,
    val correctQuestions: Int? = null,

    // Para tipo PDF
    val materialTitle: String? = null,
    val pageStopped: Int? = null,
    val pagesReadCount: Int? = null
)

data class StudySessionResponse(
    val id: Long,
    val subjectId: Long,
    val subjectName: String,
    val subjectColor: String,
    val studyType: StudyType,
    val durationSeconds: Long,
    val sessionDate: LocalDateTime,
    val topic: String?,
    val notes: String?,
    val totalQuestions: Int?,
    val correctQuestions: Int?,
    val accuracyRate: Double?,
    val materialTitle: String?,
    val pageStopped: Int?,
    val pagesReadCount: Int?,
    val createdAt: LocalDateTime
)
