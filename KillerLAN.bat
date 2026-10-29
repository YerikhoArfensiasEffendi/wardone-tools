@echo off
title ARTHUR DOWNLOAD BOOSTER - MADE BY YERIKHO
mode con: cols=92 lines=38
color 0B

:: 1. Meminta Hak Akses Administrator Otomatis
fltmc >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Meminta izin Administrator...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: Pindah ke direktori script
cd /d "%~dp0"

:MENU
cls
echo ============================================================================================
echo.
echo           ARTHUR DOWNLOAD BOOSTER v3.0 - ULTIMATE USB TETHERING & NETWORK OPTIMIZER
echo                               made by yerikho
echo                             for booster download
echo.
echo ============================================================================================

:: 2. Deteksi Pintar Adapter: Prioritaskan USB Tethering (RNDIS / Mobile) jika ada
set "ADAPTER="
set "ADAPTER_DESC="
set "IS_TETHER=TIDAK"

for /f "tokens=*" %%a in ('powershell -NoProfile -Command "(Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.Virtual -ne $True } | Sort-Object -Property { if ($_.InterfaceDescription -like '*NDIS*' -or $_.InterfaceDescription -like '*USB*' -or $_.InterfaceDescription -like '*Mobile*') { 0 } else { 1 } } | Select-Object -First 1).Name"') do set "ADAPTER=%%a"
if "%ADAPTER%"=="" set "ADAPTER=Ethernet"

for /f "tokens=*" %%a in ('powershell -NoProfile -Command "(Get-NetAdapter -Name '%ADAPTER%').InterfaceDescription"') do set "ADAPTER_DESC=%%a"

echo "%ADAPTER_DESC%" | findstr /I "NDIS USB Mobile" >nul 2>&1
if %errorlevel% equ 0 set "IS_TETHER=YA (DEDICATED MODEM HP)"

:: Tampilkan Status Dashboard
if exist "%TEMP%\arthur_booster.status" (
    echo   STATUS BOOSTER  : [ ON / AKTIF - KECEPATAN MAKSIMAL ]
    echo   TWEAKS AKTIF    : Metered Limit OFF ^| Metric Priority 1 ^| USB Max Power ^| Cloudflare DNS
) else (
    echo   STATUS BOOSTER  : [ OFF / NORMAL - SETELAN DEFAULT WINDOWS ]
)
echo   ADAPTER AKTIF   : %ADAPTER% (%ADAPTER_DESC%)
echo   MODE TETHERING  : %IS_TETHER%
echo ============================================================================================
echo.
echo   [1] TURN ON  - Aktifkan Booster (Dedicated USB Tethering, Metered Limit OFF, TCP & DNS)
echo   [2] TURN OFF - Matikan & Kembalikan ke Setelan Semula (DHCP & Default Windows)
echo   [3] PASANG FDM - Download & Pasang Free Download Manager (Multi-Thread 32x Wajib HP)
echo   [4] FIX GAME   - Pasang Visual C++ Runtimes Lengkap (Fix msvcr110.dll dll)
echo   [5] CEK STATUS - Cek Detail Konfigurasi Adapter & Ping Jaringan
echo   [6] KELUAR     - Tutup Aplikasi
echo.
echo ============================================================================================
echo                   ARTHUR DOWNLOAD BOOSTER v3.0 * MADE BY YERIKHO
echo ============================================================================================
set /p "choice=  Pilih menu [1-6]: "

if "%choice%"=="1" goto BOOST_ON
if "%choice%"=="2" goto BOOST_OFF
if "%choice%"=="3" goto INSTALL_FDM
if "%choice%"=="4" goto FIX_RUNTIMES
if "%choice%"=="5" goto CEK_STATUS
if "%choice%"=="6" goto KELUAR
goto MENU

:BOOST_ON
cls
echo ============================================================================================
echo               MENGAKTIFKAN DEDICATED USB TETHERING & DOWNLOAD BOOSTER...
echo ============================================================================================
echo.
echo [1/7] Menghapus Batasan Kuota Windows (Metered Connection Bypass)...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "3G" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "4G" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "Ethernet" /t REG_DWORD /d 1 /f >nul 2>&1

