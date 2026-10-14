# Inicializa PostgreSQL e FrankenPHP. A instalacao inicial do NovoSGA e executada separadamente.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
$pgBin = Join-Path $root 'runtime\postgres\bin'
$pgData = Join-Path $root 'data\postgres'
$pgLog = Join-Path $root 'logs\postgres.log'
$env:APP_ENV = 'prod'
$env:APP_DEBUG = '0'
$env:SERVER_ROOT = (Join-Path $root 'public').Replace('\','/')
$env:SERVER_NAME = ':8080'
$env:FRANKENPHP_CONFIG = ''
$env:MERCURE_PUBLISHER_JWT_KEY = ''
$env:MERCURE_SUBSCRIBER_JWT_KEY = ''
$env:MERCURE_EXTRA_DIRECTIVES = ''
$env:APP_RUNTIME = 'Runtime\FrankenPhpSymfony\Runtime'

if (!(Test-Path '.env.local')) { throw 'Execute INSTALAR-MARKYS.ps1 primeiro.' }
if (!(Test-Path (Join-Path $pgData 'PG_VERSION'))) { throw 'Banco ainda nao inicializado. Execute INSTALAR-MARKYS.ps1.' }

$envText = Get-Content '.env.local' -Raw
if ($envText -notmatch 'MERCURE_JWT_SECRET=(.+)') { throw 'MERCURE_JWT_SECRET ausente em .env.local.' }
$secret = $Matches[1].Trim()
$env:MERCURE_PUBLISHER_JWT_KEY = $secret
$env:MERCURE_SUBSCRIBER_JWT_KEY = $secret

$pgPid = Join-Path $pgData 'postmaster.pid'
if (!(Test-Path $pgPid)) {
  & (Join-Path $pgBin 'pg_ctl.exe') -D $pgData -l $pgLog -o '-h 127.0.0.1 -p 5432' start
  if ($LASTEXITCODE -ne 0) { throw 'PostgreSQL nao iniciou. Consulte logs\postgres.log.' }
}

$env:DATABASE_URL = ([regex]::Match($envText, 'DATABASE_URL="([^"]+)"')).Groups[1].Value
if (!$env:DATABASE_URL) { throw 'DATABASE_URL nao foi lida do .env.local.' }
& (Join-Path $pgBin 'createdb.exe') -h 127.0.0.1 -p 5432 -U markys markys 2>$null
# createdb pode retornar erro se o banco ja existir; a verificacao abaixo decide.
& (Join-Path $pgBin 'psql.exe') -h 127.0.0.1 -p 5432 -U markys -d markys -c 'SELECT 1' 2>$null
if ($LASTEXITCODE -ne 0) {
  Write-Host 'Banco ainda nao acessivel. Verifique a senha do banco e os logs.' -ForegroundColor Red
  exit 1
}

Write-Host 'Aplicando migrations do MARKYS SGA...'
& (Join-Path $root 'runtime\frankenphp.exe') php-cli bin/console doctrine:migrations:migrate --no-interaction
if ($LASTEXITCODE -ne 0) { throw 'Migrations falharam. Nao continue ate corrigir o banco.' }

Write-Host 'Iniciando servidor web em http://0.0.0.0:8080'
Write-Host 'Clientes da rede devem usar http://IP-DO-SERVIDOR:8080'
& (Join-Path $root 'runtime\frankenphp.exe') php-server --listen '0.0.0.0:8080' --root public
