#!/bin/bash
# Don't use set -e so individual non-critical failures don't stop the whole script

WP_PATH="/var/www/html"
WP="wp --path=${WP_PATH} --allow-root"

# ── Configuración ──────────────────────────────────────────
SITE_URL="http://localhost:8080"
SITE_TITLE="Impactos Local Dev"
ADMIN_USER="admin"
ADMIN_PASS="admin"
ADMIN_EMAIL="admin@test.com"
LOCALE="es_ES"

# ── Esperar a que la base de datos esté lista ──────────────
echo "⏳ Esperando a que la base de datos esté lista..."
MAX_TRIES=30
COUNT=0
until $WP db check 2>/dev/null; do
  COUNT=$((COUNT+1))
  if [ $COUNT -ge $MAX_TRIES ]; then
    echo "❌ No se pudo conectar a la base de datos después de ${MAX_TRIES} intentos"
    exit 1
  fi
  echo "  Intento ${COUNT}/${MAX_TRIES}..."
  sleep 3
done
echo "✅ Base de datos lista"

# ── Crear wp-config.php si no existe ──────────────────────
if [ ! -f "${WP_PATH}/wp-config.php" ]; then
  echo "📝 Creando wp-config.php..."
  $WP config create \
    --dbname=wordpress \
    --dbuser=wp \
    --dbpass=wp \
    --dbhost=db:3306 \
    --locale=${LOCALE}
fi

# ── Instalar WordPress si no está instalado ───────────────
if ! $WP core is-installed 2>/dev/null; then
  echo "🚀 Instalando WordPress..."
  $WP core install \
    --url="${SITE_URL}" \
    --title="${SITE_TITLE}" \
    --admin_user="${ADMIN_USER}" \
    --admin_password="${ADMIN_PASS}" \
    --admin_email="${ADMIN_EMAIL}" \
    --locale="${LOCALE}"
else
  echo "✅ WordPress ya está instalado"
fi

# ── Configurar idioma ─────────────────────────────────────
echo "🌐 Configurando idioma ${LOCALE}..."
$WP language core install ${LOCALE} || true
$WP site switch-language ${LOCALE} || true

# ── Configuración general del sitio ───────────────────────
echo "⚙️  Configurando ajustes del sitio..."
$WP option update blogname "${SITE_TITLE}"
$WP option update blogdescription "Entorno local de pruebas"
$WP option update timezone_string "America/Bogota"
$WP option update date_format "d/m/Y"
$WP option update time_format "H:i"
$WP option update start_of_week 1

# Permalinks bonitos
$WP rewrite structure '/%postname%/'
$WP rewrite flush

# Desactivar que los motores de búsqueda indexen
$WP option update blog_public 0

# ── Instalar y activar plugins ────────────────────────────
echo "🔌 Instalando plugins..."

# WooCommerce
if ! $WP plugin is-installed woocommerce; then
  echo "  📦 Instalando WooCommerce..."
  $WP plugin install woocommerce --activate
else
  echo "  ✅ WooCommerce ya instalado"
  $WP plugin activate woocommerce || true
fi

# Elementor
if ! $WP plugin is-installed elementor; then
  echo "  📦 Instalando Elementor..."
  $WP plugin install elementor --activate
else
  echo "  ✅ Elementor ya instalado"
  $WP plugin activate elementor || true
fi

# WordPress Importer (útil para importar contenido demo)
if ! $WP plugin is-installed wordpress-importer; then
  echo "  📦 Instalando WordPress Importer..."
  $WP plugin install wordpress-importer --activate
else
  $WP plugin activate wordpress-importer || true
fi

# WP Mail SMTP (para conectar con MailHog)
if ! $WP plugin is-installed wp-mail-smtp; then
  echo "  📦 Instalando WP Mail SMTP..."
  $WP plugin install wp-mail-smtp --activate
else
  $WP plugin activate wp-mail-smtp || true
fi

# Query Monitor (debugging)
if ! $WP plugin is-installed query-monitor; then
  echo "  📦 Instalando Query Monitor..."
  $WP plugin install query-monitor --activate
else
  $WP plugin activate query-monitor || true
fi

# Eliminar plugins por defecto que no se usan
$WP plugin delete akismet --quiet 2>/dev/null || true
$WP plugin delete hello --quiet 2>/dev/null || true

# ── Instalar tema ────────────────────────────────────────
echo "🎨 Configurando tema..."
if ! $WP theme is-installed hello-elementor; then
  echo "  📦 Instalando tema Hello Elementor..."
  $WP theme install hello-elementor --activate
else
  $WP theme activate hello-elementor || true
fi

# ── Configurar WooCommerce ────────────────────────────────
echo "🛒 Configurando WooCommerce..."

# Páginas de WooCommerce (se crean automáticamente al activar, pero por si acaso)
$WP option update woocommerce_store_address "Calle Test 123"
$WP option update woocommerce_store_city "Bogotá"
$WP option update woocommerce_default_country "CO"
$WP option update woocommerce_store_postcode "110111"
$WP option update woocommerce_currency "COP"
$WP option update woocommerce_currency_pos "left_space"
$WP option update woocommerce_price_thousand_sep "."
$WP option update woocommerce_price_decimal_sep ","
$WP option update woocommerce_price_num_decimals 0
$WP option update woocommerce_weight_unit "kg"
$WP option update woocommerce_dimension_unit "cm"
$WP option update woocommerce_calc_taxes "yes"
$WP option update woocommerce_enable_signup_and_login_from_checkout "yes"
$WP option update woocommerce_enable_checkout_login_reminder "yes"
$WP option update woocommerce_onboarding_profile '{"skipped":true}' --format=json

