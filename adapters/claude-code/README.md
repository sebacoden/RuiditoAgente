# Adaptador para Claude Code

Conecta RuiditoAgentes al evento **`Notification`** de Claude Code (se dispara
cuando Claude pide permiso para una herramienta o queda esperando tu input).

## Instalar

```powershell
# Windows
powershell -ExecutionPolicy Bypass -File adapters\claude-code\install.ps1
```

```bash
# macOS / Linux
bash adapters/claude-code/install.sh
```

El instalador:
- Agrega el hook a `~/.claude/settings.json`.
- **Fusiona** la config: respeta cualquier otro hook que ya tengas.
- Crea un backup `settings.json.bak` antes de tocar nada.
- Es idempotente: ejecutarlo dos veces no duplica el hook.

Reiniciá Claude Code después de instalar.

## Desinstalar

```powershell
powershell -ExecutionPolicy Bypass -File adapters\claude-code\uninstall.ps1   # Windows
```

```bash
bash adapters/claude-code/uninstall.sh                                        # macOS / Linux
```

Quita solo el hook de RuiditoAgentes; el resto de tu configuración queda intacto.

## Ruta de settings alternativa

Ambos scripts aceptan una ruta distinta de `settings.json` como argumento, útil
para probar o para configuraciones por proyecto (`.claude/settings.json`):

```bash
bash adapters/claude-code/install.sh /ruta/a/settings.json
```
