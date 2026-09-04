package com.estudai.service

import com.estudai.dto.StudyGroupRequest
import com.estudai.dto.StudyGroupResponse
import com.estudai.model.StudyGroup
import com.estudai.repository.StudyGroupRepository
import com.estudai.repository.StudySessionRepository
import com.estudai.repository.SubjectRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
class StudyGroupService(
    private val studyGroupRepository: StudyGroupRepository,
    private val subjectRepository: SubjectRepository,
    private val studySessionRepository: StudySessionRepository
) {

    fun getAllGroups(activeOnly: Boolean = false): List<StudyGroupResponse> {
        val groups = if (activeOnly) {
            studyGroupRepository.findAllByActiveTrueOrderByCreatedAtAsc()
        } else {
            studyGroupRepository.findAllByOrderByCreatedAtAsc()
        }
        return groups.map { toResponse(it) }
    }

    fun getGroupById(id: Long): StudyGroupResponse {
        val group = studyGroupRepository.findById(id)
            .orElseThrow { NoSuchElementException("Subgrupo não encontrado com ID: $id") }
        return toResponse(group)
    }

    @Transactional
    fun createGroup(request: StudyGroupRequest): StudyGroupResponse {
        val group = StudyGroup(
            name = request.name.trim(),
            description = request.description?.trim(),
            color = if (request.color.isNotBlank()) request.color else "#6366F1",
            active = request.active
        )
        val saved = studyGroupRepository.save(group)
        return toResponse(saved)
    }

    @Transactional
    fun updateGroup(id: Long, request: StudyGroupRequest): StudyGroupResponse {
        val group = studyGroupRepository.findById(id)
            .orElseThrow { NoSuchElementException("Subgrupo não encontrado com ID: $id") }

        group.name = request.name.trim()
        group.description = request.description?.trim()
        group.color = request.color
        group.active = request.active

        val updated = studyGroupRepository.save(group)
        return toResponse(updated)
    }

    @Transactional
    fun deleteGroup(id: Long) {
        val group = studyGroupRepository.findById(id).orElse(null) ?: return
        
        // 1. Find all subjects belonging to this group
        val subjects = subjectRepository.findAllByGroupIdOrderByCycleOrderAsc(id)
        
        // 2. Cascade delete all study sessions and subjects
        subjects.forEach { subject ->
            val subId = subject.id
            if (subId != null) {
                val sessions = studySessionRepository.findBySubjectIdOrderBySessionDateDesc(subId)
                sessions.forEach { studySessionRepository.delete(it) }
            }
            subjectRepository.delete(subject)
        }
        
        // 3. Delete the group
        studyGroupRepository.delete(group)
    }

    fun toResponse(group: StudyGroup): StudyGroupResponse {
        val id = group.id!!
        val subjectCount = subjectRepository.countByGroupId(id)
        val subjects = subjectRepository.findAllByGroupIdOrderByCycleOrderAsc(id)
        var sessionCount = 0L
        var totalStudySeconds = 0L

        subjects.forEach { s ->
            val subId = s.id
            if (subId != null) {
                sessionCount += studySessionRepository.countBySubjectId(subId)
                totalStudySeconds += studySessionRepository.sumDurationBySubjectId(subId)
            }
        }

        return StudyGroupResponse(
            id = id,
            name = group.name,
            description = group.description,
            color = group.color,
            active = group.active,
            totalSubjects = subjectCount,
            totalSessions = sessionCount,
            totalStudySeconds = totalStudySeconds,
            createdAt = group.createdAt
        )
    }
}
