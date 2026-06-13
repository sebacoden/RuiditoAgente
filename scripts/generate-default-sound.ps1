<#
.SYNOPSIS
    Genera el sonido de notificacion por defecto (sounds/notify.wav).

.DESCRIPTION
    Crea un WAV de 16 bits / mono / 44100 Hz con un acorde corto de dos tonos
    y una envolvente suave. No depende de archivos externos: es totalmente
    reproducible. Ejecutalo solo si queres regenerar el sonido por defecto.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts/generate-default-sound.ps1
#>

$ErrorActionPreference = 'Stop'

$sampleRate = 44100
$outPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'sounds\notify.wav'

# Cada tono: frecuencia (Hz) y duracion (segundos)
$tones = @(
    @{ Freq = 880.0;  Dur = 0.12 },   # La5
    @{ Freq = 1174.7; Dur = 0.16 }    # Re6
)

$samples = New-Object System.Collections.Generic.List[int16]

foreach ($tone in $tones) {
    $n = [int]($sampleRate * $tone.Dur)
    for ($i = 0; $i -lt $n; $i++) {
        $t = $i / $sampleRate
        # Envolvente: ataque rapido + caida exponencial para que suene a "campana"
        $env = [Math]::Min(1.0, $i / ($sampleRate * 0.01)) * [Math]::Exp(-3.5 * ($i / $n))
        $value = [Math]::Sin(2 * [Math]::PI * $tone.Freq * $t) * $env * 0.6
        $samples.Add([int16]([Math]::Round($value * 32767)))
    }
}

$dataSize = $samples.Count * 2
$ms = New-Object System.IO.MemoryStream
$bw = New-Object System.IO.BinaryWriter($ms)

# --- Cabecera RIFF/WAVE ---
$bw.Write([System.Text.Encoding]::ASCII.GetBytes('RIFF'))
$bw.Write([uint32](36 + $dataSize))
$bw.Write([System.Text.Encoding]::ASCII.GetBytes('WAVE'))
# --- Sub-chunk fmt ---
$bw.Write([System.Text.Encoding]::ASCII.GetBytes('fmt '))
$bw.Write([uint32]16)            # tamano del sub-chunk
$bw.Write([uint16]1)             # PCM
$bw.Write([uint16]1)             # mono
$bw.Write([uint32]$sampleRate)
$bw.Write([uint32]($sampleRate * 2))  # byte rate
$bw.Write([uint16]2)             # block align
$bw.Write([uint16]16)            # bits por muestra
# --- Sub-chunk data ---
$bw.Write([System.Text.Encoding]::ASCII.GetBytes('data'))
$bw.Write([uint32]$dataSize)
foreach ($s in $samples) { $bw.Write($s) }

[System.IO.File]::WriteAllBytes($outPath, $ms.ToArray())
$bw.Dispose()
$ms.Dispose()

Write-Host "Sonido generado: $outPath ($dataSize bytes de audio)"