# Crear páginas de WooCommerce si no existen
$WP wc --user=admin tool run install_pages 2>/dev/null || true

# ── Crear productos de prueba ─────────────────────────────
echo "📦 Creando productos de prueba..."

PRODUCT_COUNT=$($WP post list --post_type=product --format=count 2>/dev/null || echo "0")
if [ "$PRODUCT_COUNT" -eq "0" ]; then
  $WP wc product create --user=admin --name="Producto Test 1" --type=simple --regular_price="50000" --description="Producto de prueba número 1" --short_description="Producto test" --status=publish 2>/dev/null || true
  $WP wc product create --user=admin --name="Producto Test 2" --type=simple --regular_price="120000" --sale_price="99000" --description="Producto de prueba número 2 con descuento" --short_description="Producto en oferta" --status=publish 2>/dev/null || true
  $WP wc product create --user=admin --name="Producto Test 3" --type=simple --regular_price="35000" --description="Producto de prueba número 3" --short_description="Producto económico" --status=publish 2>/dev/null || true
  echo "  ✅ 3 productos de prueba creados"
else
  echo "  ✅ Ya existen ${PRODUCT_COUNT} productos"
fi

# ── Crear páginas básicas ─────────────────────────────────
echo "📄 Creando páginas básicas..."

if ! $WP post list --post_type=page --name=contacto --format=count | grep -q "1"; then
  $WP post create --post_type=page --post_title="Contacto" --post_name="contacto" --post_status=publish --post_content="Página de contacto de prueba."
fi

if ! $WP post list --post_type=page --name=nosotros --format=count | grep -q "1"; then
  $WP post create --post_type=page --post_title="Nosotros" --post_name="nosotros" --post_status=publish --post_content="Página sobre nosotros de prueba."
fi

# Configurar página de inicio estática
SHOP_PAGE_ID=$($WP option get woocommerce_shop_page_id 2>/dev/null || echo "0")
BLOG_PAGE_EXISTS=$($WP post list --post_type=page --name=blog --format=count 2>/dev/null || echo "0")
if [ "$BLOG_PAGE_EXISTS" -eq "0" ]; then
  BLOG_PAGE_ID=$($WP post create --post_type=page --post_title="Blog" --post_name="blog" --post_status=publish --porcelain)
else
  BLOG_PAGE_ID=$($WP post list --post_type=page --name=blog --field=ID 2>/dev/null || echo "0")
fi

$WP option update show_on_front "page"
$WP option update page_for_posts "${BLOG_PAGE_ID}"

# Intentar poner la tienda como página de inicio
if [ "$SHOP_PAGE_ID" != "0" ] && [ -n "$SHOP_PAGE_ID" ]; then
  $WP option update page_on_front "${SHOP_PAGE_ID}"
fi

# ── Configurar email con MailHog ──────────────────────────
echo "📧 Configurando email con MailHog..."
$WP option update wp_mail_smtp --format=json '{
  "mail": {
    "from_email": "admin@test.com",
    "from_name": "Impactos Local Dev",
    "mailer": "smtp",
    "return_path": true
  },
  "smtp": {
    "host": "mailhog",
    "port": 1025,
    "encryption": "none",
    "autotls": false,
    "auth": false,
    "user": "",
    "pass": ""
  }
}' 2>/dev/null || true

# ── Habilitar modo debug ─────────────────────────────────
echo "🐛 Habilitando modo debug..."
$WP config set WP_DEBUG true --raw --type=constant 2>/dev/null || true
$WP config set WP_DEBUG_LOG true --raw --type=constant 2>/dev/null || true
$WP config set WP_DEBUG_DISPLAY false --raw --type=constant 2>/dev/null || true
$WP config set SCRIPT_DEBUG true --raw --type=constant 2>/dev/null || true

# ── Limpiar ──────────────────────────────────────────────
echo "🧹 Limpiando..."
$WP cache flush 2>/dev/null || true
$WP transient delete --all 2>/dev/null || true
$WP cron event run --due-now 2>/dev/null || true

echo ""
echo "════════════════════════════════════════════════════════"
echo "  ✅ ¡WordPress listo para pruebas!"
echo "════════════════════════════════════════════════════════"
echo ""
echo "  🌐 Sitio:       ${SITE_URL}"
echo "  👤 Admin:       ${SITE_URL}/wp-admin"
echo "  📧 MailHog:     http://localhost:8025"
echo "  🗃️  phpMyAdmin:  http://localhost:8081"
echo ""
echo "  Usuario: ${ADMIN_USER}"
echo "  Clave:   ${ADMIN_PASS}"
echo ""
echo "  Plugins: WooCommerce, Elementor, Query Monitor,"
echo "           WP Mail SMTP, WordPress Importer"
echo ""
echo "════════════════════════════════════════════════════════"
