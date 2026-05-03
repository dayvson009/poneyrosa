$b64 = "MXhPdkNUcEI2OVBHWmp2UUFsQWFsNm43Sk5FQVh4TUQ3ajZ6dG84dVE2NjQ="
$sID = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($b64))
$url = "https://docs.google.com/spreadsheets/d/$sID/export?format=csv&gid=0"

function Confirm-License ($hwidLocal) {
    try {
        $dados = (Invoke-WebRequest -Uri $url -UseBasicParsing).Content | ConvertFrom-Csv
        foreach ($l in $dados) {
            if ($l.psobject.Properties.Value[4] -eq $hwidLocal -and $l.psobject.Properties.Value[5] -eq "APROVADO") {
                return $true
            }
        }
    } catch {}
    return $false
}