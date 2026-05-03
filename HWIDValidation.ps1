$b64 = "MXhPdkNUcEI2OVBHWmp2UUFsQWFsNm43Sk5FQVh4TUQ3ajZ6dG84dVE2NjQ="
$sID = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($b64))
$url = "https://docs.google.com/spreadsheets/d/$sID/export?format=csv&gid=0"

function Confirm-License ($hwidLocal) {
    try {
        # Adicionamos o cabeçalho explicitamente caso a planilha não tenha
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing
        $dados = $response.Content | ConvertFrom-Csv

        foreach ($l in $dados) {
            # Pegamos os valores das colunas E e F (Índices 4 e 5)
            $hwidPlanilha = ($l.psobject.Properties.Value[4]).ToString().Trim()
            $statusPlanilha = ($l.psobject.Properties.Value[5]).ToString().Trim()

            # DEBUG: Remova estas linhas após testar
            # Write-Host "Comparando: [$hwidPlanilha] com [$hwidLocal]" -ForegroundColor Gray

            if ($hwidPlanilha -eq $hwidLocal -and $statusPlanilha -eq "APROVADO") {
                return $true
            }
        }
    } catch {
        Write-Host "Erro ao acessar planilha: $($_.Exception.Message)" -ForegroundColor Red
    }
    return $false
}