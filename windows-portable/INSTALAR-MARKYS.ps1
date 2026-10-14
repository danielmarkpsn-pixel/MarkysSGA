# Instala a base de dados local e cria segredos exclusivos desta instalacao.
# Executar uma vez no computador que sera o servidor.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$pgBin = Join-Path $root 'runtime\postgres\bin'
$pgData = Join-Path $root 'data\postgres'
$envFile = Join-Path $root '.env.local'
$private = Join-Path $root 'config\jwt\private.pem'
$public = Join-Path $root 'config\jwt\public.pem'

if (!(Test-Path (Join-Path $pgBin 'initdb.exe'))) { throw 'PostgreSQL portatil nao encontrado. Baixe novamente o pacote completo.' }
if (Test-Path $envFile) { throw '.env.local ja existe. Por seguranca, instalacao inicial cancelada para nao sobrescrever segredos.' }

New-Item -ItemType Directory -Force -Path $pgData, (Join-Path $root 'data\backups'), (Join-Path $root 'logs'), (Split-Path $private) | Out-Null
$pgPassword = [Convert]::ToBase64String([Security.Cryptography.RandomNumberGenerator]::GetBytes(24))
$appSecret = [Convert]::ToBase64String([Security.Cryptography.RandomNumberGenerator]::GetBytes(32))
$mercureSecret = [Convert]::ToBase64String([Security.Cryptography.RandomNumberGenerator]::GetBytes(32))
$oauthPass = [Convert]::ToBase64String([Security.Cryptography.RandomNumberGenerator]::GetBytes(24))
$oauthEnc = [Convert]::ToBase64String([Security.Cryptography.RandomNumberGenerator]::GetBytes(32))

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
Set-Content -Path $envFile -Value $envText -Encoding utf8

# Chaves RSA para o servidor OAuth. O openssl acompanha o pacote FrankenPHP se presente.
$openssl = Join-Path $root 'runtime\openssl.exe'
if (!(Test-Path $openssl)) { $openssl = (Get-Command openssl.exe -ErrorAction SilentlyContinue).Source }
if (!$openssl) { throw 'OpenSSL nao encontrado. O runtime precisa incluir openssl.exe para gerar as chaves JWT.' }
& $openssl genrsa -out $private 2048
if ($LASTEXITCODE -ne 0) { throw 'Falha ao gerar chave privada OAuth.' }
& $openssl rsa -in $private -pubout -out $public
if ($LASTEXITCODE -ne 0) { throw 'Falha ao gerar chave publica OAuth.' }

Write-Host ''
Write-Host 'MARKYS SGA: base local preparada.' -ForegroundColor Green
Write-Host 'Agora execute INICIAR-MARKYS.bat para iniciar os servicos e siga as instrucoes de instalacao inicial.'
Write-Host 'Guarde a pasta data\backups e o arquivo .env.local em local seguro.'
