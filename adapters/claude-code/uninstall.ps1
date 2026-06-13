<#
.SYNOPSIS
    Quita el hook de sonido de notificacion de Claude Code (Windows).
#>

param(
    [string]$SettingsPath = (Join-Path $HOME '.claude\settings.json')
)

$ErrorActionPreference = 'Stop'

# Compatibilidad con Windows PowerShell 5.1 (sin -AsHashtable).
function ConvertTo-HashtableDeep($obj) {
    if ($null -eq $obj) { return $null }
    if ($obj -is [System.Collections.IEnumerable] -and $obj -isnot [string] -and $obj -isnot [System.Collections.IDictionary]) {
        $arr = @()
        foreach ($item in $obj) { $arr += ,(ConvertTo-HashtableDeep $item) }
        return ,$arr
    }
    if ($obj -is [System.Management.Automation.PSCustomObject]) {
        $ht = @{}
        foreach ($p in $obj.PSObject.Properties) { $ht[$p.Name] = ConvertTo-HashtableDeep $p.Value }
        return $ht
    }
    return $obj
}

if (-not (Test-Path $SettingsPath)) {
    Write-Host "No se encontro $SettingsPath. Nada que quitar."
    return
}

$settings = ConvertTo-HashtableDeep ((Get-Content $SettingsPath -Raw) | ConvertFrom-Json)

if ($settings.ContainsKey('hooks') -and $settings['hooks'].ContainsKey('Notification')) {
    $settings['hooks']['Notification'] = @($settings['hooks']['Notification'] | Where-Object {
        -not ($_.hooks | Where-Object { $_.command -like '*core\notify.ps1*' })
    })
    if ($settings['hooks']['Notification'].Count -eq 0) {
        $settings['hooks'].Remove('Notification') | Out-Null
    }
    $settings | ConvertTo-Json -Depth 100 | Set-Content $SettingsPath -Encoding UTF8
    Write-Host "Hook de sonido quitado. Reinicia Claude Code." -ForegroundColor Green
} else {
    Write-Host "No habia ningun hook de notificacion configurado."
}
