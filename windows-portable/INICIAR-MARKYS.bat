@echo off
setlocal
cd /d "%~dp0"
if not exist "INSTALAR-MARKYS.ps1" (
  echo Arquivos do pacote incompletos. Baixe o artefato completo do GitHub Actions.
  pause
  exit /b 1
)
if not exist ".env.local" (
  echo Primeira execucao: preparando a base local...
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0INSTALAR-MARKYS.ps1"
  if errorlevel 1 (
    echo Instalacao nao concluida. Leia a mensagem acima.
    pause
    exit /b 1
  )
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0INICIAR-SERVIDOR.ps1"
pause
