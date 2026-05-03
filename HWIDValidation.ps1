$b64 = "MXhPdkNUcEI2OVBHWmp2UUFsQWFsNm43Sk5FQVh4TUQ3ajZ6dG84dVE2NjQ="
$sID = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($b64))
$url = "https://docs.google.com/spreadsheets/d/$sID/export?format=csv&gid=0"

function Confirm-License ($hwidLocal) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    try {
        # Criamos o cliente .NET (Base do que o Python usa internamente)
        $handler = New-Object System.Net.Http.HttpClientHandler
        $client = New-Object System.Net.Http.HttpClient($handler)
        
        # Simulamos um navegador moderno para evitar o erro 404/403
        $client.DefaultRequestHeaders.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
        
        # Fazemos a chamada assíncrona e aguardamos o resultado
        $task = $client.GetStringAsync($url)
        $rawCsv = $task.Result 
        
        # Converte a string CSV em objetos do PowerShell
        $dados = $rawCsv | ConvertFrom-Csv

        foreach ($l in $dados) {
            # Pegamos os valores das colunas HWID (E/4) e STATUS (F/5)
            $hwidPlanilha = ($l.psobject.Properties.Value[4]).ToString().Trim()
            $statusPlanilha = ($l.psobject.Properties.Value[5]).ToString().Trim()

            if ($hwidPlanilha -ieq $hwidLocal -and $statusPlanilha -ieq "APROVADO") {
                $client.Dispose()
                return $true
            }
        }
        $client.Dispose()
    } catch {
        Write-Host "[X] Erro de Comunicacao: $($_.Exception.Message)" -ForegroundColor Red
    }
    return $false
}