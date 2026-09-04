package com.estudai.service

import com.estudai.dto.CreateStudySessionRequest
import com.estudai.dto.StudySessionResponse
import com.estudai.model.StudySession
import com.estudai.model.StudyType
import com.estudai.repository.StudySessionRepository
import com.estudai.repository.SubjectRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDateTime

@Service
class StudySessionService(
    private val studySessionRepository: StudySessionRepository,
    private val subjectRepository: SubjectRepository
) {

    fun getAllSessions(): List<StudySessionResponse> {
        return studySessionRepository.findAllByOrderBySessionDateDesc().map { toResponse(it) }
    }

    fun getRecentSessions(limit: Int = 10): List<StudySessionResponse> {
        return studySessionRepository.findTop10ByOrderBySessionDateDesc().map { toResponse(it) }
    }

    fun getSessionsBySubject(subjectId: Long): List<StudySessionResponse> {
        return studySessionRepository.findBySubjectIdOrderBySessionDateDesc(subjectId).map { toResponse(it) }
    }

    fun getSessionById(id: Long): StudySessionResponse {
        val session = studySessionRepository.findById(id)
            .orElseThrow { NoSuchElementException("Sessão não encontrada com ID: $id") }
        return toResponse(session)
    }

    @Transactional
    fun createSession(request: CreateStudySessionRequest): StudySessionResponse {
        val subject = subjectRepository.findById(request.subjectId)
            .orElseThrow { NoSuchElementException("Disciplina não encontrada com ID: ${request.subjectId}") }

        val calculatedAccuracy = if (request.studyType == StudyType.QUESTIONS && (request.totalQuestions ?: 0) > 0) {
            val correct = request.correctQuestions ?: 0
            (correct.toDouble() / request.totalQuestions!!.toDouble()) * 100.0
        } else null

        val session = StudySession(
            subject = subject,
            studyType = request.studyType,
            durationSeconds = request.durationSeconds,
            sessionDate = request.sessionDate ?: LocalDateTime.now(),
            topic = request.topic?.trim(),
            notes = request.notes?.trim(),
            totalQuestions = if (request.studyType == StudyType.QUESTIONS) request.totalQuestions else null,
            correctQuestions = if (request.studyType == StudyType.QUESTIONS) request.correctQuestions else null,
            accuracyRate = calculatedAccuracy,
            materialTitle = if (request.studyType == StudyType.PDF) request.materialTitle?.trim() else null,
            pageStopped = if (request.studyType == StudyType.PDF) request.pageStopped else null,
            pagesReadCount = if (request.studyType == StudyType.PDF) request.pagesReadCount else null
        )

        val saved = studySessionRepository.save(session)
        return toResponse(saved)
    }

    @Transactional
    fun deleteSession(id: Long) {
        val session = studySessionRepository.findById(id).orElse(null)
        if (session != null) {
            studySessionRepository.delete(session)
        }
    }

    fun toResponse(session: StudySession): StudySessionResponse {
        return StudySessionResponse(
            id = session.id!!,
            subjectId = session.subject.id!!,
            subjectName = session.subject.name,
            subjectColor = session.subject.color,
            studyType = session.studyType,
            durationSeconds = session.durationSeconds,
            sessionDate = session.sessionDate,
            topic = session.topic,
            notes = session.notes,
            totalQuestions = session.totalQuestions,
            correctQuestions = session.correctQuestions,
            accuracyRate = session.accuracyRate,
            materialTitle = session.materialTitle,
            pageStopped = session.pageStopped,
            pagesReadCount = session.pagesReadCount,
            createdAt = session.createdAt
        )
    }
}
