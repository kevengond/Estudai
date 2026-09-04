package com.estudai.dto

data class SubjectMetric(
    val subjectId: Long,
    val subjectName: String,
    val subjectColor: String,
    val totalStudySeconds: Long,
    val totalQuestions: Int,
    val totalCorrect: Int,
    val accuracyRate: Double,
    val totalPagesRead: Int,
    val sessionCount: Int
)

data class DashboardStatsResponse(
    val totalStudySeconds: Long,
    val totalSessions: Long,
    val totalQuestions: Int,
    val totalCorrect: Int,
    val overallAccuracyRate: Double,
    val totalPagesRead: Int,
    val subjectMetrics: List<SubjectMetric>,
    val recentSessions: List<StudySessionResponse>
)
