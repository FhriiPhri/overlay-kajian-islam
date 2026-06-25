@echo off
title Server Lower Third Kajian OBS
echo =========================================================
echo  MENJALANKAN SERVER LOWER THIRD KAJIAN ISLAMI UNTUK OBS
echo =========================================================
echo.
echo Server ini digunakan untuk menyinkronkan data antara
echo Control Panel dan OBS Studio secara real-time.
echo.
echo PASTIKAN SERVER INI TETAP TERBUKA SELAMA LIVE STREAMING!
echo.
echo Sedang memulai server di port 8000...
echo.

cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "server.ps1"

echo.
echo Server telah berhenti.
pause