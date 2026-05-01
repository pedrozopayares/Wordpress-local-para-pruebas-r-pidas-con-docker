# Guía de Generación de Releases para Plugins

## Problema Resuelto

Cuando WordPress instala un plugin, lo identifica por su **slug** (nombre de la carpeta). Si descargas un ZIP desde GitHub y la estructura es incorrecta, WordPress lo trata como un plugin completamente nuevo en lugar de una actualización.

**Problemas comunes:**
- GitHub genera ZIPs con carpeta contenedora: `formularios-admin-main/` en lugar de `formularios-admin/`
- Archivos de desarrollo innecesarios (`.git`, `.gitignore`, `node_modules`, etc.) inflaban el tamaño
- WordPress no reconocía la versión anterior como actualizable

## Solución

Estos scripts generan ZIPs con estructura correcta, listos para instalar/actualizar en WordPress.

## Uso

### Opción 1: Generar ZIPs de ambos plugins a la vez

```bash
./create-all-releases.sh
```

Genera (organizado por versión):
- `releases/v1.4.0/formularios-admin.zip`
- `releases/v1.7.0/acf-forms-frontend-creator.zip`

### Opción 2: Generar ZIP de un plugin específico

```bash
./create-plugin-release.sh formularios-admin
./create-plugin-release.sh acf-forms-frontend-creator
```

O con ruta completa:

```bash
./create-plugin-release.sh /Users/pedrozopayares/Development/Impactos/wp-local/wp/wp-content/plugins/formularios-admin
```

## Características de los ZIPs Generados

✅ **Nombres simples** - `{plugin-slug}.zip` (sin versión en el nombre)
  - Evita confusiones en descompresores
  - WordPress instala con el nombre correcto

✅ **Estructura correcta** - Al extraer en `wp-content/plugins/`, crea:
  - `wp-content/plugins/{plugin-slug}/` ✅ Correcto
  - NO `wp-content/plugins/{plugin-slug}-{version}/` ❌

✅ **Sin archivos de desarrollo** - Excluye:
  - `.git/` (historial de Git)
  - `.gitignore`
  - `node_modules/`, `vendor/`
  - Archivos de editor (`.vscode/`, `.idea/`)
  - Archivos de log, caché, etc.

✅ **Tamaño optimizado** - Típicamente 60-80% más pequeño que descargas de GitHub

✅ **Compatible con WordPress** - Reconoce automáticamente como actualización cuando:
  1. El slug es idéntico al plugin instalado (`formularios-admin`, NOT `formularios-admin-1.4.0`)
  2. La versión es mayor a la instalada

## Flujo de Actualización en WordPress

1. Usuario descarga el ZIP de tu GitHub release
2. En WordPress: Plugins → Añadir nuevo → Subir plugin
3. Selecciona el ZIP y lo instala
4. Si es un plugin actual, WordPress lo detecta como actualización
5. Todos los datos y configuración se preservan

## Integración con GitHub Releases

Después de generar los ZIPs, puedes subirlos a un release de GitHub:

```bash
# Crear release y subir ZIP de formularios-admin
gh release create v1.4.0 releases/formularios-admin-v1.4.0.zip

# O agregar a un release existente
gh release upload v1.4.0 releases/formularios-admin-v1.4.0.zip
```

## Automatización Futura (Opcional)

Puedes configurar GitHub Actions para que estos scripts se ejecuten automáticamente en cada push a una rama de release, generando y subiendo los ZIPs sin intervención manual.

## Archivos Excluidos del ZIP

```
.git/                    # Historial de Git
.gitignore              # Archivo de configuración de Git
.DS_Store               # Archivos del sistema macOS
*.log                   # Archivos de log
Thumbs.db               # Archivos del sistema Windows
node_modules/           # Dependencias de Node.js
vendor/                 # Dependencias de Composer
.idea/                  # Configuración de IntelliJ
.vscode/                # Configuración de VS Code
*.swp, *.swo            # Archivos temporales de Vim
package-lock.json       # Lock file de npm
composer.lock           # Lock file de Composer
.env, .env.local        # Archivos de configuración sensitiva
.editorconfig           # Configuración de editor
*.cache                 # Archivos de caché
```

## Estructura del ZIP Final

**Nombre del archivo:** `formularios-admin.zip` (sin versión)
**Ubicación:** `releases/v1.4.0/formularios-admin.zip`

```
formularios-admin.zip
└── formularios-admin/
    ├── includes/
    │   ├── class-user-notification-settings.php
    │   ├── class-user-notification-helper.php
    │   └── ... (otros archivos)
    ├── assets/
    │   ├── css/
    │   └── js/
    ├── formularios/
    │   └── ... (archivos de formularios)
    ├── formularios-admin.php (archivo principal)
    └── README.md
```

Al extraer en `wp-content/plugins/`:
```
wp-content/plugins/
├── formularios-admin/          ✅ Correcto
│   ├── includes/
│   ├── assets/
│   └── formularios-admin.php
└── ... (otros plugins)
```

## Verificación del ZIP

Para verificar la estructura sin extraer:

```bash
# Listar contenido del ZIP
unzip -l releases/v1.4.0/formularios-admin.zip | head -20

# Verificar que la carpeta principal es correcta
unzip -l releases/v1.4.0/formularios-admin.zip | grep "formularios-admin/"
# Debe mostrar: 0  formularios-admin/

# Verificar que no contiene .git
unzip -l releases/v1.4.0/formularios-admin.zip | grep -i "\.git"
# (No debe mostrar resultados)

# Verificar que no tiene versión en el nombre de la carpeta
unzip -l releases/v1.4.0/formularios-admin.zip | grep "formularios-admin-1\."
# (No debe mostrar resultados)
```

## Notas Importantes

- Los scripts leen automáticamente la versión del archivo PHP principal del plugin
- El ZIP siempre se nombra con el patrón: `{plugin-slug}-v{version}.zip`
- Los ZIPs se guardan en el directorio `releases/` (se crea automáticamente)
- Los scripts son agnósticos del plugin - funcionan con cualquier plugin WordPress

## Troubleshooting

### El ZIP aún contiene `.git/`

Asegúrate de que tienes `zip` instalado:

```bash
which zip
# Si no está instalado:
# macOS: brew install zip
# Linux: sudo apt-get install zip
```

### El tamaño del ZIP es muy grande

Verifica si hay directorios grandes no deseados:

```bash
unzip -l releases/formularios-admin-v1.4.0.zip | sort -k4 -nr | head -20
```

Si encuentras directorios grandes, agrégalos a `EXCLUDE_PATTERNS` en el script.

### WordPress no reconoce la actualización

1. Verifica que el slug en la carpeta sea idéntico al actual
2. Comprueba que la versión en el archivo PHP es mayor
3. Desactiva el plugin antes de actualizar (recomendado)

## Contacto

Si hay problemas con los scripts, verifica:
- Que tienes permisos de lectura en los directorios de plugins
- Que la versión está correctamente especificada en el archivo PHP principal
- Que tienes `zip` instalado en tu sistema
