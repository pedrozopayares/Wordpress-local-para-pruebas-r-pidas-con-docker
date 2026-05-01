#!/bin/bash

##############################################################################
# Script para generar ZIPs de plugins listos para instalación en WordPress
#
# Uso:
#   ./create-plugin-release.sh /ruta/al/plugin
#   ./create-plugin-release.sh formularios-admin
#   ./create-plugin-release.sh acf-forms-frontend-creator
#
# Genera un ZIP con estructura correcta, sin carpeta contenedora extra
##############################################################################

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_error() {
    echo -e "${RED}❌ Error: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Validar argumentos
if [ $# -eq 0 ]; then
    print_error "Debes especificar la ruta del plugin"
    echo "Uso: $0 /ruta/al/plugin"
    echo "Ejemplos:"
    echo "  $0 /Users/pedrozopayares/Development/Impactos/wp-local/wp/wp-content/plugins/formularios-admin"
    echo "  $0 formularios-admin"
    exit 1
fi

PLUGIN_ARG="$1"

# Resolver ruta completa del plugin
if [[ "$PLUGIN_ARG" = /* ]]; then
    PLUGIN_PATH="$PLUGIN_ARG"
else
    PLUGIN_PATH="$(pwd)/wp/wp-content/plugins/$PLUGIN_ARG"
fi

# Validar que el directorio existe
if [ ! -d "$PLUGIN_PATH" ]; then
    print_error "El directorio del plugin no existe: $PLUGIN_PATH"
    exit 1
fi

# Obtener slug del plugin (nombre de la carpeta)
PLUGIN_SLUG=$(basename "$PLUGIN_PATH")

print_info "Plugin detectado: $PLUGIN_SLUG"

# Buscar el archivo PHP principal del plugin
PLUGIN_FILE=$(find "$PLUGIN_PATH" -maxdepth 1 -name "*.php" -type f | head -1)

if [ -z "$PLUGIN_FILE" ]; then
    print_error "No se encontró archivo PHP principal en $PLUGIN_PATH"
    exit 1
fi

# Extraer versión del plugin
VERSION=$(grep -m 1 "Version:" "$PLUGIN_FILE" | sed 's/.*Version:[ \t]*\([^ \t]*\).*/\1/')

if [ -z "$VERSION" ]; then
    print_error "No se encontró versión en $PLUGIN_FILE"
    exit 1
fi

print_info "Versión detectada: $VERSION"

# Crear directorios de releases si no existen
RELEASES_DIR="$(pwd)/releases"
VERSION_DIR="$RELEASES_DIR/v${VERSION}"
mkdir -p "$VERSION_DIR"

# Nombre del archivo ZIP (sin versión en el nombre para evitar confusión)
# Se guarda en releases/v{VERSION}/ para mantener histórico
ZIP_NAME="${PLUGIN_SLUG}.zip"
ZIP_PATH="$VERSION_DIR/$ZIP_NAME"

print_info "Generando ZIP: $ZIP_NAME"

# Crear directorio temporal
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

# Copiar plugin al directorio temporal con el slug correcto
cp -r "$PLUGIN_PATH" "$TMP_DIR/$PLUGIN_SLUG"

# Remover archivos/directorios innecesarios del ZIP
EXCLUDE_PATTERNS=(
    ".git"
    ".gitignore"
    ".DS_Store"
    "*.log"
    "Thumbs.db"
    "node_modules"
    "vendor"
    ".idea"
    ".vscode"
    "*.swp"
    "*.swo"
    "package-lock.json"
    "composer.lock"
    ".env"
    ".env.local"
    ".editorconfig"
    "phpcbf.cache"
    ".phpunit.result.cache"
)

# Crear archivo .zip excluyendo los patrones
cd "$TMP_DIR"

# Usar zip con -x para excluir patrones específicos
zip -r -q "$ZIP_PATH" "$PLUGIN_SLUG" \
    -x "$PLUGIN_SLUG/.git/*" \
    -x "$PLUGIN_SLUG/.gitignore" \
    -x "$PLUGIN_SLUG/.DS_Store" \
    -x "$PLUGIN_SLUG/*.log" \
    -x "$PLUGIN_SLUG/Thumbs.db" \
    -x "$PLUGIN_SLUG/node_modules/*" \
    -x "$PLUGIN_SLUG/vendor/*" \
    -x "$PLUGIN_SLUG/.idea/*" \
    -x "$PLUGIN_SLUG/.vscode/*" \
    -x "$PLUGIN_SLUG/*.swp" \
    -x "$PLUGIN_SLUG/*.swo" \
    -x "$PLUGIN_SLUG/package-lock.json" \
    -x "$PLUGIN_SLUG/composer.lock" \
    -x "$PLUGIN_SLUG/.env" \
    -x "$PLUGIN_SLUG/.env.local" \
    -x "$PLUGIN_SLUG/.editorconfig" \
    -x "$PLUGIN_SLUG/phpcbf.cache" \
    -x "$PLUGIN_SLUG/.phpunit.result.cache"

cd - > /dev/null

# Verificar que el ZIP se creó
if [ ! -f "$ZIP_PATH" ]; then
    print_error "Error al crear el ZIP"
    exit 1
fi

# Obtener tamaño del archivo
SIZE=$(du -h "$ZIP_PATH" | cut -f1)

print_success "ZIP creado exitosamente"
echo ""
echo "📦 Detalles del release:"
echo "   Plugin:  $PLUGIN_SLUG"
echo "   Versión: $VERSION"
echo "   Archivo: $ZIP_NAME"
echo "   Ruta:    releases/v$VERSION/$ZIP_NAME"
echo "   Tamaño:  $SIZE"
echo ""
echo "⚠️  IMPORTANTE: Nombre del plugin al instalar será '$PLUGIN_SLUG'"
echo "   NO 'acf-forms-frontend-creator-1.7.0' o similar"
echo ""
echo "Para subir a GitHub, usa:"
echo "   gh release upload v$VERSION '$ZIP_PATH'"
echo ""
