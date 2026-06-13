<#
.SYNOPSIS
    RuiditoAgentes - nucleo de notificacion (Windows).

.DESCRIPTION
    Reproduce un sonido (cualquier formato: wav, mp3, ogg, flac, m4a...) y, de
    forma opcional, muestra una notificacion de texto. Pensado para que cualquier
    agente de IA lo ejecute cuando pide permiso o tu atencion.

    Configuracion (precedencia: parametros > variables de entorno > config.json > defaults):
      - Sonido:  -Sound <ruta> | $env:RUIDITO_SOUND | config.json .sound | sounds/notify.wav
      - Texto:   -Message <txt> | $env:RUIDITO_MESSAGE | config.json .message | "Tu agente necesita tu atencion"
      - Sin sonido:  -NoSound | $env:RUIDITO_NO_SOUND=1 | config.json .playSound=false
      - Sin texto:   -NoText  | $env:RUIDITO_NO_TEXT=1  | config.json .showText=false

.EXAMPLE
    powershell -ExecutionPolicy Bypass -NoProfile -File core\notify.ps1 -Message "Claude pide permiso"
#>

param(
    [string]$Message,
    [string]$Sound,
    [switch]$NoSound,
    [switch]$NoText
)

$ErrorActionPreference = 'SilentlyContinue'

$repoRoot   = Split-Path $PSScriptRoot -Parent
$configPath = Join-Path $repoRoot 'config.json'

# --- Cargar config.json si existe ---
$config = $null
if (Test-Path $configPath) {
    try { $config = (Get-Content $configPath -Raw | ConvertFrom-Json) } catch { $config = $null }
}
function Get-Config($name) {
    if ($config -and ($config.PSObject.Properties.Name -contains $name)) { return $config.$name }
    return $null
}

# --- Resolver opciones (parametro > entorno > config > default) ---
if (-not $Sound)   { $Sound = $env:RUIDITO_SOUND }
if (-not $Sound)   { $Sound = Get-Config 'sound' }
if (-not $Sound)   { $Sound = Join-Path $repoRoot 'sounds\notify.wav' }
elseif (-not [System.IO.Path]::IsPathRooted($Sound)) { $Sound = Join-Path $repoRoot $Sound }

if (-not $Message) { $Message = $env:RUIDITO_MESSAGE }
if (-not $Message) { $Message = Get-Config 'message' }
if (-not $Message) { $Message = 'Tu agente necesita tu atencion' }

$playSound = -not ($NoSound -or $env:RUIDITO_NO_SOUND -eq '1' -or (Get-Config 'playSound') -eq $false)
$showText  = -not ($NoText  -or $env:RUIDITO_NO_TEXT  -eq '1' -or (Get-Config 'showText')  -eq $false)

# --- Reproducir audio (cualquier formato) ---
function Invoke-PlayAudio($path) {
    if (-not (Test-Path $path)) { [System.Media.SystemSounds]::Asterisk.Play(); return }
    $ext = [System.IO.Path]::GetExtension($path).ToLower()

    if ($ext -eq '.wav') {
        # Ruta nativa y fiable para WAV
        (New-Object System.Media.SoundPlayer $path).PlaySync()
        return
    }

    # Formatos comprimidos: MediaPlayer de WPF (sin dependencias externas)
    try {
        Add-Type -AssemblyName presentationCore -ErrorAction Stop
        $player = New-Object System.Windows.Media.MediaPlayer
        $player.Open([System.Uri]::new((Resolve-Path $path).Path))
        $waited = 0
        while (-not $player.NaturalDuration.HasTimeSpan -and $waited -lt 2000) {
            Start-Sleep -Milliseconds 50; $waited += 50
        }
        $player.Play()
        if ($player.NaturalDuration.HasTimeSpan) {
            Start-Sleep -Milliseconds ([int]$player.NaturalDuration.TimeSpan.TotalMilliseconds + 200)
        } else {
            Start-Sleep -Seconds 3
        }
        $player.Close()
        return
    } catch { }

    # Respaldos: ffplay si existe, si no el sonido de sistema
    if (Get-Command ffplay -ErrorAction SilentlyContinue) {
        & ffplay -nodisp -autoexit -loglevel quiet $path
    } else {
        [System.Media.SystemSounds]::Asterisk.Play()
    }
}

# --- Mostrar notificacion de texto ---
function Show-TextNotification($text) {
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        $icon = New-Object System.Windows.Forms.NotifyIcon
        $icon.Icon = [System.Drawing.SystemIcons]::Information
        $icon.Visible = $true
        $icon.ShowBalloonTip(5000, 'RuiditoAgentes', $text, [System.Windows.Forms.ToolTipIcon]::Info)
        Start-Sleep -Milliseconds 400
        $icon.Dispose()
    } catch { }
}

if ($showText)  { Show-TextNotification $Message }
if ($playSound) { Invoke-PlayAudio $Sound }
