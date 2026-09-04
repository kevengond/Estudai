package com.estudai

import io.github.cdimascio.dotenv.Dotenv
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import java.io.File

@SpringBootApplication
class EstudaiApplication

fun main(args: Array<String>) {
    // Load .env if present in current or parent directory
    try {
        val dotenv = Dotenv.configure()
            .ignoreIfMissing()
            .load()
        dotenv.entries().forEach { entry ->
            System.setProperty(entry.key, entry.value)
        }
    } catch (_: Exception) {
        // Dotenv optional fallback
    }

    runApplication<EstudaiApplication>(*args)
}
