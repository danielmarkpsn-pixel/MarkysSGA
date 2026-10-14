# Inicializa PostgreSQL e FrankenPHP. A instalacao inicial do NovoSGA e executada separadamente.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
$pgBin = Join-Path $root 'runtime\postgres\bin'
$pgData = Join-Path $root 'data\postgres'
$pgLog = Join-Path $root 'logs\postgres.log'
$env:PATH = (Join-Path $root 'runtime\postgres\bin') + ';' + $env:PATH
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
if ($envText -notmatch 'DATABASE_URL="postgresql://markys:([^@]+)@') { throw 'Senha do banco nao foi lida do .env.local.' }
$env:PGPASSWORD = $Matches[1]
$dbExists = & (Join-Path $pgBin 'psql.exe') -h 127.0.0.1 -p 5432 -U markys -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='markys'" 2>$null
if ($LASTEXITCODE -eq 0 -and "$dbExists".Trim() -ne '1') {
  & (Join-Path $pgBin 'createdb.exe') -h 127.0.0.1 -p 5432 -U markys markys
  if ($LASTEXITCODE -ne 0) { throw 'Nao foi possivel criar o banco markys.' }
}
& (Join-Path $pgBin 'psql.exe') -h 127.0.0.1 -p 5432 -U markys -d markys -c 'SELECT 1'
if ($LASTEXITCODE -ne 0) { throw 'Banco ainda nao acessivel. Verifique a senha e logs\postgres.log.' }

Write-Host 'Aplicando migrations do MARKYS SGA...'
& (Join-Path $root 'runtime\frankenphp.exe') php-cli bin/console doctrine:migrations:migrate --no-interaction
if ($LASTEXITCODE -ne 0) { throw 'Migrations falharam. Nao continue ate corrigir o banco.' }

Write-Host 'Iniciando servidor web em http://0.0.0.0:8080'
Write-Host 'Clientes da rede devem usar http://IP-DO-SERVIDOR:8080'
& (Join-Path $root 'runtime\frankenphp.exe') run --config (Join-Path $root 'etc\Caddyfile')
