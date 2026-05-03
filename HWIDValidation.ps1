$b64 = "MXhPdkNUcEI2OVBHWmp2UUFsQWFsNm43Sk5FQVh4TUQ3ajZ6dG84dVE2NjQ="
$sID = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($b64))
$url = "https://docs.google.com/spreadsheets/d/$sID/export?format=csv&gid=0"

function Confirm-License ($hwidLocal) {
    
    $tempCSV = "$env:TEMP\licenca_infortec.csv"
    $url = "https://docs.google.com/spreadsheets/d/1xOvCTpB69PGYjvQAlAal6n7JNEAXxMD7j6zto8uQ664/export?format=csv&gid=0"

    try {
        Invoke-WebRequest -Uri $url -OutFile $tempCSV -UseBasicParsing -ErrorAction Stop

        $dados = Import-Csv -Path $tempCSV -Delimiter "," 

        foreach ($linha in $dados) {
            $hwidPlanilha = $linha.psobject.Properties.Value[4]
            $statusPlanilha = $linha.psobject.Properties.Value[5]

            if ($hwidPlanilha -and $hwidPlanilha.Trim() -ieq $hwidLocal.Trim() -and $statusPlanilha -ieq "APROVADO") {
                Remove-Item $tempCSV -ErrorAction SilentlyContinue
                return $true
            }
        }
    } catch {
        Write-Host "[X] Erro ao processar banco de dados local." -ForegroundColor Red
    }

    # Limpeza e retorno negativo
    Remove-Item $tempCSV -ErrorAction SilentlyContinue
    return $false
}