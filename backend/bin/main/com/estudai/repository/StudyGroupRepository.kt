package com.estudai.repository

import com.estudai.model.StudyGroup
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface StudyGroupRepository : JpaRepository<StudyGroup, Long> {
    fun findAllByOrderByCreatedAtAsc(): List<StudyGroup>
    fun findAllByActiveTrueOrderByCreatedAtAsc(): List<StudyGroup>
}
