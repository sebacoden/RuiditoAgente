<#
.SYNOPSIS
    RuiditoAgentes - instala el hook de notificacion en Claude Code (Windows).

.DESCRIPTION
    Agrega un hook "Notification" a ~/.claude/settings.json que reproduce un
    sonido (y muestra un aviso de texto) cada vez que Claude Code pide permiso
    o tu atencion. Fusiona la configuracion: respeta cualquier otro hook que ya tengas.

.PARAMETER SettingsPath
    Ruta alternativa al settings.json (por defecto ~/.claude/settings.json).

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File install.ps1
#>

param(
    [string]$SettingsPath = (Join-Path $HOME '.claude\settings.json')
)

$ErrorActionPreference = 'Stop'

# Convierte recursivamente la salida de ConvertFrom-Json (PSCustomObject) en
# hashtables/arrays. Necesario para compatibilidad con Windows PowerShell 5.1,
# que no tiene el parametro -AsHashtable.
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

# Raiz del repo (este script vive en adapters/claude-code/)
$repoDir    = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$notifyScript = Join-Path $repoDir 'core\notify.ps1'
$command    = "powershell -ExecutionPolicy Bypass -NoProfile -File `"$notifyScript`" -Message `"Claude Code necesita tu atencion`""

Write-Host "Instalando hook de RuiditoAgentes en Claude Code..." -ForegroundColor Cyan
Write-Host "  Nucleo:        $notifyScript"
Write-Host "  settings.json: $SettingsPath"

# --- Cargar settings.json existente (o crear uno vacio) ---
if (Test-Path $SettingsPath) {
    $raw = Get-Content $SettingsPath -Raw
    $settings = if ([string]::IsNullOrWhiteSpace($raw)) { @{} } else { ConvertTo-HashtableDeep ($raw | ConvertFrom-Json) }
    # Backup antes de tocar nada
    $backup = "$SettingsPath.bak"
    Copy-Item $SettingsPath $backup -Force
    Write-Host "  Backup creado:    $backup"
} else {
    New-Item -ItemType Directory -Force -Path (Split-Path $SettingsPath) | Out-Null
    $settings = @{}
}

if (-not $settings.ContainsKey('hooks'))               { $settings['hooks'] = @{} }
if (-not $settings['hooks'].ContainsKey('Notification')) { $settings['hooks']['Notification'] = @() }

# --- Evitar duplicados: borrar cualquier entrada previa de este proyecto ---
$existing = @($settings['hooks']['Notification'] | Where-Object {
    $entry = $_
    -not ($entry.hooks | Where-Object { $_.command -like '*core\notify.ps1*' })
})

$newEntry = @{
    matcher = ''
    hooks   = @(@{ type = 'command'; command = $command })
}

$settings['hooks']['Notification'] = @($existing) + $newEntry

# --- Guardar ---
$settings | ConvertTo-Json -Depth 100 | Set-Content $SettingsPath -Encoding UTF8

Write-Host ""
Write-Host "Listo. Reinicia Claude Code para que tome el cambio." -ForegroundColor Green
Write-Host "Para cambiar el sonido, reemplaza: $repoDir\sounds\notify.wav (o usa config.json)"
