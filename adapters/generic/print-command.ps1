<#
.SYNOPSIS
    Imprime el comando de RuiditoAgentes para pegar en cualquier agente (Windows).

.DESCRIPTION
    No modifica nada: solo muestra el comando exacto que debes configurar en tu
    agente para que ejecute la notificacion (sonido + texto). Util cuando el
    agente no tiene un instalador dedicado en adapters/.
#>

param([string]$Message = 'Tu agente necesita tu atencion')

$repoDir = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$notify  = Join-Path $repoDir 'core\notify.ps1'
$command = "powershell -ExecutionPolicy Bypass -NoProfile -File `"$notify`" -Message `"$Message`""

Write-Host "Configura este comando en el evento de notificacion de tu agente:`n"
Write-Host $command -ForegroundColor Green
Write-Host "`nConsejos:"
Write-Host "  - Cambia el sonido reemplazando $repoDir\sounds\notify.wav (cualquier formato) o via config.json."
Write-Host "  - Para fusionarlo automaticamente en un settings.json/toml/yaml, usa lib\merge-config.py."
