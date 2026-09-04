package com.estudai.controller

import com.estudai.dto.DashboardStatsResponse
import com.estudai.service.DashboardService
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/dashboard")
@CrossOrigin(origins = ["*"])
class DashboardController(
    private val dashboardService: DashboardService
) {

    @GetMapping("/stats")
    fun getDashboardStats(@RequestParam(required = false) groupId: Long?): DashboardStatsResponse {
        return dashboardService.getDashboardStats(groupId)
    }
}
