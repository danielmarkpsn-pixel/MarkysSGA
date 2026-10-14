@echo off
setlocal
cd /d "%~dp0"
title Instalador MARKYS SGA
echo ==========================================
echo       INSTALADOR PORTATIL MARKYS SGA
echo ==========================================
echo.
if not exist "runtime\postgres\bin\initdb.exe" (
  echo ERRO: runtimes nao encontrados nesta pasta.
  echo Extraia o ZIP completo MARKYS-SGA-Windows-Portatil antes de executar.
  echo Nao execute o arquivo de dentro do ZIP.
  pause
  exit /b 1
)
if exist ".env.local" (
  echo O MARKYS ja foi configurado neste computador.
  echo Para iniciar, execute INICIAR-MARKYS.bat.
  pause
  exit /b 0
)
echo Este computador sera o SERVIDOR do MARKYS.
echo A configuracao pode levar alguns minutos.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0INSTALAR-MARKYS.ps1"
if errorlevel 1 (
  echo.
  echo A instalacao encontrou um erro. Copie a mensagem acima.
  pause
  exit /b 1
)
echo.
echo Instalacao base concluida.
echo Agora execute INICIAR-MARKYS.bat para iniciar o servidor.
pause
