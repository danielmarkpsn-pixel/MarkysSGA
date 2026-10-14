# Instala a base de dados local e cria segredos exclusivos desta instalacao.
# Executar uma vez no computador que sera o servidor.
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
Set-Location $root

$pgBin = Join-Path $root 'runtime\postgres\bin'
$pgData = Join-Path $root 'data\postgres'
$envFile = Join-Path $root '.env.local'
$private = Join-Path $root 'config\jwt\private.pem'
$public = Join-Path $root 'config\jwt\public.pem'

if (!(Test-Path (Join-Path $pgBin 'initdb.exe'))) { throw 'PostgreSQL portatil nao encontrado. Baixe novamente o pacote completo.' }
if (Test-Path $envFile) { throw '.env.local ja existe. Por seguranca, instalacao inicial cancelada para nao sobrescrever segredos.' }

New-Item -ItemType Directory -Force -Path $pgData, (Join-Path $root 'data\backups'), (Join-Path $root 'logs'), (Split-Path $private) | Out-Null
function New-RandomHex([int]$Bytes = 32) {
  $buffer = New-Object byte[] $Bytes
  $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
  try { $rng.GetBytes($buffer) } finally { $rng.Dispose() }
  return ([BitConverter]::ToString($buffer)).Replace('-', '').ToLowerInvariant()
}
$pgPassword = New-RandomHex 24
$appSecret = New-RandomHex 32
$mercureSecret = New-RandomHex 32
$oauthPass = New-RandomHex 24
$oauthEnc = New-RandomHex 32

if (!(Test-Path $pgData -PathType Container) -or !(Get-ChildItem $pgData -Force -ErrorAction SilentlyContinue)) {
  $pwFile = Join-Path $env:TEMP ('markys-pg-' + [guid]::NewGuid().ToString('N') + '.txt')
  try {
    Set-Content -Path $pwFile -Value $pgPassword -NoNewline -Encoding ascii
    & (Join-Path $pgBin 'initdb.exe') -D $pgData -U markys -A scram-sha-256 --pwfile=$pwFile --encoding=UTF8
    if ($LASTEXITCODE -ne 0) { throw 'initdb falhou.' }
  } finally { Remove-Item $pwFile -Force -ErrorAction SilentlyContinue }
}

@'
listen_addresses = '127.0.0.1'
port = 5432
password_encryption = scram-sha-256
'@ | Set-Content (Join-Path $pgData 'postgresql.auto.conf') -Encoding ascii

$envText = @"
APP_ENV=prod
APP_DEBUG=0
APP_SECRET=$appSecret
APP_SHARE_DIR=var/share
DEFAULT_URI=http://localhost:8080
DATABASE_URL="postgresql://markys:$pgPassword@127.0.0.1:5432/markys?serverVersion=16&charset=utf8"
MESSENGER_TRANSPORT_DSN=doctrine://default?auto_setup=0
MAILER_DSN=null://null
MERCURE_URL=http://127.0.0.1:8080/.well-known/mercure
MERCURE_PUBLIC_URL=/.well-known/mercure
MERCURE_JWT_SECRET=$mercureSecret
MERCURE_PUBLISHER_JWT_KEY=$mercureSecret
MERCURE_SUBSCRIBER_JWT_KEY=$mercureSecret
APP_LANGUAGE=pt_BR
APP_BUILD_NUMBER=windows-portable
OAUTH_PRIVATE_KEY=config/jwt/private.pem
OAUTH_PUBLIC_KEY=config/jwt/public.pem
OAUTH_PASSPHRASE=$oauthPass
OAUTH_ENCRYPTION_KEY=$oauthEnc
"@
[IO.File]::WriteAllText($envFile, $envText, (New-Object System.Text.UTF8Encoding($false)))

& (Join-Path $root 'runtime\frankenphp.exe') php-cli (Join-Path $root 'gerar-chaves.php')
if ($LASTEXITCODE -ne 0 -or !(Test-Path $private) -or !(Test-Path $public)) {
  throw 'Falha ao gerar chaves JWT. Verifique se a extensao openssl esta disponivel no runtime.'
}

Write-Host ''
Write-Host 'MARKYS SGA: base local preparada.' -ForegroundColor Green
Write-Host 'Agora execute INICIAR-MARKYS.bat para iniciar os servicos e siga as instrucoes de instalacao inicial.'
Write-Host 'Guarde a pasta data\backups e o arquivo .env.local em local seguro.'
