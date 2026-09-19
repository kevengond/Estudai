package com.estudai.service

import com.estudai.dto.SubjectResponse
import com.estudai.model.StudySession
import com.estudai.model.StudyType
import com.estudai.model.Subject
import com.estudai.repository.StudySessionRepository
import com.estudai.repository.SubjectRepository
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito.`when`
import org.mockito.junit.jupiter.MockitoExtension
import java.time.LocalDateTime

@ExtendWith(MockitoExtension::class)
class CycleServiceTest {

    @Mock
    private lateinit var subjectRepository: SubjectRepository

    @Mock
    private lateinit var studySessionRepository: StudySessionRepository

    @Mock
    private lateinit var subjectService: SubjectService

    @Mock
    private lateinit var studySessionService: StudySessionService

    @InjectMocks
    private lateinit var cycleService: CycleService

    private lateinit var subA: Subject
    private lateinit var subB: Subject
    private lateinit var subC: Subject

    @BeforeEach
    fun setup() {
        subA = Subject(id = 1L, name = "Português", cycleOrder = 1, active = true)
        subB = Subject(id = 2L, name = "Matemática", cycleOrder = 2, active = true)
        subC = Subject(id = 3L, name = "Direito", cycleOrder = 3, active = true)
    }

    private fun mockSubjectResponse(subject: Subject): SubjectResponse {
        return SubjectResponse(
            id = subject.id!!,
            name = subject.name,
            color = subject.color,
            cycleOrder = subject.cycleOrder,
            active = subject.active,
            targetMinutes = subject.targetMinutes,
            groupId = null,
            groupName = null,
            totalSessions = 1,
            totalStudySeconds = 3600,
            lastStudiedAt = LocalDateTime.now(),
            createdAt = LocalDateTime.now()
        )
    }

    @Test
    fun `deve sugerir proxima materia com base na ordem atualizada apos reordenar o ciclo`() {
        subC.cycleOrder = 2
        subB.cycleOrder = 3
        val activeSubjects = listOf(subA, subC, subB)

        `when`(subjectRepository.findAllByActiveTrueOrderByCycleOrderAsc()).thenReturn(activeSubjects)
        `when`(subjectService.toResponse(subC)).thenReturn(mockSubjectResponse(subC))

        val sessionA = StudySession(
            id = 100L,
            subject = subA,
            studyType = StudyType.QUESTIONS,
            topic = "Sintaxe",
            sessionDate = LocalDateTime.now()
        )
        `when`(studySessionRepository.findAllByOrderBySessionDateDesc()).thenReturn(listOf(sessionA))

        val suggestion = cycleService.getNextStudySuggestion(groupId = null)

        assertNotNull(suggestion.suggestedSubject)
        assertEquals(subC.id, suggestion.suggestedSubject?.id)
        assertTrue(suggestion.resumeMessage.contains("Direito"))
        assertTrue(suggestion.resumeMessage.contains("Português"))
    }

    @Test
    fun `deve ancorar na ultima materia ativa do ciclo quando a ultima estudada foi removida do ciclo`() {
        subB.active = false
        val activeSubjects = listOf(subA, subC)

        `when`(subjectRepository.findAllByActiveTrueOrderByCycleOrderAsc()).thenReturn(activeSubjects)
        `when`(subjectService.toResponse(subC)).thenReturn(mockSubjectResponse(subC))

        val sessionB = StudySession(
            id = 101L,
            subject = subB,
            studyType = StudyType.PDF,
            sessionDate = LocalDateTime.now()
        )
        val sessionA = StudySession(
            id = 100L,
            subject = subA,
            studyType = StudyType.QUESTIONS,
            sessionDate = LocalDateTime.now().minusHours(1)
        )
        `when`(studySessionRepository.findAllByOrderBySessionDateDesc()).thenReturn(listOf(sessionB, sessionA))

        val suggestion = cycleService.getNextStudySuggestion(groupId = null)

        assertNotNull(suggestion.suggestedSubject)
        assertEquals(subC.id, suggestion.suggestedSubject?.id)
        assertTrue(suggestion.resumeMessage.contains("Direito"))
        assertTrue(suggestion.resumeMessage.contains("após Português"))
    }

    @Test
    fun `deve sugerir a primeira materia quando nenhuma das ativas foi estudada ainda`() {
        val activeSubjects = listOf(subC, subA)

        `when`(subjectRepository.findAllByActiveTrueOrderByCycleOrderAsc()).thenReturn(activeSubjects)
        `when`(subjectService.toResponse(subC)).thenReturn(mockSubjectResponse(subC))
        `when`(studySessionRepository.findAllByOrderBySessionDateDesc()).thenReturn(emptyList())

        val suggestion = cycleService.getNextStudySuggestion(groupId = null)

        assertNotNull(suggestion.suggestedSubject)
        assertEquals(subC.id, suggestion.suggestedSubject?.id)
        assertEquals("1 de 2 no Ciclo (Direito)", suggestion.cycleStatus)
        assertTrue(suggestion.resumeMessage.contains("Iniciar ciclo com Direito"))
    }
}
