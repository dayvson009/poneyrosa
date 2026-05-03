$b64 = "MXhPdkNUcEI2OVBHWmp2UUFsQWFsNm43Sk5FQVh4TUQ3ajZ6dG84dVE2NjQ="
$sID = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($b64))
$url = "https://docs.google.com/spreadsheets/d/$sID/export?format=csv&gid=0"

function Confirm-License ($hwidLocal) {
    # Garante segurança de conexão
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    try {
        # Criamos um objeto de cliente web e simulamos um navegador real (User-Agent)
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
        
        # Baixa os dados como string e converte
        $rawCsv = $wc.DownloadString($url)
        $dados = $rawCsv | ConvertFrom-Csv

        foreach ($l in $dados) {
            # Pegamos os valores das colunas E (4) e F (5)
            $hwidPlanilha = ($l.psobject.Properties.Value[4]).ToString().Trim()
            $statusPlanilha = ($l.psobject.Properties.Value[5]).ToString().Trim()

            # Comparação ignorando maiúsculas/minúsculas
            if ($hwidPlanilha -ieq $hwidLocal -and $statusPlanilha -ieq "APROVADO") {
                return $true
            }
        }
    } catch {
        # Se mesmo assim der erro, mostraremos o detalhe técnico
        Write-Host "[X] Falha na comunicacao: $($_.Exception.Message)" -ForegroundColor Red
    }
    return $false
}