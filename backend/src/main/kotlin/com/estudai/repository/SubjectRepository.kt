package com.estudai.repository

import com.estudai.model.Subject
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository

@Repository
interface SubjectRepository : JpaRepository<Subject, Long> {
    fun findAllByOrderByCycleOrderAsc(): List<Subject>
    fun findAllByActiveTrueOrderByCycleOrderAsc(): List<Subject>

    fun findAllByGroupIdOrderByCycleOrderAsc(groupId: Long): List<Subject>
    fun findAllByGroupIdAndActiveTrueOrderByCycleOrderAsc(groupId: Long): List<Subject>
    
    @Query("SELECT MAX(s.cycleOrder) FROM Subject s WHERE (:groupId IS NULL AND s.group IS NULL) OR (s.group.id = :groupId)")
    fun findMaxCycleOrderByGroupId(groupId: Long?): Int?

    fun countByGroupId(groupId: Long): Long
}
