package com.estudai.controller

import com.estudai.dto.ReorderCycleRequest
import com.estudai.dto.SubjectRequest
import com.estudai.dto.SubjectResponse
import com.estudai.service.SubjectService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/subjects")
@CrossOrigin(origins = ["*"])
class SubjectController(
    private val subjectService: SubjectService
) {

    @GetMapping
    fun getAllSubjects(
        @RequestParam(required = false) groupId: Long?,
        @RequestParam(required = false, defaultValue = "false") activeOnly: Boolean
    ): List<SubjectResponse> {
        return subjectService.getAllSubjects(groupId = groupId, activeOnly = activeOnly)
    }

    @GetMapping("/{id}")
    fun getSubjectById(@PathVariable id: Long): SubjectResponse {
        return subjectService.getSubjectById(id)
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    fun createSubject(@Valid @RequestBody request: SubjectRequest): SubjectResponse {
        return subjectService.createSubject(request)
    }

    @PutMapping("/{id}")
    fun updateSubject(@PathVariable id: Long, @Valid @RequestBody request: SubjectRequest): SubjectResponse {
        return subjectService.updateSubject(id, request)
    }

    @PatchMapping("/{id}/toggle-cycle")
    fun toggleActiveInCycle(@PathVariable id: Long): SubjectResponse {
        return subjectService.toggleActiveInCycle(id)
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    fun deleteSubject(@PathVariable id: Long) {
        subjectService.deleteSubject(id)
    }

    @PostMapping("/reorder")
    fun reorderCycle(@RequestBody request: ReorderCycleRequest): List<SubjectResponse> {
        return subjectService.reorderCycle(request)
    }
}
