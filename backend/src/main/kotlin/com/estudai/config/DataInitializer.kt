package com.estudai.config

import com.estudai.dto.CreateStudySessionRequest
import com.estudai.dto.StudyGroupRequest
import com.estudai.dto.SubjectRequest
import com.estudai.model.StudyType
import com.estudai.repository.StudyGroupRepository
import com.estudai.repository.SubjectRepository
import com.estudai.service.StudyGroupService
import com.estudai.service.StudySessionService
import com.estudai.service.SubjectService
import org.springframework.boot.CommandLineRunner
import org.springframework.stereotype.Component
import java.time.LocalDateTime

@Component
class DataInitializer(
    private val studyGroupRepository: StudyGroupRepository,
    private val studyGroupService: StudyGroupService,
    private val subjectRepository: SubjectRepository,
    private val subjectService: SubjectService,
    private val studySessionService: StudySessionService
) : CommandLineRunner {

    override fun run(vararg args: String?) {
        if (studyGroupRepository.count() == 0L && subjectRepository.count() == 0L) {
            // Group 1: Concurso Polícia Federal
            val g1 = studyGroupService.createGroup(
                StudyGroupRequest(
                    name = "Concurso Polícia Federal",
                    description = "Foco em Agente e Escrivão de Polícia Federal",
                    color = "#4F46E5",
                    active = true
                )
            )

            // Group 2: Concurso Área Fiscal / Receita
            val g2 = studyGroupService.createGroup(
                StudyGroupRequest(
                    name = "Concurso Área Fiscal (Receita)",
                    description = "Auditor Fiscal e Analista Tributário",
                    color = "#059669",
                    active = true
                )
            )

            val s1 = subjectService.createSubject(
                SubjectRequest(
                    name = "Direito Constitucional",
                    color = "#4F46E5",
                    cycleOrder = 1,
                    active = true,
                    targetMinutes = 90,
                    groupId = g1.id
                )
            )
            val s2 = subjectService.createSubject(
                SubjectRequest(
                    name = "Direito Administrativo",
                    color = "#0891B2",
                    cycleOrder = 2,
                    active = true,
                    targetMinutes = 90,
                    groupId = g1.id
                )
            )
            val s3 = subjectService.createSubject(
                SubjectRequest(
                    name = "Português",
                    color = "#059669",
                    cycleOrder = 3,
                    active = true,
                    targetMinutes = 60,
                    groupId = g1.id
                )
            )
            val s4 = subjectService.createSubject(
                SubjectRequest(
                    name = "Raciocínio Lógico & Matemática",
                    color = "#D97706",
                    cycleOrder = 4,
                    active = true,
                    targetMinutes = 60,
                    groupId = g1.id
                )
            )
            val s5 = subjectService.createSubject(
                SubjectRequest(
                    name = "Informática & Tecnologia",
                    color = "#DC2626",
                    cycleOrder = 5,
                    active = true,
                    targetMinutes = 60,
                    groupId = g1.id
                )
            )

            subjectService.createSubject(
                SubjectRequest(
                    name = "Direito Tributário",
                    color = "#059669",
                    cycleOrder = 1,
                    active = true,
                    targetMinutes = 90,
                    groupId = g2.id
                )
            )
            subjectService.createSubject(
                SubjectRequest(
                    name = "Contabilidade Geral e Avançada",
                    color = "#D97706",
                    cycleOrder = 2,
                    active = true,
                    targetMinutes = 90,
                    groupId = g2.id
                )
            )
            subjectService.createSubject(
                SubjectRequest(
                    name = "Auditoria",
                    color = "#2563EB",
                    cycleOrder = 3,
                    active = true,
                    targetMinutes = 60,
                    groupId = g2.id
                )
            )

            // Seed initial study sessions for Group 1
            studySessionService.createSession(
                CreateStudySessionRequest(
                    subjectId = s1.id,
                    studyType = StudyType.QUESTIONS,
                    durationSeconds = 3600,
                    topic = "Direitos e Garantias Fundamentais",
                    notes = "Bateria de questões Cebraspe. Foco em remédios constitucionais.",
                    sessionDate = LocalDateTime.now().minusDays(2),
                    totalQuestions = 30,
                    correctQuestions = 26
                )
            )

            studySessionService.createSession(
                CreateStudySessionRequest(
                    subjectId = s2.id,
                    studyType = StudyType.PDF,
                    durationSeconds = 4200,
                    topic = "Atos Administrativos",
                    materialTitle = "Manual de Direito Administrativo - 2026.pdf",
                    pageStopped = 54,
                    pagesReadCount = 28,
                    notes = "Parei no tópico sobre 'Requisitos e Atributos do Ato'.",
                    sessionDate = LocalDateTime.now().minusDays(1)
                )
            )
        }
    }
}
