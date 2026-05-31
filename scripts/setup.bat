@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo Flutter Forge - Environment Setup Check
echo ========================================================
echo.

:: Check Git
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [X] Git non trovato. Installazione in corso tramite winget...
    winget install --id Git.Git -e --source winget
    if %errorlevel% neq 0 (
        echo [ERROR] Installazione di Git fallita. Installa manualmente da https://git-scm.com/
        pause
        exit /b 1
    )
    echo [OK] Git installato con successo.
) else (
    echo [OK] Git e' gia' installato.
)

:: Check Java 17
where java >nul 2>nul
if %errorlevel% neq 0 (
    echo [X] Java non trovato. Installazione di OpenJDK 17 in corso tramite winget...
    winget install Microsoft.OpenJDK.17 -e --source winget
    if %errorlevel% neq 0 (
        echo [ERROR] Installazione di Java fallita. Installa manualmente Java 17.
    ) else (
        echo [OK] Java 17 installato con successo.
    )
) else (
    echo [OK] Java trovato.
)

:: Check Android SDK/Studio
if not exist "%LOCALAPPDATA%\Android\Sdk" (
    if "%ANDROID_HOME%"=="" (
        echo [X] Android SDK non trovato.
        echo Per sviluppare app Android, e' necessario installare Android Studio.
        echo Puoi scaricarlo da: https://developer.android.com/studio
    ) else (
        echo [OK] Android SDK trovato in ANDROID_HOME.
    )
) else (
    echo [OK] Android SDK trovato.
)

:: Check Flutter
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [X] Flutter SDK non trovato.
    echo Assicurati che Flutter sia installato e nel PATH.
    echo Vuoi scaricare e installare Flutter adesso? (S/N)
    set /p install_flutter=
    if /i "!install_flutter!"=="S" (
        echo Installazione di Flutter in C:\src\flutter ...
        mkdir C:\src >nul 2>nul
        cd /d C:\src
        git clone https://github.com/flutter/flutter.git -b stable
        echo ATTENZIONE: Aggiungi C:\src\flutter\bin alle variabili d'ambiente PATH.
        echo Dopo aver aggiunto al PATH, riavvia il terminale ed esegui 'flutter doctor'.
    ) else (
        echo Setup interrotto. Installa Flutter da https://flutter.dev/
        pause
        exit /b 1
    )
) else (
    echo [OK] Flutter SDK trovato.
    echo.
    echo Esecuzione di flutter doctor...
    call flutter doctor
)

echo.
echo ========================================================
echo Setup completato! L'ambiente e' pronto per Flutter Forge.
echo ========================================================
pause
