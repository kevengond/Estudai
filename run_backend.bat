@echo off
echo ==========================================
echo    Iniciando Backend Kotlin (EstudAI)
echo ==========================================
cd /d "%~dp0backend"
call gradlew.bat bootRun
pause
