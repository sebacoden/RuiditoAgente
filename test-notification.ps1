<#
.SYNOPSIS
    RuiditoAgentes - prueba la notificacion (Windows).

.DESCRIPTION
    Dispara la notificacion (sonido + texto) para comprobar que todo funciona,
    sin necesidad de un agente. Pasa los mismos parametros que core\notify.ps1.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File test-notification.ps1
    powershell -ExecutionPolicy Bypass -File test-notification.ps1 -Sound "sounds\otro.mp3"
    powershell -ExecutionPolicy Bypass -File test-notification.ps1 -NoText   # solo sonido
#>

param(
    [string]$Message = 'Notificacion de prueba de RuiditoAgentes',
    [string]$Sound,
    [switch]$NoSound,
    [switch]$NoText
)

$notify = Join-Path $PSScriptRoot 'core\notify.ps1'

Write-Host "Probando notificacion de RuiditoAgentes..." -ForegroundColor Cyan
Write-Host "  Deberias escuchar un sonido" -NoNewline
if (-not $NoText) { Write-Host " y ver un aviso de texto." } else { Write-Host "." }

$params = @{ Message = $Message }
if ($Sound)   { $params.Sound = $Sound }
if ($NoSound) { $params.NoSound = $true }
if ($NoText)  { $params.NoText = $true }

& $notify @params

Write-Host ""
Write-Host "Si lo escuchaste/viste, funciona. Si no:" -ForegroundColor Green
Write-Host "  - Subi el volumen y revisa que el archivo de sonido exista."
Write-Host "  - Consulta la seccion 'Solucion de problemas' del README."
