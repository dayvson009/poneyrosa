# No topo do seu ativar.ps1
# $ErrorActionPreference = "SilentlyContinue"

# Script de Ativação Corel - Executado via Python
Param([string]$caminhoDllOrigem)

$caminhoCorel = "$env:ProgramFiles\Corel\PASMUtility\v1"
$destino = "$caminhoCorel\PASMUTILITY.dll"

# 1. Criar Regras de Firewall
netsh advfirewall firewall add rule name="Corel27_Block_Out" dir=out action=block program="$env:ProgramFiles\Corel\CorelDRAW Graphics Suite\27\Programs64\CorelDRW.exe" enable=yes
netsh advfirewall firewall add rule name="Corel27_Block_In" dir=in action=block program="$env:ProgramFiles\Corel\CorelDRAW Graphics Suite\27\Programs64\CorelDRW.exe" enable=yes

# 2. Mover a DLL (Se a pasta existir)
if (Test-Path $caminhoCorel) {
    if (Test-Path $destino) {
        takeown /f $destino
        icacls $destino /grant Everyone:F
    }
    Move-Item -Path $caminhoDllOrigem -Destination $destino -Force
    Write-Host "Sucesso"
} else {
    Write-Host "Caminho_Nao_Encontrado"
}