package com.estudai.controller

import com.estudai.dto.CreateStudySessionRequest
import com.estudai.dto.StudySessionResponse
import com.estudai.service.StudySessionService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/sessions")
@CrossOrigin(origins = ["*"])
class StudySessionController(
    private val studySessionService: StudySessionService
) {

    @GetMapping
    fun getAllSessions(@RequestParam(required = false) subjectId: Long?): List<StudySessionResponse> {
        return if (subjectId != null) {
            studySessionService.getSessionsBySubject(subjectId)
        } else {
            studySessionService.getAllSessions()
        }
    }

    @GetMapping("/recent")
    fun getRecentSessions(@RequestParam(required = false, defaultValue = "10") limit: Int): List<StudySessionResponse> {
        return studySessionService.getRecentSessions(limit)
    }

    @GetMapping("/{id}")
    fun getSessionById(@PathVariable id: Long): StudySessionResponse {
        return studySessionService.getSessionById(id)
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    fun createSession(@Valid @RequestBody request: CreateStudySessionRequest): StudySessionResponse {
        return studySessionService.createSession(request)
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    fun deleteSession(@PathVariable id: Long) {
        studySessionService.deleteSession(id)
    }
}
