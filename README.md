# WP Local Dev — Impactos

Entorno local de WordPress con Docker, preconfigurado y listo para pruebas. Con un solo comando tendrás WordPress + WooCommerce + Elementor funcionando.

## Requisitos

- [Docker](https://docs.docker.com/get-docker/) y Docker Compose v2+

## Inicio rápido

```bash
docker compose up -d
```

Espera ~90 segundos mientras el contenedor `wp_setup` instala y configura todo automáticamente. Puedes seguir el progreso con:

```bash
docker compose logs -f wpcli
```

Cuando aparezca `✅ ¡WordPress listo para pruebas!`, todo estará listo.

## URLs

| Servicio     | URL                          |
| ------------ | ---------------------------- |
| WordPress    | http://localhost:8080        |
| WP Admin     | http://localhost:8080/wp-admin |
| phpMyAdmin   | http://localhost:8081        |
| MailHog      | http://localhost:8025        |

## Credenciales

| Recurso        | Usuario | Contraseña |
| -------------- | ------- | ---------- |
| WordPress Admin | `admin` | `admin`    |
| Base de datos   | `wp`    | `wp`       |
| phpMyAdmin (root) | `root` | `root`   |

## ¿Qué se instala automáticamente?

### Plugins

- **WooCommerce** — Tienda configurada con moneda COP, dirección en Bogotá, 3 productos de prueba
- **Elementor** — Constructor visual de páginas
- **Hello Elementor** — Tema ligero compatible con Elementor
- **Query Monitor** — Panel de debugging para desarrollo
- **WP Mail SMTP** — Configurado para enviar emails a MailHog
- **WordPress Importer** — Para importar contenido demo

### Configuración del sitio

- Idioma: Español (es_ES)
- Zona horaria: America/Bogota
- Permalinks: `/%postname%/`
- Formato de fecha: `d/m/Y`
- Debug: `WP_DEBUG`, `WP_DEBUG_LOG` y `SCRIPT_DEBUG` habilitados
- Indexación por buscadores: desactivada

### WooCommerce

- Moneda: COP (Pesos Colombianos) sin decimales
- País: Colombia
- Separador de miles: `.` | Separador decimal: `,`
- Impuestos habilitados
- 3 productos de prueba creados
- Páginas de tienda (Carrito, Checkout, Mi Cuenta) generadas

### Páginas

- Tienda (página de inicio)
- Blog
- Contacto
- Nosotros
- + páginas de WooCommerce

## Servicios Docker

| Contenedor  | Imagen               | Descripción                       |
| ----------- | -------------------- | --------------------------------- |
| `wp_db`     | mariadb:11.8         | Base de datos MariaDB             |
| `wp_app`    | wordpress:latest     | Servidor WordPress (Apache + PHP) |
| `wp_setup`  | wordpress:cli        | Inicialización automática con WP-CLI |
| `wp_pma`    | phpmyadmin:latest    | Administrador de base de datos    |
| `wp_mail`   | mailhog/mailhog      | Servidor SMTP de prueba           |

## Comandos útiles

```bash
# Iniciar todo
docker compose up -d

# Ver logs del setup
docker compose logs -f wpcli

# Parar todo (mantiene datos)
docker compose down

# Destruir todo y empezar desde cero
docker compose down -v && docker compose up -d

# Ejecutar WP-CLI manualmente
docker compose run --rm wpcli wp plugin list --allow-root

# Ver logs de WordPress
docker compose logs -f wordpress

# Acceder al contenedor de WordPress
docker exec -it wp_app bash
```

## Estructura del proyecto

```
├── docker-compose.yml   # Definición de servicios Docker
├── setup.sh             # Script de inicialización automática
├── wp/                  # Archivos de WordPress (montado como volumen)
└── README.md
```

> **Nota:** La carpeta `wp/` se genera automáticamente y debería estar en `.gitignore`.

## Personalización

Edita las variables al inicio de `setup.sh` para cambiar la configuración:

```bash
SITE_URL="http://localhost:8080"
SITE_TITLE="Impactos Local Dev"
ADMIN_USER="admin"
ADMIN_PASS="admin"
ADMIN_EMAIL="admin@test.com"
LOCALE="es_ES"
```

Para agregar más plugins, añade bloques en la sección de plugins de `setup.sh`:

```bash
if ! $WP plugin is-installed mi-plugin; then
  $WP plugin install mi-plugin --activate
else
  $WP plugin activate mi-plugin || true
fi
```
