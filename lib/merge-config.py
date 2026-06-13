#!/usr/bin/env python3
"""RuiditoAgentes - fusiona un valor dentro del archivo de configuracion de
cualquier agente, en formato json, toml o yaml. Crea un backup .bak.

Permite tanto fijar una clave anidada como agregar a una lista, de modo que sirva
para agentes que usan "un comando de notificacion" (clave escalar) o "una lista
de hooks" (lista).

Uso:
    python3 merge-config.py --file <ruta> [--format json|toml|yaml] \
        (--set <ruta.de.clave>=<valor> | --append <ruta.de.lista>=<valor>)

  - El formato se deduce por extension si no se pasa --format.
  - <valor> se interpreta como JSON si es valido (numeros, true/false, objetos,
    listas); si no, se trata como texto.

Ejemplos:
    # Agente con un comando escalar de notificacion:
    python3 merge-config.py --file ~/.config/miagente/config.toml \
        --set notify.command='bash /ruta/RuiditoAgentes/core/notify.sh'

    # Agente con lista de hooks (estilo Claude Code):
    python3 merge-config.py --file ~/.claude/settings.json \
        --append hooks.Notification='{"matcher":"","hooks":[{"type":"command","command":"..."}]}'

Dependencias opcionales: toml -> tomli_w (escritura), yaml -> pyyaml.
"""
import argparse
import json
import os
import sys


def load(path, fmt):
    if not os.path.exists(path):
        return {}
    with open(path, "r", encoding="utf-8") as f:
        text = f.read().strip()
    if not text:
        return {}
    if fmt == "json":
        return json.loads(text)
    if fmt == "toml":
        try:
            import tomllib  # Python 3.11+
        except ModuleNotFoundError:
            try:
                import tomli as tomllib  # type: ignore
            except ModuleNotFoundError:
                sys.exit("Error: para TOML necesitas Python 3.11+ o 'pip install tomli'.")
        return tomllib.loads(text)
    if fmt == "yaml":
        try:
            import yaml  # type: ignore
        except ModuleNotFoundError:
            sys.exit("Error: para YAML necesitas 'pip install pyyaml'.")
        return yaml.safe_load(text) or {}
    sys.exit(f"Formato no soportado: {fmt}")


def dump(path, fmt, data):
    if fmt == "json":
        text = json.dumps(data, indent=2, ensure_ascii=False) + "\n"
    elif fmt == "toml":
        try:
            import tomli_w  # type: ignore
        except ModuleNotFoundError:
            sys.exit("Error: para escribir TOML necesitas 'pip install tomli_w'.")
        text = tomli_w.dumps(data)
    elif fmt == "yaml":
        import yaml  # type: ignore
        text = yaml.safe_dump(data, allow_unicode=True, sort_keys=False)
    else:
        sys.exit(f"Formato no soportado: {fmt}")
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)


def parse_value(raw):
    try:
        return json.loads(raw)
    except (ValueError, TypeError):
        return raw


def navigate(root, keys):
    """Devuelve el contenedor padre del ultimo segmento, creandolo si hace falta."""
    node = root
    for k in keys[:-1]:
        if k not in node or not isinstance(node[k], dict):
            node[k] = {}
        node = node[k]
    return node


def main():
    ap = argparse.ArgumentParser(description="Fusiona config de agentes (json/toml/yaml).")
    ap.add_argument("--file", required=True)
    ap.add_argument("--format", choices=["json", "toml", "yaml"])
    ap.add_argument("--set", dest="set_expr", help="ruta.de.clave=valor")
    ap.add_argument("--append", dest="append_expr", help="ruta.de.lista=valor")
    args = ap.parse_args()

    if bool(args.set_expr) == bool(args.append_expr):
        ap.error("usa exactamente uno: --set o --append")

    fmt = args.format
    if not fmt:
        ext = os.path.splitext(args.file)[1].lower().lstrip(".")
        fmt = {"yml": "yaml"}.get(ext, ext)

    data = load(args.file, fmt)
    if not isinstance(data, dict):
        sys.exit("La raiz del archivo de configuracion no es un objeto/mapa.")

    expr = args.set_expr or args.append_expr
    if "=" not in expr:
        ap.error("la expresion debe ser ruta.de.clave=valor")
    key_path, raw_value = expr.split("=", 1)
    value = parse_value(raw_value)
    keys = key_path.split(".")
    parent = navigate(data, keys)
    last = keys[-1]

    if args.set_expr:
        parent[last] = value
    else:  # append
        if last not in parent or not isinstance(parent[last], list):
            parent[last] = []
        # Evitar duplicados exactos
        if value not in parent[last]:
            parent[last].append(value)

    if os.path.exists(args.file):
        with open(args.file, "rb") as src, open(args.file + ".bak", "wb") as dst:
            dst.write(src.read())

    os.makedirs(os.path.dirname(os.path.abspath(args.file)), exist_ok=True)
    dump(args.file, fmt, data)
    print(f"OK: actualizado {args.file} (formato {fmt}).")


if __name__ == "__main__":
    main()
