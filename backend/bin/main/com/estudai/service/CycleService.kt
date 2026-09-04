package com.estudai.service

import com.estudai.dto.NextStudySuggestionResponse
import com.estudai.model.StudyType
import com.estudai.repository.StudySessionRepository
import com.estudai.repository.SubjectRepository
import org.springframework.stereotype.Service

@Service
class CycleService(
    private val subjectRepository: SubjectRepository,
    private val studySessionRepository: StudySessionRepository,
    private val subjectService: SubjectService,
    private val studySessionService: StudySessionService
) {

    fun getNextStudySuggestion(groupId: Long? = null): NextStudySuggestionResponse {
        val activeSubjects = if (groupId != null) {
            subjectRepository.findAllByGroupIdAndActiveTrueOrderByCycleOrderAsc(groupId)
        } else {
            subjectRepository.findAllByActiveTrueOrderByCycleOrderAsc()
        }

        if (activeSubjects.isEmpty()) {
            return NextStudySuggestionResponse(
                suggestedSubject = null,
                lastSession = null,
                suggestionType = null,
                resumeMessage = "Cadastre disciplinas ativas no ciclo para iniciar os estudos!",
                checkpointDetail = "Nenhuma matéria ativa encontrada para este ciclo.",
                cycleStatus = "Ciclo Vazio",
                isResumeLastContent = false,
                suggestedMaterialOrTopic = null,
                suggestedPage = null,
                suggestedQuestionsBatch = null
            )
        }

        val allSessions = studySessionRepository.findAllByOrderBySessionDateDesc()
        val lastSessionOpt = if (groupId != null) {
            allSessions.firstOrNull { it.subject.group?.id == groupId }
        } else {
            allSessions.firstOrNull()
        }

        if (lastSessionOpt == null) {
            val firstSubject = activeSubjects.first()
            return NextStudySuggestionResponse(
                suggestedSubject = subjectService.toResponse(firstSubject),
                lastSession = null,
                suggestionType = StudyType.QUESTIONS,
                resumeMessage = "Iniciar ciclo com ${firstSubject.name}",
                checkpointDetail = "Primeira sessão deste ciclo de estudos.",
                cycleStatus = "1 de ${activeSubjects.size} no Ciclo",
                isResumeLastContent = false,
                suggestedMaterialOrTopic = "Introdução / Bloco Inicial",
                suggestedPage = null,
                suggestedQuestionsBatch = 20
            )
        }

        val lastSession = lastSessionOpt
        val lastSubject = lastSession.subject

        val (resumeMessage, checkpointDetail, suggestedPage, suggestedMaterial) = when (lastSession.studyType) {
            StudyType.PDF -> {
                val page = lastSession.pageStopped ?: 1
                val mat = lastSession.materialTitle ?: lastSession.topic ?: "Material PDF"
                Tuple4(
                    "Continuar leitura: $mat (Página $page)",
                    "Você parou na página $page de '$mat'.",
                    page,
                    mat
                )
            }
            StudyType.QUESTIONS -> {
                val topic = lastSession.topic ?: "Questões Gerais"
                val count = lastSession.totalQuestions ?: 0
                val correct = lastSession.correctQuestions ?: 0
                Tuple4(
                    "Continuar questões: ${lastSubject.name} ($topic)",
                    "Último treino: $correct acertos em $count questões ($topic).",
                    null,
                    topic
                )
            }
        }

        val currentIndex = activeSubjects.indexOfFirst { it.id == lastSubject.id }
        val cycleStatus = if (currentIndex >= 0) {
            "${currentIndex + 1} de ${activeSubjects.size} no Ciclo (${lastSubject.name})"
        } else {
            "Ciclo com ${activeSubjects.size} disciplinas ativas"
        }

        return NextStudySuggestionResponse(
            suggestedSubject = subjectService.toResponse(lastSubject),
            lastSession = studySessionService.toResponse(lastSession),
            suggestionType = lastSession.studyType,
            resumeMessage = resumeMessage,
            checkpointDetail = checkpointDetail,
            cycleStatus = cycleStatus,
            isResumeLastContent = true,
            suggestedMaterialOrTopic = suggestedMaterial,
            suggestedPage = suggestedPage,
            suggestedQuestionsBatch = if (lastSession.studyType == StudyType.QUESTIONS) 20 else null
        )
    }

    private data class Tuple4<A, B, C, D>(val a: A, val b: B, val c: C, val d: D)
}
