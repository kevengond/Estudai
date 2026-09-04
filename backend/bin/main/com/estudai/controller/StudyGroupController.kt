package com.estudai.controller

import com.estudai.dto.StudyGroupRequest
import com.estudai.dto.StudyGroupResponse
import com.estudai.service.StudyGroupService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/groups")
@CrossOrigin(origins = ["*"])
class StudyGroupController(
    private val studyGroupService: StudyGroupService
) {

    @GetMapping
    fun getAllGroups(@RequestParam(required = false, defaultValue = "false") activeOnly: Boolean): List<StudyGroupResponse> {
        return studyGroupService.getAllGroups(activeOnly)
    }

    @GetMapping("/{id}")
    fun getGroupById(@PathVariable id: Long): StudyGroupResponse {
        return studyGroupService.getGroupById(id)
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    fun createGroup(@Valid @RequestBody request: StudyGroupRequest): StudyGroupResponse {
        return studyGroupService.createGroup(request)
    }

    @PutMapping("/{id}")
    fun updateGroup(@PathVariable id: Long, @Valid @RequestBody request: StudyGroupRequest): StudyGroupResponse {
        return studyGroupService.updateGroup(id, request)
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    fun deleteGroup(@PathVariable id: Long) {
        studyGroupService.deleteGroup(id)
    }
}
