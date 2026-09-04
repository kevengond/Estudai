package com.estudai.repository

import com.estudai.model.StudySession
import com.estudai.model.StudyType
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository
import java.util.Optional

@Repository
interface StudySessionRepository : JpaRepository<StudySession, Long> {
    fun findAllByOrderBySessionDateDesc(): List<StudySession>
    
    fun findFirstByOrderBySessionDateDesc(): Optional<StudySession>

    fun findFirstBySubjectIdOrderBySessionDateDesc(subjectId: Long): Optional<StudySession>

    fun findFirstBySubjectIdAndStudyTypeOrderBySessionDateDesc(subjectId: Long, studyType: StudyType): Optional<StudySession>

    fun findTop10ByOrderBySessionDateDesc(): List<StudySession>

    fun findBySubjectIdOrderBySessionDateDesc(subjectId: Long): List<StudySession>

    @Query("SELECT COUNT(s) FROM StudySession s WHERE s.subject.id = :subjectId")
    fun countBySubjectId(subjectId: Long): Long

    @Query("SELECT COALESCE(SUM(s.durationSeconds), 0) FROM StudySession s WHERE s.subject.id = :subjectId")
    fun sumDurationBySubjectId(subjectId: Long): Long

    @Query("SELECT COALESCE(SUM(s.durationSeconds), 0) FROM StudySession s")
    fun sumTotalDuration(): Long

    @Query("SELECT COALESCE(SUM(s.totalQuestions), 0) FROM StudySession s WHERE s.studyType = 'QUESTIONS'")
    fun sumTotalQuestions(): Int

    @Query("SELECT COALESCE(SUM(s.correctQuestions), 0) FROM StudySession s WHERE s.studyType = 'QUESTIONS'")
    fun sumTotalCorrectQuestions(): Int

    @Query("SELECT COALESCE(SUM(s.pagesReadCount), 0) FROM StudySession s WHERE s.studyType = 'PDF'")
    fun sumTotalPagesRead(): Int
}
