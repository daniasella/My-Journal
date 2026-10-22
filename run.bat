@echo off
chcp 65001 > nul
title My Journal - Flutter Launcher

echo =======================================================
echo          MY JOURNAL - FLUTTER APPLICATION
echo =======================================================
echo.

:: Cek direktori project Flutter
if exist "%~dp0pubspec.yaml" (
    cd /d "%~dp0"
) else if exist "%~dp0My Journal\pubspec.yaml" (
    cd /d "%~dp0My Journal"
) else (
    echo [ERROR] File pubspec.yaml tidak ditemukan!
    echo Pastikan file run.bat berada di folder proyek My Journal.
    pause
    exit /b 1
)

echo Direktori kerja: %CD%
echo.
echo Pilih perangkat untuk menjalankan aplikasi:
echo [1] Google Chrome (Web - Rekomendasi)
echo [2] Microsoft Edge (Web)
echo [3] Windows Desktop
echo [4] Perangkat Otomatis / Terkoneksi (Android/Device)
echo [5] Jalankan Uji Coba (Flutter Analyze ^& Test)
echo [6] Keluar
echo.

set /p choice="Masukkan pilihan [1-6] (Default 1): "

if "%choice%"=="" set choice=1
if "%choice%"=="1" goto run_chrome
if "%choice%"=="2" goto run_edge
if "%choice%"=="3" goto run_windows
if "%choice%"=="4" goto run_auto
if "%choice%"=="5" goto run_test
if "%choice%"=="6" goto end

echo Pilihan tidak valid, menjalankan di Chrome secara default...
goto run_chrome

:run_chrome
echo.
echo Menjalankan My Journal di Google Chrome...
flutter run -d chrome
goto finish

:run_edge
echo.
echo Menjalankan My Journal di Microsoft Edge...
flutter run -d edge
goto finish

:run_windows
echo.
echo Menjalankan My Journal di Windows Desktop...
flutter run -d windows
goto finish

:run_auto
echo.
echo Menjalankan My Journal di perangkat yang tersedia...
flutter run
goto finish

:run_test
echo.
echo Menjalankan flutter analyze...
flutter analyze
echo.
echo Menjalankan flutter test...
flutter test
goto finish

:finish
echo.
echo =======================================================
echo Proses selesai.
pause
exit /b 0

:end
exit /b 0
