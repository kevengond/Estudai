package com.estudai.dto

import com.estudai.model.StudyType

data class NextStudySuggestionResponse(
    val suggestedSubject: SubjectResponse?,
    val lastSession: StudySessionResponse?,
    val suggestionType: StudyType?,
    val resumeMessage: String,
    val checkpointDetail: String,
    val cycleStatus: String,
    val isResumeLastContent: Boolean,
    val suggestedMaterialOrTopic: String?,
    val suggestedPage: Int?,
    val suggestedQuestionsBatch: Int?
)
