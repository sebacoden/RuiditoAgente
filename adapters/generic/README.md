# Adaptador genérico (cualquier agente)

Sirve para conectar RuiditoAgentes a **cualquier agente** que pueda ejecutar un
comando de shell cuando necesita tu atención (pedir permiso, terminar una tarea,
etc.). Si tu agente no tiene un adaptador dedicado en [`../`](../), usá este.

## 1. Obtener el comando

Ejecutá el helper para tu sistema; imprime el comando exacto a pegar:

```powershell
# Windows
powershell -ExecutionPolicy Bypass -File adapters\generic\print-command.ps1
```

```bash
# macOS / Linux
bash adapters/generic/print-command.sh
```

Te va a mostrar algo como:

```
bash "/ruta/RuiditoAgentes/core/notify.sh" --message "Tu agente necesita tu atencion"
```

## 2. Conectarlo al agente

Pegá ese comando en el lugar donde tu agente ejecuta acciones ante notificaciones.
Cada agente lo llama distinto: *hooks*, *notify command*, *on-event*, *post-action*,
etc. Revisá la documentación de tu agente.

## 3. (Opcional) Fusión automática en el config del agente

Si conocés la clave de configuración de tu agente, podés insertar el comando sin
editar el archivo a mano. El helper soporta **json, toml y yaml**:

```bash
# Agente con un comando escalar de notificación
python3 lib/merge-config.py --file ~/.config/miagente/config.toml \
    --set notify.command='bash /ruta/RuiditoAgentes/core/notify.sh'

# Agente con una lista de hooks (estilo Claude Code)
python3 lib/merge-config.py --file ~/.config/miagente/settings.json \
    --append hooks.Notification='{"matcher":"","hooks":[{"type":"command","command":"bash /ruta/.../core/notify.sh"}]}'
```

- `--set ruta.de.clave=valor` fija una clave anidada.
- `--append ruta.de.lista=valor` agrega a una lista (la crea si no existe; evita duplicados).
- El valor se interpreta como JSON si es válido; si no, como texto.
- Crea un backup `.bak` antes de escribir.
- Dependencias opcionales: TOML necesita Python 3.11+ (o `tomli`/`tomli_w`); YAML necesita `pyyaml`.

## Personalización

Igual que con cualquier adaptador: cambiá el sonido reemplazando
`sounds/notify.wav` (cualquier formato) o configurá `config.json`. Ver el
[README principal](../../README.md).
