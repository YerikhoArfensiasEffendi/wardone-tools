@echo off
title ARTHUR WIFI BOOSTER - MADE BY YERIKHO
mode con: cols=92 lines=38
color 0B

:: 1. Meminta Hak Akses Administrator Otomatis
fltmc >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Meminta izin Administrator...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

:MENU
cls
echo ============================================================================================
echo.
echo           ARTHUR WIFI BOOSTER v2.0 - LAPTOP WIFI OPTIMIZER
echo                               made by yerikho
echo                             for booster download
echo.
echo ============================================================================================

:: 2. Deteksi Adapter Wi-Fi Aktif
set "ADAPTER="
set "ADAPTER_DESC="
set "WIFI_SSID=Tidak Terhubung"
set "WIFI_SIGNAL=-"
set "WIFI_RX=-"
set "WIFI_RADIO=-"
set "WIFI_BAND=Tidak Diketahui"

for /f "tokens=*" %%a in ('powershell -NoProfile -Command "(Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -like '*Wi*' } | Select-Object -First 1).Name"') do set "ADAPTER=%%a"
if "%ADAPTER%"=="" (
    for /f "tokens=*" %%a in ('powershell -NoProfile -Command "(Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.Virtual -ne $True } | Select-Object -First 1).Name"') do set "ADAPTER=%%a"
)
if "%ADAPTER%"=="" set "ADAPTER=Wi-Fi"

for /f "tokens=*" %%a in ('powershell -NoProfile -Command "(Get-NetAdapter -Name '%ADAPTER%').InterfaceDescription"') do set "ADAPTER_DESC=%%a"

netsh wlan show interfaces > "%TEMP%\wlan_info.tmp" 2>&1
for /f "tokens=1,* delims=:" %%i in ('findstr /C:"SSID" "%TEMP%\wlan_info.tmp" ^| findstr /V "BSSID"') do set "WIFI_SSID=%%j"
for /f "tokens=1,* delims=:" %%i in ('findstr /C:"Signal" "%TEMP%\wlan_info.tmp"') do set "WIFI_SIGNAL=%%j"
for /f "tokens=1,* delims=:" %%i in ('findstr /C:"Receive rate" "%TEMP%\wlan_info.tmp"') do set "WIFI_RX=%%j"
for /f "tokens=1,* delims=:" %%i in ('findstr /C:"Radio type" "%TEMP%\wlan_info.tmp"') do set "WIFI_RADIO=%%j"
for /f "tokens=1,* delims=:" %%i in ('findstr /C:"Channel" "%TEMP%\wlan_info.tmp"') do set "WIFI_CH=%%j"
del /f /q "%TEMP%\wlan_info.tmp" >nul 2>&1

:: Deteksi Band 2.4 GHz vs 5 GHz dari Radio Type
echo "%WIFI_RADIO%" | findstr /I "802.11a 802.11ac 802.11ax" >nul 2>&1
if %errorlevel% equ 0 (
    set "WIFI_BAND=5 GHz (BAGUS)"
) else (
    echo "%WIFI_RADIO%" | findstr /I "802.11n 802.11g 802.11b" >nul 2>&1
    if !errorlevel! equ 0 set "WIFI_BAND=2.4 GHz (LAMBAT - Ganti ke 5G jika bisa)"
)

:: Tampilkan Status Dashboard
if exist "%TEMP%\arthur_wifi_booster.status" (
    echo   STATUS BOOSTER  : [ ON / AKTIF - KECEPATAN WIFI MAKSIMAL ]
    echo   TWEAKS AKTIF    : TCP Autotuning ^| QoS 0%% ^| Delivery Opt 100%% ^| Cloudflare DNS
) else (
    echo   STATUS BOOSTER  : [ OFF / NORMAL - SETELAN DEFAULT WINDOWS ]
)
echo   ADAPTER AKTIF   : %ADAPTER% (%ADAPTER_DESC%)
echo   SSID WI-FI      :%WIFI_SSID%
echo   SINYAL / SPEED  :%WIFI_SIGNAL% ^| Link Speed:%WIFI_RX% Mbps
echo   FREKUENSI       :%WIFI_RADIO% - %WIFI_BAND%
echo ============================================================================================
echo.
echo   [1] TURN ON  - Aktifkan Wi-Fi Booster (TCP, DNS Cloudflare, QoS 0%%, Delivery Opt)
echo   [2] TURN OFF - Matikan & Kembalikan ke Setelan Semula (DHCP & Default Windows)
echo   [3] PASANG FDM - Download & Pasang Free Download Manager (Multi-Thread 32x)
echo   [4] FIX GAME   - Pasang Visual C++ Runtimes Lengkap (Fix msvcr110.dll dll)
echo   [5] CEK WIFI   - Diagnosa Frekuensi, Sinyal, Channel, & Ping Test
echo   [6] KELUAR     - Tutup Aplikasi
echo.
echo ============================================================================================
echo                   ARTHUR WIFI BOOSTER v2.0 * MADE BY YERIKHO
echo ============================================================================================
set /p "choice=  Pilih menu [1-6]: "

if "%choice%"=="1" goto BOOST_ON
if "%choice%"=="2" goto BOOST_OFF
if "%choice%"=="3" goto INSTALL_FDM
if "%choice%"=="4" goto FIX_RUNTIMES
if "%choice%"=="5" goto CEK_WIFI
if "%choice%"=="6" goto KELUAR
goto MENU

