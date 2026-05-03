# --- IMPORTAÇÃO DE MÓDULOS REMOTOS ---
# Importa a lógica de captura de ID e a validação da planilha
irm "https://raw.githubusercontent.com/dayvson009/poneyrosa/main/GetHWID.ps1" | iex
irm "https://raw.githubusercontent.com/dayvson009/poneyrosa/main/HWIDValidation.ps1" | iex

# --- CONFIGURAÇÕES DE CAMINHO ---
$urlBin = "https://github.com/dayvson009/poneyrosa/raw/refs/heads/main/27.bin"
$caminhoCorel = "$env:ProgramFiles\Corel\PASMUtility\v1"
$destino = "$caminhoCorel\PASMUTILITY.dll"
$exeCorel = "$env:ProgramFiles\Corel\CorelDRAW Graphics Suite\27\Programs64\CorelDRW.exe"

Write-Host "==========================================" -ForegroundColor Yellow
Write-Host "   INFORTEC - SISTEMA DE ATIVAÇÃO 2026   " -ForegroundColor White -BackgroundColor Blue
Write-Host "==========================================" -ForegroundColor Yellow

# 1. Identificação e Validação
$myID = Get-UnifiedHWID
Write-Host "[*] Verificando Hardware" -ForegroundColor Gray

if (Confirm-License $myID) {
    Write-Host "[OK] LICENÇA VALIDADA COM SUCESSO!" -ForegroundColor Green
    
    # 2. Bloqueio de Firewall
    Write-Host "`n[*] Aplicando regras de Firewall..." -ForegroundColor Cyan
    netsh advfirewall firewall add rule name="Corel27_Block_Out" dir=out action=block program="$exeCorel" enable=yes
    netsh advfirewall firewall add rule name="Corel27_Block_In" dir=in action=block program="$exeCorel" enable=yes

    # 3. Processo de Patch (DLL)
    Write-Host "[*] Ativando Corel Draw v27..." -ForegroundColor Cyan
    if (Test-Path $caminhoCorel) {
        if (Test-Path $destino) {
            Set-ItemProperty $destino -Name IsReadOnly -Value $false
            takeown /f $destino /a > $null
            icacls $destino /grant "Administrators:F" > $null
            Remove-Item $destino -Force -ErrorAction SilentlyContinue
        }
        try {
            Invoke-WebRequest -Uri $urlBin -OutFile $destino -MaximumRedirection 5 -ErrorAction Stop
            Write-Host "[+] Ativação concluída com sucesso." -ForegroundColor Green
        } catch {
            Write-Host "[X] Erro ao baixar Ativador de ativação." -ForegroundColor Red
        }
    }

    # 4. Limpeza e Bloqueio da pasta de Mensagens (Pop-ups)
    $caminhoMessages = "$env:AppData\Corel\Messages"
    if (Test-Path $caminhoMessages) {
        Write-Host "[*] Bloqueando anuncios e pop-ups..." -ForegroundColor Cyan
        Remove-Item -Path "$caminhoMessages\*" -Recurse -Force -ErrorAction SilentlyContinue
        
        $acl = Get-Acl $caminhoMessages
        $acl.SetAccessRuleProtection($true, $false)
        $sidTodos = New-Object System.Security.Principal.SecurityIdentifier("S-1-1-0")
        $regraNegar = New-Object System.Security.AccessControl.FileSystemAccessRule($sidTodos, "FullControl", "Deny")
        $acl.AddAccessRule($regraNegar)
        Set-Acl $caminhoMessages $acl
        Write-Host "[+] Pop-ups bloqueados com sucesso." -ForegroundColor Green
    }

    Write-Host "`n==========================================" -ForegroundColor Yellow
    Write-Host "   ATIVAÇÃO CONCLUÍDA! FECHANDO EM 3S... " -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Yellow
    Start-Sleep -Seconds 3

} else {
    Write-Host "`n[X] COMPUTADOR NÃO AUTORIZADO!" -ForegroundColor White -BackgroundColor Red
    Write-Host "[!] Entre em contato: (81) 98531-5669" -ForegroundColor Yellow
    Start-Sleep -Seconds 10
}