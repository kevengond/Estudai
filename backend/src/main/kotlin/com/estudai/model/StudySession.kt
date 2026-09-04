package com.estudai.model

import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "study_sessions")
data class StudySession(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null,

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "subject_id", nullable = false)
    var subject: Subject,

    @Enumerated(EnumType.STRING)
    @Column(name = "study_type", nullable = false)
    var studyType: StudyType = StudyType.QUESTIONS,

    @Column(name = "duration_seconds", nullable = false)
    var durationSeconds: Long = 0L,

    @Column(name = "session_date", nullable = false)
    var sessionDate: LocalDateTime = LocalDateTime.now(),

    @Column
    var topic: String? = null,

    @Column(length = 1000)
    var notes: String? = null,

    // Fields for QUESTIONS
    @Column(name = "total_questions")
    var totalQuestions: Int? = null,

    @Column(name = "correct_questions")
    var correctQuestions: Int? = null,

    @Column(name = "accuracy_rate")
    var accuracyRate: Double? = null,

    // Fields for PDF
    @Column(name = "material_title")
    var materialTitle: String? = null,

    @Column(name = "page_stopped")
    var pageStopped: Int? = null,

    @Column(name = "pages_read_count")
    var pagesReadCount: Int? = null,

    @Column(name = "created_at", nullable = false)
    var createdAt: LocalDateTime = LocalDateTime.now()
) {
    @PrePersist
    @PreUpdate
    fun calculateMetrics() {
        if (studyType == StudyType.QUESTIONS && totalQuestions != null && totalQuestions!! > 0) {
            val correct = correctQuestions ?: 0
            accuracyRate = (correct.toDouble() / totalQuestions!!.toDouble()) * 100.0
        }
    }
}
