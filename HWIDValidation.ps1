$b64 = "MXhPdkNUcEI2OVBHWmp2UUFsQWFsNm43Sk5FQVh4TUQ3ajZ6dG84dVE2NjQ="
$sID = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($b64))
$url = "https://docs.google.com/spreadsheets/d/$sID/export?format=csv&gid=0"

function Confirm-License ($hwidLocal) {
    $tempCSV = "$env:TEMP\licenca_infortec.csv"

    try {
        Invoke-WebRequest -Uri $url -OutFile $tempCSV -UseBasicParsing -ErrorAction Stop
        $dados = Import-Csv -Path $tempCSV -Delimiter "," 

        # Limpamos o HWID local uma única vez no início para evitar erros de nulo depois
        $hwidLocalLimpo = if ($null -ne $hwidLocal) { $hwidLocal.ToString().Trim() } else { "" }

        foreach ($linha in $dados) {
            # Captura os valores usando o nome das colunas (mais seguro que índice)
            $valHwid = $linha.HWID
            $valStatus = $linha.STATUS

            # Se a linha atual não tiver HWID ou STATUS, pula para a próxima sem dar erro
            if ([string]::IsNullOrWhiteSpace($valHwid) -or [string]::IsNullOrWhiteSpace($valStatus)) {
                continue
            }

            $hwidPlanilha = $valHwid.ToString().Trim()
            $statusPlanilha = $valStatus.ToString().Trim()

            # Comparação de Aprovação
            if ($hwidPlanilha -ieq $hwidLocalLimpo -and $statusPlanilha -ieq "APROVADO") {
                Write-Host "[!] Aprovado." -ForegroundColor Green
                Remove-Item $tempCSV -ErrorAction SilentlyContinue
                return $true
            }

            # Comparação de Rejeição
            if ($hwidPlanilha -ieq $hwidLocalLimpo -and $statusPlanilha -ieq "REJEITADO") {
                Write-Host "[x] Permissao negada pelo administrador." -ForegroundColor Red
                Remove-Item $tempCSV -ErrorAction SilentlyContinue
                return $false
            }
        }

        # Se terminou o loop e não retornou TRUE, significa que não achou o HWID aprovado
        Write-Host "[X] HWID nao encontrado ou pendente de aprovacao." -ForegroundColor Yellow

    } catch {
        Write-Host "[X] Erro ao processar solicitacao: $($_.Exception.Message)" -ForegroundColor Red
    }

    Remove-Item $tempCSV -ErrorAction SilentlyContinue
    return $false
}