# Prueba de Actualización de Plugins

Este documento explica cómo verificar que los ZIPs generados permiten actualizar correctamente los plugins en WordPress.

## Antes vs Después

### ❌ Problema Original (descargas de GitHub)

Cuando descargas un ZIP de GitHub:
1. Se crea con estructura: `formularios-admin-main/formularios-admin/`
2. Al extraer en `wp-content/plugins/`: se obtiene carpeta `formularios-admin-main/`
3. WordPress ve un plugin diferente (diferente slug)
4. ➜ Se instala como **plugin nuevo**, no como actualización

### ✅ Solución (ZIPs generados con nuestros scripts)

Con los ZIPs generados:
1. Se crea con estructura correcta: `formularios-admin/`
2. Al extraer en `wp-content/plugins/`: se obtiene carpeta `formularios-admin/`
3. WordPress reconoce el mismo slug
4. ➜ Se instala como **actualización** ✅

## Cómo Probar Localmente

### 1. Simular Descarga e Instalación

```bash
# Ir a wp-content/plugins
cd wp/wp-content/plugins

# Respaldar el plugin actual (por si acaso)
cp -r formularios-admin formularios-admin-backup

# Simular lo que hace WordPress al extraer el ZIP
unzip -q ../../releases/formularios-admin-v1.4.0.zip

# Verificar la estructura
ls -la | grep formularios-admin
# Debe mostrar:
# drwxr-xr-x  10 user  staff  320 May  1 14:05 formularios-admin
# (Una sola carpeta con el nombre correcto)
```

### 2. Verificar en WordPress Admin

Después de extraer:

1. **Panel de control** → **Plugins**
2. Busca "Formularios Admin"
3. Debería mostrar: **"Ya tienes la versión 1.4.0"** (o más reciente si existe)
4. NO debería mostrar dos versiones del mismo plugin

### 3. Verificar Integridad de Versión

```bash
# Extraer y verificar la versión en el archivo
unzip -p ./releases/formularios-admin-v1.4.0.zip \
  formularios-admin/formularios-admin.php | grep "Version:" | head -1

# Debe mostrar:
# * Version: 1.4.0
```

### 4. Comparar con Plugin Instalado

```bash
# Plugin actual (instalado)
grep "Version:" wp/wp-content/plugins/formularios-admin/formularios-admin.php

# Debería ser idéntica a la del ZIP para probar actualización en el mismo sitio
```

## Cuándo Ocurre la Actualización Automática

WordPress actualiza un plugin cuando:

1. ✅ El **slug es idéntico** (carpeta con mismo nombre)
2. ✅ El **archivo principal es idéntico** (mismo nombre .php)
3. ✅ La **versión en header es mayor** (ej: 1.4.0 → 1.5.0)
4. ✅ El **Plugin Name es idéntico** (mismo nombre en cabecera)

Ejemplo:

```php
<?php
/**
 * Plugin Name: Formularios Admin
 * Version: 1.4.0
 */
```

Si cambias cualquiera de estos campos, WordPress lo considerará un plugin diferente.

## Instalación Limpia vs Actualización

### Instalación Limpia (Primera vez)
```
1. Usuario descarga formularios-admin-v1.4.0.zip
2. Extrae en wp-content/plugins/
3. WordPress detecta nuevo plugin
4. Instala y activa
5. Se ejecutan hooks de activación
```

### Actualización (Plugin ya existe)
```
1. Usuario descarga formularios-admin-v1.4.1.zip (versión mayor)
2. Extrae en wp-content/plugins/ (reemplaza archivos)
3. WordPress detecta es el mismo plugin (slug + nombre)
4. Ejecuta actualización (si hay código de migración)
5. Preserva TODA la configuración guardada en BD
6. Se ejecutan hooks de actualización (update_option, etc.)
```

## Verificar Preservación de Datos

Importante: La configuración se preserva en:

```
wp_options (Base de datos)
- eff_settings (ACF Forms Frontend Creator)
- formularios_admin_settings (Formularios Admin)
- Otros postmeta, usermeta, etc.
```

Al actualizar un plugin:
```bash
# Estructura de carpetas cambia
/formularios-admin-old/ → /formularios-admin/

# Pero la base de datos NO se afecta
wp_options.option_name = 'formularios_admin_settings'
wp_options.option_value = '...' # SIN CAMBIOS
```

## Pasos Para Producción

1. Aumentar versión en archivo PHP principal
2. Hacer commit: `git commit -m "Bump version to X.Y.Z"`
3. Crear tag: `git tag vX.Y.Z`
4. Hacer push: `git push && git push --tags`
5. Ejecutar: `./create-plugin-release.sh plugin-slug`
6. Subir ZIP a GitHub release

## Simulación Completa

```bash
#!/bin/bash

# 1. Generar nuevo ZIP
./create-plugin-release.sh formularios-admin

# 2. Respaldar versión actual
cp -r wp/wp-content/plugins/formularios-admin \
      wp/wp-content/plugins/formularios-admin-v1.3.9

# 3. Extraer nuevo ZIP (simula descarga + instalación)
unzip -q releases/formularios-admin-v*.zip -d wp/wp-content/plugins/

# 4. Verificar en WordPress
echo "Abre WordPress en navegador y revisa:"
echo "Plugins → Formularios Admin"
echo "Debería mostrar que está actualizado a la nueva versión"

# 5. Si todo va bien, puedes eliminar el backup
# rm -rf wp/wp-content/plugins/formularios-admin-v1.3.9
```

## Troubleshooting

### Plugin aparece como "nuevo" en lugar de "actualización"

**Causa:** El slug cambió

```bash
# Verifica qué carpeta se creó
ls wp/wp-content/plugins | grep formularios

# Si ves "formularios-admin-vX.X.X", eso es el problema
# Debe ser solo "formularios-admin"
```

### Datos se perdieron después de actualizar

**Causa:** No debería ocurrir si usas `get_option()` correctamente

```php
// ✅ Correcto - los datos se preservan
$settings = get_option('formularios_admin_settings');

// ❌ Incorrecto - podrías perder datos
delete_option('formularios_admin_settings');
```

### Mensajes de error after actualizar

**Solución:** WordPress debería ejecutar código de migración:

```php
// En el archivo principal del plugin
add_action('plugins_loaded', function() {
    $current_version = get_option('plugin_version');
    if ($current_version !== EFF_VERSION) {
        // Ejecutar migraciones necesarias
        // ...
        update_option('plugin_version', EFF_VERSION);
    }
});
```

## Conclusión

Los ZIPs generados con `./create-plugin-release.sh`:
- ✅ Permiten actualizaciones sin perder datos
- ✅ Tienen estructura correcta para WordPress
- ✅ Excluyen archivos innecesarios
- ✅ Son pequeños y eficientes
- ✅ Funcionan idéntico a plugins de WordPress.org
