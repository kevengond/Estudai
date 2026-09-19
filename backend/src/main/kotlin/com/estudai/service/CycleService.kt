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

        val activeSubjectIds = activeSubjects.mapNotNull { it.id }.toSet()
        val allSessions = studySessionRepository.findAllByOrderBySessionDateDesc()

        // Âncora da rotação: última sessão de uma matéria que AINDA PERTENCE ao ciclo ativo atual.
        // Se alguma matéria foi removida/desativada do ciclo, a âncora recua para a última que permanece ativa.
        val lastSessionInCycle = allSessions.firstOrNull { session ->
            session.subject.id in activeSubjectIds && (groupId == null || session.subject.group?.id == groupId)
        }

        if (lastSessionInCycle == null) {
            val firstSubject = activeSubjects.first()
            val lastOfFirst = allSessions.firstOrNull { it.subject.id == firstSubject.id }
            val cycleStatus = "1 de ${activeSubjects.size} no Ciclo (${firstSubject.name})"

            if (lastOfFirst == null) {
                return NextStudySuggestionResponse(
                    suggestedSubject = subjectService.toResponse(firstSubject),
                    lastSession = null,
                    suggestionType = StudyType.QUESTIONS,
                    resumeMessage = "Iniciar ciclo com ${firstSubject.name}",
                    checkpointDetail = "Primeira sessão deste ciclo de estudos.",
                    cycleStatus = cycleStatus,
                    isResumeLastContent = false,
                    suggestedMaterialOrTopic = "Introdução / Bloco Inicial",
                    suggestedPage = null,
                    suggestedQuestionsBatch = 20
                )
            } else {
                val (resumeBody, checkpointDetail, suggestedPage, suggestedMaterial) = extractCheckpoint(lastOfFirst, firstSubject.name)
                return NextStudySuggestionResponse(
                    suggestedSubject = subjectService.toResponse(firstSubject),
                    lastSession = studySessionService.toResponse(lastOfFirst),
                    suggestionType = lastOfFirst.studyType,
                    resumeMessage = "Iniciar ciclo com ${firstSubject.name} — $resumeBody",
                    checkpointDetail = checkpointDetail,
                    cycleStatus = cycleStatus,
                    isResumeLastContent = true,
                    suggestedMaterialOrTopic = suggestedMaterial,
                    suggestedPage = suggestedPage,
                    suggestedQuestionsBatch = if (lastOfFirst.studyType == StudyType.QUESTIONS) 20 else null
                )
            }
        }

        // Matéria ativa que servirá de âncora no ciclo
        val lastSubject = lastSessionInCycle.subject

        // Próxima matéria = próxima na ordem atualizada após a última estudada no ciclo ativo (com wrap-around)
        val currentIndex = activeSubjects.indexOfFirst { it.id == lastSubject.id }
        val nextIndex = if (currentIndex >= 0) {
            (currentIndex + 1) % activeSubjects.size
        } else {
            0
        }
        val nextSubject = activeSubjects[nextIndex]

        // Último conteúdo registrado DA PRÓXIMA matéria (checkpoint: página/tópico)
        val lastOfNext = allSessions.firstOrNull { it.subject.id == nextSubject.id }
        val cycleStatus = "${nextIndex + 1} de ${activeSubjects.size} no Ciclo (${nextSubject.name})"

        if (lastOfNext == null) {
            // Próxima matéria nunca estudada: sugerir início
            return NextStudySuggestionResponse(
                suggestedSubject = subjectService.toResponse(nextSubject),
                lastSession = null,
                suggestionType = StudyType.QUESTIONS,
                resumeMessage = if (activeSubjects.size == 1)
                    "Continuar ciclo com ${nextSubject.name}"
                else
                    "Próxima no ciclo: ${nextSubject.name} (após ${lastSubject.name})",
                checkpointDetail = "Nenhum registro anterior em '${nextSubject.name}'. Comece pelo bloco inicial.",
                cycleStatus = cycleStatus,
                isResumeLastContent = false,
                suggestedMaterialOrTopic = "Introdução / Bloco Inicial",
                suggestedPage = null,
                suggestedQuestionsBatch = 20
            )
        }

        val (resumeBody, checkpointDetail, suggestedPage, suggestedMaterial) = extractCheckpoint(lastOfNext, nextSubject.name)

        val resumeMessage = if (nextSubject.id == lastSubject.id) {
            resumeBody
        } else {
            "Próxima no ciclo: ${nextSubject.name} (após ${lastSubject.name}) — $resumeBody"
        }

        return NextStudySuggestionResponse(
            suggestedSubject = subjectService.toResponse(nextSubject),
            lastSession = studySessionService.toResponse(lastOfNext),
            suggestionType = lastOfNext.studyType,
            resumeMessage = resumeMessage,
            checkpointDetail = checkpointDetail,
            cycleStatus = cycleStatus,
            isResumeLastContent = true,
            suggestedMaterialOrTopic = suggestedMaterial,
            suggestedPage = suggestedPage,
            suggestedQuestionsBatch = if (lastOfNext.studyType == StudyType.QUESTIONS) 20 else null
        )
    }

    private fun extractCheckpoint(session: com.estudai.model.StudySession, subjectName: String): Tuple4<String, String, Int?, String?> {
        return when (session.studyType) {
            StudyType.PDF -> {
                val page = session.pageStopped ?: 1
                val mat = session.materialTitle ?: session.topic ?: "Material PDF"
                Tuple4(
                    "Continuar leitura: $mat (Página $page)",
                    "Você parou na página $page de '$mat' em '$subjectName'.",
                    page,
                    mat
                )
            }
            StudyType.QUESTIONS -> {
                val topic = session.topic ?: "Questões Gerais"
                val count = session.totalQuestions ?: 0
                val correct = session.correctQuestions ?: 0
                Tuple4(
                    "Continuar questões: $subjectName ($topic)",
                    "Último treino em '$subjectName': $correct acertos em $count questões ($topic).",
                    null,
                    topic
                )
            }
        }
    }

    private data class Tuple4<A, B, C, D>(val a: A, val b: B, val c: C, val d: D)
}
