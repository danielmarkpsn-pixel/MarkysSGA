$ErrorActionPreference = 'Continue'
$root = Split-Path -Parent $PSScriptRoot
$pgCtl = Join-Path $root 'runtime\postgres\bin\pg_ctl.exe'
$pgData = Join-Path $root 'data\postgres'
if (Test-Path $pgCtl -and (Test-Path (Join-Path $pgData 'postmaster.pid'))) {
  & $pgCtl -D $pgData stop -m fast
}
Write-Host 'O servidor web deve ser encerrado com Ctrl+C na janela em que foi iniciado.'
