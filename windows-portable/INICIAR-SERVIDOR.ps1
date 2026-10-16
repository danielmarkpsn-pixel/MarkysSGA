# Inicializa PostgreSQL e FrankenPHP. A instalacao inicial do NovoSGA e executada separadamente.
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
Set-Location $root
$pgBin = Join-Path $root 'runtime\postgres\bin'
$pgData = Join-Path $root 'data\postgres'
$pgLog = Join-Path $root 'logs\postgres.log'
$env:PATH = (Join-Path $root 'runtime\postgres\bin') + ';' + $env:PATH
$env:PHPRC = Join-Path $root 'runtime\php.ini'
$env:APP_ENV = 'prod'
$env:APP_DEBUG = '0'
$env:SERVER_ROOT = (Join-Path $root 'public').Replace('\','/')
$env:SERVER_NAME = ':8080'
$env:FRANKENPHP_CONFIG = ''
$env:APP_RUNTIME = 'Runtime\FrankenPhpSymfony\Runtime'

if (!(Test-Path '.env.local')) { throw 'Execute INSTALAR-MARKYS.bat primeiro.' }
if (!(Test-Path (Join-Path $pgData 'PG_VERSION'))) { throw 'Banco ainda nao inicializado. Execute INSTALAR-MARKYS.bat.' }

$envText = Get-Content '.env.local' -Raw
if ($envText -notmatch 'MERCURE_JWT_SECRET=(.+)') { throw 'MERCURE_JWT_SECRET ausente em .env.local.' }
$secret = $Matches[1].Trim()
$env:MERCURE_PUBLISHER_JWT_KEY = $secret
$env:MERCURE_SUBSCRIBER_JWT_KEY = $secret

# Verifica o estado real do PostgreSQL; postmaster.pid sozinho pode estar obsoleto.
$pgCtl = Join-Path $pgBin 'pg_ctl.exe'
$psql = Join-Path $pgBin 'psql.exe'
$pgStatusOutput = & $pgCtl -D $pgData status 2>&1
$pgStatus = $LASTEXITCODE
if ($pgStatus -ne 0) {
  Write-Host 'Iniciando PostgreSQL local...'
  $startOutput = & $pgCtl -D $pgData -l $pgLog -o '-h 127.0.0.1 -p 5432' start 2>&1
  $startCode = $LASTEXITCODE
  if ($startCode -ne 0) {
    Write-Host ($startOutput | Out-String)
    if (Test-Path $pgLog) { Get-Content $pgLog -Tail 40 }
    throw 'PostgreSQL nao iniciou. Consulte logs\postgres.log; confira se a porta 5432 esta livre e se data\postgres esta integra.'
  }
}

$env:DATABASE_URL = ([regex]::Match($envText, 'DATABASE_URL="([^"]+)"')).Groups[1].Value
if (!$env:DATABASE_URL) { throw 'DATABASE_URL nao foi lida do .env.local.' }
if ($envText -notmatch 'DATABASE_URL="postgresql://markys:([^@]+)@') { throw 'Senha do banco nao foi lida do .env.local.' }
$env:PGPASSWORD = $Matches[1]

# Aguarda o banco ficar pronto, em vez de consultar imediatamente após pg_ctl start.
$ready = $false
for ($attempt = 1; $attempt -le 30; $attempt++) {
  $null = & $psql -h 127.0.0.1 -p 5432 -U markys -d postgres -tAc 'SELECT 1' 2>$null
  if ($LASTEXITCODE -eq 0) {
    $ready = $true
    break
  }
  Start-Sleep -Seconds 2
}
if (!$ready) {
  if (Test-Path $pgLog) { Get-Content $pgLog -Tail 60 }
  throw 'PostgreSQL nao respondeu em 60 segundos. Consulte logs\postgres.log; confira a porta 5432, as permissoes e data\postgres.'
}

$dbExists = & $psql -h 127.0.0.1 -p 5432 -U markys -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='markys'" 2>$null
if ($LASTEXITCODE -ne 0) { throw 'PostgreSQL iniciou, mas nao foi possivel consultar o catalogo. Confira a senha em .env.local.' }
if ("$dbExists".Trim() -ne '1') {
  & (Join-Path $pgBin 'createdb.exe') -h 127.0.0.1 -p 5432 -U markys markys
  if ($LASTEXITCODE -ne 0) { throw 'Nao foi possivel criar o banco markys.' }
}
& $psql -h 127.0.0.1 -p 5432 -U markys -d markys -c 'SELECT 1' 2>&1
if ($LASTEXITCODE -ne 0) { throw 'Banco ainda nao acessivel. Verifique a senha e logs\postgres.log.' }

Write-Host 'Aplicando migrations do MARKYS SGA...'
& (Join-Path $root 'runtime\frankenphp.exe') php-cli bin/console doctrine:migrations:migrate --no-interaction
if ($LASTEXITCODE -ne 0) { throw 'Migrations falharam. Nao continue ate corrigir o banco.' }

Write-Host 'Iniciando servidor web em http://0.0.0.0:8080'
Write-Host 'Clientes da rede devem usar http://IP-DO-SERVIDOR:8080'
& (Join-Path $root 'runtime\frankenphp.exe') run --config (Join-Path $root 'etc\Caddyfile')
