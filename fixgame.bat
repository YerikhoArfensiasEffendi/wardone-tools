@echo off
title Auto Fix Visual C++ Missing DLL
color 0A

:: Meminta hak akses Administrator otomatis
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Meminta izin Administrator...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo ========================================================
echo   AUTO INSTALLER VISUAL C++ RUNTIMES (OFFICIAL MICROSOFT)
echo ========================================================
echo.
echo Sedang mendownload dan memasang runtime...
echo Harap tunggu sebentar sampai status SELESAI muncul.
echo.

set "TMPDIR=%TEMP%\vcredist_fix"
if not exist "%TMPDIR%" mkdir "%TMPDIR%"

:: 1. VC++ 2012 (Penyebab utama msvcr110.dll hilang)
echo [1/6] Download & Pasang VC++ 2012 (x86)...
curl -sLo "%TMPDIR%\vc2012_x86.exe" "https://download.microsoft.com/download/1/6/B/16B06F60-3CA2-430B-844F-B44E4814ED38/vcredist_x86.exe"
start /wait "" "%TMPDIR%\vc2012_x86.exe" /passive /norestart

echo [2/6] Download & Pasang VC++ 2012 (x64)...
curl -sLo "%TMPDIR%\vc2012_x64.exe" "https://download.microsoft.com/download/1/6/B/16B06F60-3CA2-430B-844F-B44E4814ED38/vcredist_x64.exe"
start /wait "" "%TMPDIR%\vc2012_x64.exe" /passive /norestart

:: 2. VC++ 2013 (Sering dibutuhkan game rip lainnya)
echo [3/6] Download & Pasang VC++ 2013 (x86)...
curl -sLo "%TMPDIR%\vc2013_x86.exe" "https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x86.exe"
start /wait "" "%TMPDIR%\vc2013_x86.exe" /passive /norestart

echo [4/6] Download & Pasang VC++ 2013 (x64)...
curl -sLo "%TMPDIR%\vc2013_x64.exe" "https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe"
start /wait "" "%TMPDIR%\vc2013_x64.exe" /passive /norestart

:: 3. VC++ 2015-2022 (Terbaru - wajib untuk game modern)
echo [5/6] Download & Pasang VC++ 2015-2022 (x86)...
curl -sLo "%TMPDIR%\vc2022_x86.exe" "https://aka.ms/vs/17/release/vc_redist.x86.exe"
start /wait "" "%TMPDIR%\vc2022_x86.exe" /passive /norestart

echo [6/6] Download & Pasang VC++ 2015-2022 (x64)...
curl -sLo "%TMPDIR%\vc2022_x64.exe" "https://aka.ms/vs/17/release/vc_redist.x64.exe"
start /wait "" "%TMPDIR%\vc2022_x64.exe" /passive /norestart

:: Hapus file installer sementara
echo.
echo Membersihkan sisa file instalasi...
rmdir /s /q "%TMPDIR%" >nul 2>&1

echo.
echo ========================================================
echo   SELESAI! SEMUA RUNTIME SUDAH TERPASANG DENGAN AMAN.
echo ========================================================
echo Sekarang kamu sudah bisa langsung buka dan mainkan gamenya!
echo.
pause
exit