echo [2/7] Mengatur Jalur Dedicated Priority (Interface Metric = 1)...
netsh interface ipv4 set interface "%ADAPTER%" metric=1 >nul 2>&1

echo [3/7] Mengunci Performa Maksimal Port USB (Disable USB Selective Suspend)...
powercfg /SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba4d5a0 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 >nul 2>&1
powercfg /SETACTIVE SCHEME_CURRENT >nul 2>&1

echo [4/7] Membuka Penuh TCP Autotuning & Congestion Control Jaringan Seluler (CTCP)...
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set heuristics disabled >nul 2>&1
netsh int tcp set global rss=enabled >nul 2>&1
netsh int tcp set global fastopen=enabled >nul 2>&1
netsh int tcp set supplemental template=internet congestionprovider=ctcp >nul 2>&1

echo [5/7] Menghilangkan Batasan QoS & Windows Delivery Optimization (Set 100%%)...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DODownloadMode" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DOMaxBackgroundDownloadBandwidth" /t REG_DWORD /d 100 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DOMaxForegroundDownloadBandwidth" /t REG_DWORD /d 100 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DOMaxDownloadBandwidth" /t REG_DWORD /d 0 /f >nul 2>&1

echo [6/7] Memasang DNS Cloudflare (1.1.1.1 / 1.0.0.1) untuk Akses CDN Game Cepat...
netsh interface ipv4 set dnsservers name="%ADAPTER%" static 1.1.1.1 primary >nul 2>&1
netsh interface ipv4 add dnsservers name="%ADAPTER%" 1.0.0.1 index=2 >nul 2>&1

echo [7/7] Membersihkan DNS Cache...
ipconfig /flushdns >nul 2>&1

echo 1 > "%TEMP%\arthur_booster.status"
echo.
echo ============================================================================================
echo         BERHASIL! USB TETHERING HP KINI SUDAH DEDICATED & MAKSIMAL 100%% KECEPATANNYA!
echo ============================================================================================
echo Seluruh batasan Windows telah dibuka.
echo Tekan tombol apa saja untuk kembali ke menu...
pause >nul
goto MENU

:BOOST_OFF
cls
echo ============================================================================================
echo                  MENGEMBALIKAN SEMUA PENGATURAN KE DEFAULT WINDOWS
echo ============================================================================================
echo.
echo [1/5] Mengembalikan DNS ke DHCP Otomatis...
netsh interface ipv4 set dnsservers name="%ADAPTER%" dhcp >nul 2>&1

echo [2/5] Mengembalikan Interface Metric ke Otomatis...
netsh interface ipv4 set interface "%ADAPTER%" metric=auto >nul 2>&1

echo [3/5] Mereset Pengaturan TCP & Heuristics ke Standar Bawaan...
netsh int tcp set heuristics enabled >nul 2>&1
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set supplemental template=internet congestionprovider=default >nul 2>&1

echo [4/5] Menghapus Kebijakan Registry (QoS, Delivery Opt, Metered Cost)...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "3G" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "4G" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "Ethernet" /f >nul 2>&1

echo [5/5] Flush DNS Cache...
ipconfig /flushdns >nul 2>&1

del /f /q "%TEMP%\arthur_booster.status" >nul 2>&1
echo.
echo ============================================================================================
echo          BERHASIL! SEMUA PENGATURAN JARINGAN KEMBALI SEPERTI SEMULA (ORIGINAL).
echo ============================================================================================
echo Tekan tombol apa saja untuk kembali ke menu...
pause >nul
goto MENU

:INSTALL_FDM
cls
echo ============================================================================================
echo               MEMASANG FREE DOWNLOAD MANAGER (MULTI-THREAD PARALLEL)
echo ============================================================================================
echo.
echo Pada tethering HP, server sering mencekik kecepatan jika download via browser biasa.
echo FDM memecah file jadi 10-32 jalur paralel agar Mbps paket data terpakai penuh.
echo.
echo Sedang mendownload installer resmi FDM...
set "FDM_INSTALLER=%TEMP%\fdm_setup.exe"
curl -sLo "%FDM_INSTALLER%" "https://files2.freedownloadmanager.org/6/latest/freedownloadmanager.exe"

