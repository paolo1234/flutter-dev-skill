@echo off
setlocal enabledelayedexpansion

:: Imposta la directory corrente su quella dello script
cd /d "%~dp0"

echo ========================================================
echo Flutter Forge - Skill Installation
echo ========================================================
echo.

:: Determina le cartelle di destinazione
set "ANTIGRAVITY_DIR=%USERPROFILE%\.gemini\config\skills\flutter-forge"
set "OPENCODE_DIR=%USERPROFILE%\.config\opencode\skills\flutter-forge"

for %%D in ("%ANTIGRAVITY_DIR%" "%OPENCODE_DIR%") do (
    echo Copia della skill in: %%~D
    echo.

    :: Crea la directory se non esiste
    if not exist "%%~D" (
        mkdir "%%~D"
    )

    :: Usa xcopy per copiare file e cartelle
    xcopy /S /E /Y "..\SKILL.md" "%%~D\" >nul
    xcopy /S /E /Y "..\references\*" "%%~D\references\" >nul
    xcopy /S /E /Y "..\templates\*" "%%~D\templates\" >nul
    xcopy /S /E /Y "..\examples\*" "%%~D\examples\" >nul
    xcopy /S /E /Y "..\rules\*" "%%~D\rules\" >nul
    xcopy /S /E /Y "..\phases\*" "%%~D\phases\" >nul
    xcopy /S /E /Y "..\state-formats\*" "%%~D\state-formats\" >nul
    xcopy /S /E /Y "..\commands\*" "%%~D\commands\" >nul
    xcopy /S /E /Y "..\docs\*" "%%~D\docs\" >nul

    if !errorlevel! neq 0 (
        echo [X] Errore durante l'installazione in %%~D.
        pause
        exit /b 1
    )
)

echo.
echo [OK] Skill installata con successo su Antigravity e OpenCode!
echo Riavvia gli IDE o ricarica le skill per usare '/forge'.
echo.
pause

