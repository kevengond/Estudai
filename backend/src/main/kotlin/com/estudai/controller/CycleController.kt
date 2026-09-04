package com.estudai.controller

import com.estudai.dto.NextStudySuggestionResponse
import com.estudai.service.CycleService
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/cycle")
@CrossOrigin(origins = ["*"])
class CycleController(
    private val cycleService: CycleService
) {

    @GetMapping("/next-suggestion")
    fun getNextStudySuggestion(@RequestParam(required = false) groupId: Long?): NextStudySuggestionResponse {
        return cycleService.getNextStudySuggestion(groupId)
    }
}