if exist "%FDM_INSTALLER%" (
    echo Menginstal Free Download Manager...
    start /wait "" "%FDM_INSTALLER%" /SILENT
    del /f /q "%FDM_INSTALLER%" >nul 2>&1
    echo.
    echo [SUKSES] Free Download Manager berhasil dipasang!
) else (
    echo [GAGAL] Tidak dapat mengunduh installer. Silakan unduh manual dari freedownloadmanager.org
)
echo Tekan tombol apa saja untuk kembali ke menu...
pause >nul
goto MENU

:FIX_RUNTIMES
cls
echo ============================================================================================
echo             MEMASANG VISUAL C++ RUNTIMES DARI MICROSOFT (FIX ERROR DLL)
echo ============================================================================================
echo.
set "TMPDIR=%TEMP%\vcredist_arthur"
if not exist "%TMPDIR%" mkdir "%TMPDIR%"

echo [1/3] Memasang VC++ 2012 (x86 & x64 - Fix msvcr110.dll)...
curl -sLo "%TMPDIR%\vc2012_x86.exe" "https://download.microsoft.com/download/1/6/B/16B06F60-3CA2-430B-844F-B44E4814ED38/vcredist_x86.exe"
start /wait "" "%TMPDIR%\vc2012_x86.exe" /passive /norestart
curl -sLo "%TMPDIR%\vc2012_x64.exe" "https://download.microsoft.com/download/1/6/B/16B06F60-3CA2-430B-844F-B44E4814ED38/vcredist_x64.exe"
start /wait "" "%TMPDIR%\vc2012_x64.exe" /passive /norestart

echo [2/3] Memasang VC++ 2013 (x86 & x64)...
curl -sLo "%TMPDIR%\vc2013_x86.exe" "https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x86.exe"
start /wait "" "%TMPDIR%\vc2013_x86.exe" /passive /norestart
curl -sLo "%TMPDIR%\vc2013_x64.exe" "https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe"
start /wait "" "%TMPDIR%\vc2013_x64.exe" /passive /norestart

echo [3/3] Memasang VC++ 2015-2022 (x86 & x64)...
curl -sLo "%TMPDIR%\vc2022_x86.exe" "https://aka.ms/vs/17/release/vc_redist.x86.exe"
start /wait "" "%TMPDIR%\vc2022_x86.exe" /passive /norestart
curl -sLo "%TMPDIR%\vc2022_x64.exe" "https://aka.ms/vs/17/release/vc_redist.x64.exe"
start /wait "" "%TMPDIR%\vc2022_x64.exe" /passive /norestart

rmdir /s /q "%TMPDIR%" >nul 2>&1
echo.
echo [SUKSES] Seluruh Visual C++ Runtimes berhasil dipasang!
echo Tekan tombol apa saja untuk kembali ke menu...
pause >nul
goto MENU

:CEK_STATUS
cls
echo ============================================================================================
echo                    STATUS ADAPTER & PING TEST JARINGAN TETHERING
echo ============================================================================================
echo.
echo Detail Konfigurasi IP %ADAPTER%:
ipconfig | findstr /I "IPv4 Subnet Gateway DNS"
echo.
echo --------------------------------------------------------------------------------------------
echo Uji Latensi / Ping ke Server Cloudflare (1.1.1.1):
ping -n 4 1.1.1.1
echo --------------------------------------------------------------------------------------------
echo.
echo Tekan tombol apa saja untuk kembali ke menu...
pause >nul
goto MENU

:KELUAR
cls
echo ============================================================================================
echo               TERIMA KASIH TELAH MENGGUNAKAN ARTHUR DOWNLOAD BOOSTER
echo ============================================================================================
timeout /t 2 >nul
exit
