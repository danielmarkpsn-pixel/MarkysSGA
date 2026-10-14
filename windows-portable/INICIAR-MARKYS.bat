@echo off
setlocal EnableExtensions
title MARKYS SGA - Inicializacao portatil
cd /d "%~dp0.."

echo.
echo ============================================
echo          MARKYS SGA - Windows LAN
echo ============================================
echo.

if not exist "runtime\frankenphp.exe" (
  echo [ERRO] Runtime FrankenPHP nao encontrado.
  echo O pacote de runtime ainda precisa ser montado em runtime\.
  echo Consulte windows-portable\README.md.
  pause
  exit /b 1
)

if not exist "runtime\postgres\bin\pg_ctl.exe" (
  echo [ERRO] PostgreSQL portatil nao encontrado em runtime\postgres\bin.
  echo O banco nao sera iniciado automaticamente ate o runtime ser preparado.
  pause
  exit /b 1
)

if not exist ".env.local" (
  echo [ERRO] O arquivo .env.local nao foi configurado.
  echo Nao inicie o sistema com segredos de exemplo.
  pause
  exit /b 1
)

echo Os arquivos basicos foram encontrados.
echo A inicializacao completa ainda depende da configuracao validada do banco,
echo das chaves de seguranca e do hub Mercure.
echo Este inicializador nao finge que esses servicos estao prontos.
pause
exit /b 2
