@echo off
chcp 65001 > nul
title My Journal - Git Push Launcher

echo =======================================================
echo          MY JOURNAL - GIT PUSH HELPER
echo          Target: https://github.com/daniasella/My-Journal.git
echo =======================================================
echo.

:: Cek direktori project Flutter (target git repo adalah folder My Journal)
if exist "%~dp0pubspec.yaml" (
    cd /d "%~dp0"
) else if exist "%~dp0My Journal\pubspec.yaml" (
    cd /d "%~dp0My Journal"
) else (
    echo [ERROR] Direktori proyek Flutter tidak ditemukan!
    pause
    exit /b 1
)

echo Direktori kerja: %CD%
echo.

:: 1. Cek apakah git terpasang
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Git belum terpasang atau tidak ada di PATH sistem!
    echo Silakan pasang Git terlebih dahulu dari https://git-scm.com/
    pause
    exit /b 1
)

:: 2. Cek apakah repositori git sudah diinisialisasi
if not exist ".git" (
    echo [INFO] Inisialisasi Git repository baru...
    git init -b main
)

:: 3. Konfigurasi remote origin
echo [INFO] Memeriksa remote origin...
git remote get-url origin >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Menambahkan remote origin: https://github.com/daniasella/My-Journal.git
    git remote add origin https://github.com/daniasella/My-Journal.git
) else (
    echo [INFO] Memperbarui remote origin: https://github.com/daniasella/My-Journal.git
    git remote set-url origin https://github.com/daniasella/My-Journal.git
)

:: 4. Masukkan pesan commit
echo.
set default_msg=feat: complete My Journal Flutter application with Neon backend
set /p commit_msg="Masukkan pesan commit (tekan Enter untuk default): "
if not defined commit_msg set commit_msg=%default_msg%

echo.
echo [1/4] Menambahkan semua perubahan (git add .)...
git add .

echo [2/4] Melakukan commit: %commit_msg%...
git commit -m "%commit_msg%"

echo [3/4] Memastikan branch main...
git branch -M main

echo [4/4] Melakukan push ke origin main...
git push -u origin main

if %errorlevel% neq 0 (
    goto handle_error
)

goto success

:handle_error
echo.
echo =======================================================
echo [PERINGATAN] Push ke origin main belum berhasil!
echo Kemungkinan penyebab:
echo 1. Repositori di GitHub sudah memiliki commit/file awal (README/License).
echo 2. Belum login/autentikasi ke GitHub (Personal Access Token / Browser Login).
echo =======================================================
echo.
set /p retry="Coba pull rebase lalu push ulang? [Y/N] (Default Y): "
if not defined retry set retry=Y
if /i "%retry%"=="Y" (
    echo.
    echo Menjalankan git pull origin main --rebase...
    git pull origin main --rebase
    echo Mendorong kembali ke origin main...
    git push -u origin main
)
goto finish

:success
echo.
echo =======================================================
echo [BERHASIL] Seluruh kode berhasil dipush ke GitHub!
echo https://github.com/daniasella/My-Journal.git
echo =======================================================

:finish
pause
exit /b 0