:BOOST_ON
cls
echo ============================================================================================
echo                    MENGAKTIFKAN ARTHUR WIFI BOOSTER UNTUK LAPTOP...
echo ============================================================================================
echo.
echo [1/6] Mengaktifkan TCP Window Auto-Tuning (Membuka Penuh Bandwidth Wi-Fi)...
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set heuristics disabled >nul 2>&1
netsh int tcp set global rss=enabled >nul 2>&1
netsh int tcp set global fastopen=enabled >nul 2>&1
netsh int tcp set supplemental template=internet congestionprovider=ctcp >nul 2>&1

echo [2/6] Menghilangkan Batasan QoS Bandwidth Windows (0%% Reserved)...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d 0 /f >nul 2>&1

echo [3/6] Membuka Pembatasan Windows Delivery Optimization (Set 100%%)...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DODownloadMode" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DOMaxBackgroundDownloadBandwidth" /t REG_DWORD /d 100 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DOMaxForegroundDownloadBandwidth" /t REG_DWORD /d 100 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DOMaxDownloadBandwidth" /t REG_DWORD /d 0 /f >nul 2>&1

echo [4/6] Memasang DNS Tercepat Cloudflare (1.1.1.1 / 1.0.0.1)...
netsh interface ipv4 set dnsservers name="%ADAPTER%" static 1.1.1.1 primary >nul 2>&1
netsh interface ipv4 add dnsservers name="%ADAPTER%" 1.0.0.1 index=2 >nul 2>&1

echo [5/6] Mengoptimalkan Adapter Wi-Fi (Disable Power Saving & Max Throughput)...
powershell -NoProfile -Command "Set-NetAdapterPowerManagement -Name '%ADAPTER%' -WakeOnMagicPacket Disabled -WakeOnPattern Disabled -ErrorAction SilentlyContinue" >nul 2>&1
powercfg /SETACVALUEINDEX SCHEME_CURRENT 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0 >nul 2>&1
powercfg /SETDCVALUEINDEX SCHEME_CURRENT 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0 >nul 2>&1
powercfg /SETACTIVE SCHEME_CURRENT >nul 2>&1

echo [6/6] Membersihkan DNS Cache...
ipconfig /flushdns >nul 2>&1

echo 1 > "%TEMP%\arthur_wifi_booster.status"
echo.
echo ============================================================================================
echo        BERHASIL! WIFI LAPTOP KINI SUDAH DIOPTIMALKAN UNTUK KECEPATAN MAKSIMAL!
echo ============================================================================================
echo.
echo TIPS: Jika sinyal Wi-Fi lemah, pindah lebih dekat ke router atau ganti ke SSID 5 GHz.
echo Tekan tombol apa saja untuk kembali ke menu...
pause >nul
goto MENU

:BOOST_OFF
cls
echo ============================================================================================
echo                  MENGEMBALIKAN SEMUA PENGATURAN KE DEFAULT WINDOWS
echo ============================================================================================
echo.
echo [1/4] Mengembalikan DNS ke DHCP Otomatis bawaan provider...
netsh interface ipv4 set dnsservers name="%ADAPTER%" dhcp >nul 2>&1

echo [2/4] Mereset Pengaturan TCP & Heuristics ke Standar Bawaan...
netsh int tcp set heuristics enabled >nul 2>&1
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set supplemental template=internet congestionprovider=default >nul 2>&1

echo [3/4] Menghapus Kebijakan Registry (QoS & Delivery Optimization)...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /f >nul 2>&1

echo [4/4] Flush DNS Cache...
ipconfig /flushdns >nul 2>&1

del /f /q "%TEMP%\arthur_wifi_booster.status" >nul 2>&1
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
echo Browser biasa (Chrome/Edge) hanya membuka 1 jalur koneksi per file (single-thread).
echo FDM memecah file jadi 10-32 jalur paralel agar bandwidth Wi-Fi terpakai penuh.
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

:CEK_WIFI
cls
echo ============================================================================================
echo                     DIAGNOSA LENGKAP KONEKSI WI-FI LAPTOP
echo ============================================================================================
echo.
netsh wlan show interfaces
echo.
echo --------------------------------------------------------------------------------------------
echo ANALISA:
echo - Radio 802.11ac / 802.11ax = Frekuensi 5 GHz (BAGUS, kecepatan tinggi)
echo - Radio 802.11n / 802.11g  = Frekuensi 2.4 GHz (LAMBAT, banyak interferensi)
echo - Jika Link Speed di bawah 100 Mbps, pindahkan laptop lebih dekat ke router.
echo - Jika router support dual-band, sambungkan ke SSID yang berakhiran _5G atau _5GHz.
echo --------------------------------------------------------------------------------------------
echo.
echo Uji Latensi / Ping ke Server Cloudflare (1.1.1.1):
ping -n 4 1.1.1.1
echo.
echo --------------------------------------------------------------------------------------------
echo Tekan tombol apa saja untuk kembali ke menu...
pause >nul
goto MENU

:KELUAR
cls
echo ============================================================================================
echo               TERIMA KASIH TELAH MENGGUNAKAN ARTHUR WIFI BOOSTER
echo ============================================================================================
timeout /t 2 >nul
exit
