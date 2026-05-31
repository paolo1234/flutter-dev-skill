@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo Flutter Forge - Skill Installation (Antigravity IDE)
echo ========================================================
echo.

:: Determina la cartella di destinazione
set "SKILL_DIR=%USERPROFILE%\.agents\skills\flutter-forge"

echo Copia della skill in: %SKILL_DIR%
echo.

:: Crea la directory se non esiste
if not exist "%SKILL_DIR%" (
    mkdir "%SKILL_DIR%"
)

:: Usa xcopy per copiare file e cartelle
xcopy /S /E /Y "..\SKILL.md" "%SKILL_DIR%\" >nul
xcopy /S /E /Y "..\references\*" "%SKILL_DIR%\references\" >nul
xcopy /S /E /Y "..\templates\*" "%SKILL_DIR%\templates\" >nul
xcopy /S /E /Y "..\examples\*" "%SKILL_DIR%\examples\" >nul
xcopy /S /E /Y "..\rules\*" "%SKILL_DIR%\rules\" >nul
xcopy /S /E /Y "..\phases\*" "%SKILL_DIR%\phases\" >nul
xcopy /S /E /Y "..\state-formats\*" "%SKILL_DIR%\state-formats\" >nul
xcopy /S /E /Y "..\commands\*" "%SKILL_DIR%\commands\" >nul
xcopy /S /E /Y "..\docs\*" "%SKILL_DIR%\docs\" >nul

if %errorlevel% neq 0 (
    echo [X] Errore durante l'installazione della skill.
    pause
    exit /b 1
)

echo [OK] Skill installata con successo!
echo Riavvia Antigravity o ricarica le skill per usare '/forge'.
echo.
pause
