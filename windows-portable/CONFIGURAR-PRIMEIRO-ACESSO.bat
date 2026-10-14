@echo off
setlocal
cd /d "%~dp0"
if not exist ".env.local" (
  echo Execute INSTALAR-MARKYS.ps1 primeiro.
  pause
  exit /b 1
)
set "PATH=%~dp0runtime\postgres\bin;%PATH%"
echo.
echo Assistente de instalacao inicial do MARKYS SGA
echo Crie o administrador e a unidade. Use dados de teste na primeira validacao.
echo.
runtime\frankenphp.exe php-cli bin/console novosga:install
if errorlevel 1 (
  echo O comando terminou com erro. Copie a mensagem para suporte.
) else (
  echo Instalacao inicial concluida.
)
pause
