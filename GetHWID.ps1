function Get-UnifiedHWID {
    try {
        $uuid = (Get-CimInstance Win32_ComputerSystemProduct -ErrorAction SilentlyContinue).UUID
        $invalidos = @("FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF", "00000000-0000-0000-0000-000000000000", "")
        if ($uuid -and $uuid -notin $invalidos) { return $uuid }
    } catch {}

    try {
        $mac = (Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1).LinkAddress
        if ($mac) { 
            $macLimpo = $mac.Replace("-", "").Replace(":", "")
            return "MAC-" + [Convert]::ToUInt64($macLimpo, 16).ToString()
        }
    } catch {}
    return "DESCONHECIDO"
}