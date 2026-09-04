package com.estudai.service

import com.estudai.dto.ReorderCycleRequest
import com.estudai.dto.SubjectRequest
import com.estudai.dto.SubjectResponse
import com.estudai.model.Subject
import com.estudai.repository.StudyGroupRepository
import com.estudai.repository.StudySessionRepository
import com.estudai.repository.SubjectRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
class SubjectService(
    private val subjectRepository: SubjectRepository,
    private val studyGroupRepository: StudyGroupRepository,
    private val studySessionRepository: StudySessionRepository
) {

    fun getAllSubjects(groupId: Long? = null, activeOnly: Boolean = false): List<SubjectResponse> {
        val subjects = when {
            groupId != null && activeOnly -> subjectRepository.findAllByGroupIdAndActiveTrueOrderByCycleOrderAsc(groupId)
            groupId != null -> subjectRepository.findAllByGroupIdOrderByCycleOrderAsc(groupId)
            activeOnly -> subjectRepository.findAllByActiveTrueOrderByCycleOrderAsc()
            else -> subjectRepository.findAllByOrderByCycleOrderAsc()
        }
        return subjects.map { toResponse(it) }
    }

    fun getSubjectById(id: Long): SubjectResponse {
        val subject = subjectRepository.findById(id)
            .orElseThrow { NoSuchElementException("Disciplina não encontrada com ID: $id") }
        return toResponse(subject)
    }

    @Transactional
    fun createSubject(request: SubjectRequest): SubjectResponse {
        val group = if (request.groupId != null) {
            studyGroupRepository.findById(request.groupId).orElse(null)
        } else null

        val nextOrder = (subjectRepository.findMaxCycleOrderByGroupId(request.groupId) ?: 0) + 1
        val subject = Subject(
            group = group,
            name = request.name.trim(),
            color = if (request.color.isNotBlank()) request.color else "#4F46E5",
            cycleOrder = if (request.cycleOrder > 0) request.cycleOrder else nextOrder,
            active = request.active,
            targetMinutes = if (request.targetMinutes > 0) request.targetMinutes else 60
        )
        val saved = subjectRepository.save(subject)
        return toResponse(saved)
    }

    @Transactional
    fun updateSubject(id: Long, request: SubjectRequest): SubjectResponse {
        val subject = subjectRepository.findById(id)
            .orElseThrow { NoSuchElementException("Disciplina não encontrada com ID: $id") }

        if (request.groupId != null) {
            subject.group = studyGroupRepository.findById(request.groupId).orElse(null)
        }
        subject.name = request.name.trim()
        subject.color = request.color
        subject.active = request.active
        subject.targetMinutes = request.targetMinutes
        if (request.cycleOrder > 0) {
            subject.cycleOrder = request.cycleOrder
        }

        val updated = subjectRepository.save(subject)
        return toResponse(updated)
    }

    @Transactional
    fun toggleActiveInCycle(id: Long): SubjectResponse {
        val subject = subjectRepository.findById(id)
            .orElseThrow { NoSuchElementException("Disciplina não encontrada com ID: $id") }
        subject.active = !subject.active
        val updated = subjectRepository.save(subject)
        return toResponse(updated)
    }

    @Transactional
    fun deleteSubject(id: Long) {
        if (!subjectRepository.existsById(id)) {
            throw NoSuchElementException("Disciplina não encontrada com ID: $id")
        }
        // Delete related sessions
        val sessions = studySessionRepository.findBySubjectIdOrderBySessionDateDesc(id)
        sessions.forEach { studySessionRepository.delete(it) }
        subjectRepository.deleteById(id)
    }

    @Transactional
    fun reorderCycle(request: ReorderCycleRequest): List<SubjectResponse> {
        request.subjectIds.forEachIndexed { index, id ->
            subjectRepository.findById(id).ifPresent {
                it.cycleOrder = index + 1
                subjectRepository.save(it)
            }
        }
        return getAllSubjects(groupId = request.groupId)
    }

    fun toResponse(subject: Subject): SubjectResponse {
        val id = subject.id!!
        val sessionCount = studySessionRepository.countBySubjectId(id)
        val duration = studySessionRepository.sumDurationBySubjectId(id)
        val lastSession = studySessionRepository.findFirstBySubjectIdOrderBySessionDateDesc(id)

        return SubjectResponse(
            id = id,
            name = subject.name,
            color = subject.color,
            cycleOrder = subject.cycleOrder,
            active = subject.active,
            targetMinutes = subject.targetMinutes,
            groupId = subject.group?.id,
            groupName = subject.group?.name,
            totalSessions = sessionCount,
            totalStudySeconds = duration,
            lastStudiedAt = lastSession.map { it.sessionDate }.orElse(null),
            createdAt = subject.createdAt
        )
    }
}
