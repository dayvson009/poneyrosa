function Ativar-Corel {
    Param([string]$caminhoDllOrigem)

    Write-Host "Processando origem: $caminhoDllOrigem"
    
    $caminhoCorel = "$env:ProgramFiles\Corel\PASMUtility\v1"
    $destino = "$caminhoCorel\PASMUTILITY.dll"

    # Regras de Firewall
    netsh advfirewall firewall add rule name="Corel27_Block_Out" dir=out action=block program="$env:ProgramFiles\Corel\CorelDRAW Graphics Suite\27\Programs64\CorelDRW.exe" enable=yes
    netsh advfirewall firewall add rule name="Corel27_Block_In" dir=in action=block program="$env:ProgramFiles\Corel\CorelDRAW Graphics Suite\27\Programs64\CorelDRW.exe" enable=yes

    if (Test-Path $caminhoCorel) {
        if (Test-Path $destino) {
            Set-ItemProperty $destino -Name IsReadOnly -Value $false
            takeown /f $destino /a
            icacls $destino /grant "Administrators:F"
            Remove-Item $destino -Force -ErrorAction SilentlyContinue
        }
        Copy-Item -Path $caminhoDllOrigem -Destination $destino -Force
        if (Test-Path $destino) { Write-Host "Sucesso" } else { Write-Host "Erro_Copia" }
    } else {
        Write-Host "Pasta_Nao_Encontrada"
    }
}