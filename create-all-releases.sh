#!/bin/bash

##############################################################################
# Script para generar ZIPs de todos los plugins
##############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CREATE_SCRIPT="$SCRIPT_DIR/create-plugin-release.sh"

echo "📦 Generando ZIPs de todos los plugins...\n"

# Array de plugins a procesar
PLUGINS=(
    "formularios-admin"
    "acf-forms-frontend-creator"
)

for plugin in "${PLUGINS[@]}"; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    "$CREATE_SCRIPT" "$plugin" || { echo "Error procesando $plugin"; exit 1; }
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Todos los ZIPs se han generado"
echo ""
echo "📁 Estructura de releases/"
tree "$SCRIPT_DIR/releases/" 2>/dev/null || find "$SCRIPT_DIR/releases/" -type f
echo ""
echo "ℹ️  Los ZIPs usan nombres simples para instalación correcta en WordPress:"
ls -lh "$SCRIPT_DIR/releases/"/*/*.zip 2>/dev/null
