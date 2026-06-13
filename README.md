# 🔔 RuiditoAgentes

Hace **ruido** (y muestra un aviso de texto) cada vez que tu **agente de IA** te
pide permiso o necesita tu atención. Así no tenés que estar mirando la terminal.

- 🔊 **Sonido multi-formato**: wav, mp3, ogg, flac, m4a… personalizable.
- 💬 **Notificación de texto** opcional (toast en Windows, `notify-send` en Linux, `osascript` en macOS).
- 🤖 **Cualquier agente**: núcleo reutilizable + adaptadores. Incluye adaptador automático para **Claude Code** y uno **genérico** para el resto.
- 🖥️ **Multiplataforma**: Windows, macOS y Linux.

---

## ¿Cómo funciona?

La mayoría de los agentes permiten ejecutar un comando ante ciertos eventos (pedir
permiso, terminar, etc.). RuiditoAgentes provee un **núcleo** (`core/notify`) que
reproduce el sonido y muestra el aviso, y **adaptadores** que conectan ese núcleo
al evento del agente que uses.

```
El agente necesita tu atención  ──▶  adaptador  ──▶  core/notify  ──▶  🔊 + 💬
```

---

## Instalación

Cloná el repo y corré el adaptador de tu agente.

```bash
git clone https://github.com/TU_USUARIO/RuiditoAgentes.git
cd RuiditoAgentes
```

### Claude Code

```powershell
# Windows
powershell -ExecutionPolicy Bypass -File adapters\claude-code\install.ps1
```

```bash
# macOS / Linux
bash adapters/claude-code/install.sh
```

Reiniciá Claude Code al terminar. El instalador **fusiona** tu `settings.json`
(respeta otros hooks) y crea un backup. Más detalles en
[adapters/claude-code/README.md](adapters/claude-code/README.md).

### Cualquier otro agente

Usá el adaptador genérico, que te imprime el comando exacto para pegar en tu agente
y puede fusionarlo en configs **json / toml / yaml**. Ver
[adapters/generic/README.md](adapters/generic/README.md).

```powershell
powershell -ExecutionPolicy Bypass -File adapters\generic\print-command.ps1   # Windows
```
```bash
bash adapters/generic/print-command.sh                                        # macOS / Linux
```

---

## Personalización

Hay dos formas, de la más simple a la más completa:

### 1. Cambiar solo el sonido
Reemplazá [`sounds/notify.wav`](sounds/notify.wav) por tu propio archivo. Soporta
**cualquier formato** (wav, mp3, ogg, flac, m4a…); si usás otro nombre/extensión,
indicá la ruta en `config.json` (abajo).

### 2. Config completa (`config.json`)
Copiá [`config.example.json`](config.example.json) como `config.json` en la raíz y editá:

```json
{
  "sound": "sounds/mi-sonido.mp3",
  "message": "Tu agente necesita tu atencion",
  "playSound": true,
  "showText": true
}
```

### 3. Variables de entorno (puntual, máxima prioridad)
`RUIDITO_SOUND`, `RUIDITO_MESSAGE`, `RUIDITO_NO_SOUND=1`, `RUIDITO_NO_TEXT=1`.

> **Precedencia:** argumentos del comando › variables de entorno › `config.json` › valores por defecto.

¿Querés volver al sonido por defecto? Regeneralo:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/generate-default-sound.ps1
```

---

## Probar sin un agente

```powershell
powershell -ExecutionPolicy Bypass -File core\notify.ps1 -Message "Prueba"   # Windows
```
```bash
bash core/notify.sh --message "Prueba"                                        # macOS / Linux
```

---

## Estructura del proyecto

```
RuiditoAgentes/
├── core/
│   ├── notify.ps1            Núcleo Windows (audio multi-formato + texto)
│   └── notify.sh             Núcleo macOS/Linux
├── adapters/
│   ├── claude-code/          Instalador automático para Claude Code
│   └── generic/              Comando + fusión de config para cualquier agente
├── lib/
│   └── merge-config.py       Fusiona el comando en config json/toml/yaml
├── sounds/
│   └── notify.wav            Sonido por defecto (reemplazable)
├── scripts/
│   └── generate-default-sound.ps1   Genera el WAV por defecto
├── config.example.json       Plantilla de configuración
└── examples/settings.json    Ejemplo de hook manual (Claude Code)
```

---

## Solución de problemas

| Problema | Solución |
|---|---|
| No suena nada | Reiniciá el agente. Verificá que la ruta del comando apunte a `core/notify`. |
| Windows bloquea el script | Usá `-ExecutionPolicy Bypass` (ya incluido en los adaptadores). |
| No reproduce mp3/ogg en Linux | Instalá `ffmpeg` (`ffplay`) o `mpg123`/`pulseaudio-utils`. |
| No aparece el texto en Linux | Instalá `libnotify-bin` (`notify-send`). |
| Quiero probar el sonido | Ver la sección "Probar sin un agente". |

---

## Contribuir

¡Bienvenidas las contribuciones! Lo más útil: **nuevos adaptadores** para otros
agentes (creá una carpeta en `adapters/`), más formatos de audio o mejores
notificaciones de texto.

## Licencia

[MIT](LICENSE). El sonido por defecto es obra original generada por código
(`scripts/generate-default-sound.ps1`), de uso libre.
