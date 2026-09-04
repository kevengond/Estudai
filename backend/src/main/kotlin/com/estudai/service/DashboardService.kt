package com.estudai.service

import com.estudai.dto.DashboardStatsResponse
import com.estudai.dto.SubjectMetric
import com.estudai.model.StudyType
import com.estudai.repository.StudySessionRepository
import com.estudai.repository.SubjectRepository
import org.springframework.stereotype.Service

@Service
class DashboardService(
    private val subjectRepository: SubjectRepository,
    private val studySessionRepository: StudySessionRepository,
    private val studySessionService: StudySessionService
) {

    fun getDashboardStats(groupId: Long? = null): DashboardStatsResponse {
        val allSessions = studySessionRepository.findAllByOrderBySessionDateDesc()
        val filteredSessions = if (groupId != null) {
            allSessions.filter { it.subject.group?.id == groupId }
        } else {
            allSessions
        }

        val totalSeconds = filteredSessions.sumOf { it.durationSeconds }
        val totalSessions = filteredSessions.size.toLong()
        val qSessions = filteredSessions.filter { it.studyType == StudyType.QUESTIONS }
        val totalQuestions = qSessions.sumOf { it.totalQuestions ?: 0 }
        val totalCorrect = qSessions.sumOf { it.correctQuestions ?: 0 }
        val totalPages = filteredSessions.filter { it.studyType == StudyType.PDF }.sumOf { it.pagesReadCount ?: 0 }

        val overallAccuracy = if (totalQuestions > 0) {
            (totalCorrect.toDouble() / totalQuestions.toDouble()) * 100.0
        } else 0.0

        val subjects = if (groupId != null) {
            subjectRepository.findAllByGroupIdOrderByCycleOrderAsc(groupId)
        } else {
            subjectRepository.findAllByOrderByCycleOrderAsc()
        }

        val subjectMetrics = subjects.map { sub ->
            val sessionsForSub = filteredSessions.filter { it.subject.id == sub.id }
            val subDuration = sessionsForSub.sumOf { it.durationSeconds }
            val subQSessions = sessionsForSub.filter { it.studyType == StudyType.QUESTIONS }
            val subQuestions = subQSessions.sumOf { it.totalQuestions ?: 0 }
            val subCorrect = subQSessions.sumOf { it.correctQuestions ?: 0 }
            val subAccuracy = if (subQuestions > 0) {
                (subCorrect.toDouble() / subQuestions.toDouble()) * 100.0
            } else 0.0
            val subPages = sessionsForSub.filter { it.studyType == StudyType.PDF }.sumOf { it.pagesReadCount ?: 0 }

            SubjectMetric(
                subjectId = sub.id!!,
                subjectName = sub.name,
                subjectColor = sub.color,
                totalStudySeconds = subDuration,
                totalQuestions = subQuestions,
                totalCorrect = subCorrect,
                accuracyRate = subAccuracy,
                totalPagesRead = subPages,
                sessionCount = sessionsForSub.size
            )
        }

        val recentResponses = filteredSessions.take(10).map { studySessionService.toResponse(it) }

        return DashboardStatsResponse(
            totalStudySeconds = totalSeconds,
            totalSessions = totalSessions,
            totalQuestions = totalQuestions,
            totalCorrect = totalCorrect,
            overallAccuracyRate = overallAccuracy,
            totalPagesRead = totalPages,
            subjectMetrics = subjectMetrics,
            recentSessions = recentResponses
        )
    }
}
