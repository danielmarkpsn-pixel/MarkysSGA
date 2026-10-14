# MARKYS SGA — diagnóstico inicial do computador servidor
# Somente leitura: não instala programas, não altera o Firewall e não abre portas.

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " MARKYS SGA - Diagnóstico Windows / Rede LAN"
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

try {
    $os = Get-CimInstance Win32_OperatingSystem
    Write-Host ("Windows: {0} (build {1})" -f $os.Caption, $os.BuildNumber)
} catch {
    Write-Host "Windows: não foi possível determinar a versão."
}

Write-Host ""
Write-Host "Adaptadores de rede ativos e endereços IPv4:"
try {
    Get-NetIPConfiguration |
        Where-Object { $_.NetAdapter.Status -eq "Up" -and $_.IPv4Address } |
        ForEach-Object {
            $addresses = ($_.IPv4Address | ForEach-Object { $_.IPAddress }) -join ", "
            Write-Host (" - {0}: {1}" -f $_.InterfaceAlias, $addresses)
        }
} catch {
    ipconfig
}

Write-Host ""
Write-Host "Verificação de portas locais comuns (não abre portas):"
$ports = @(80, 443, 5432, 8000, 8080, 3000, 2222)
foreach ($port in $ports) {
    $listeners = @(Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue)
    if ($listeners.Count -gt 0) {
        Write-Host (" - Porta {0}: EM USO (listener encontrado)" -f $port) -ForegroundColor Yellow
    } else {
        Write-Host (" - Porta {0}: sem listener detectado" -f $port)
    }
}

Write-Host ""
Write-Host "Ferramentas já disponíveis (apenas deteção):"
foreach ($command in @("php", "composer", "psql", "pg_ctl", "docker", "git")) {
    $found = Get-Command $command -ErrorAction SilentlyContinue
    if ($found) {
        Write-Host (" - {0}: {1}" -f $command, $found.Source)
    } else {
        Write-Host (" - {0}: não encontrado no PATH" -f $command)
    }
}

Write-Host ""
Write-Host "Diagnóstico concluído. Nenhuma configuração foi alterada."
Write-Host "Guarde estas informações para a preparação do pacote portátil."
Write-Host ""
Read-Host "Pressione Enter para fechar"
