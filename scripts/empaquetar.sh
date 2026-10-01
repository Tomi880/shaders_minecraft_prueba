#!/usr/bin/env bash
# Valida y empaqueta el shaderpack en dist/<PACK_NAME>-v<VERSION>.zip, listo para subir a Drive
# y copiar a la carpeta shaderpacks de la instancia de Modrinth en el PC.
#
# Uso:
#   bash scripts/empaquetar.sh               # valida con glslang y empaqueta
#   bash scripts/empaquetar.sh --sin-validar # empaqueta sin validar (no recomendado)
#
# Variables opcionales:
#   PACK_NAME  nombre del pack en el zip (por defecto, el de abajo)
#   DRIVE_DIR  carpeta de Google Drive para escritorio; si existe, el zip se copia ahí
set -euo pipefail

RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
PACK_NAME="${PACK_NAME:-ShaderChocapic13Reborn}"
VERSION="$(tr -d '[:space:]' < "$RAIZ/VERSION")"
ZIP="$RAIZ/dist/${PACK_NAME}-v${VERSION}.zip"

if [ ! -f "$RAIZ/shaders/shaders.properties" ]; then
    echo "Falta shaders/shaders.properties: el pack todavía no existe." >&2
    exit 1
fi

if [ "${1:-}" != "--sin-validar" ]; then
    python3 "$RAIZ/scripts/validar_glsl.py"
fi

if [ -f "$ZIP" ]; then
    echo "Ya existe $ZIP. Sube la versión en VERSION antes de empaquetar de nuevo." >&2
    exit 1
fi

mkdir -p "$RAIZ/dist"
# Iris espera la carpeta shaders/ en la raíz del zip.
(cd "$RAIZ" && zip -r -X -q "$ZIP" shaders -x '*.DS_Store' -x '__MACOSX/*')
echo "Empaquetado: $ZIP"

if [ -n "${DRIVE_DIR:-}" ] && [ -d "$DRIVE_DIR" ]; then
    cp "$ZIP" "$DRIVE_DIR/"
    echo "Copiado a Drive: $DRIVE_DIR"
fi
