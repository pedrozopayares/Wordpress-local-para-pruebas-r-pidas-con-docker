# Corrección de Nombres de Plugins en Producción

## Problema Encontrado

En tu ambiente de producción, los plugins están instalados con nombres incorrectos:

- ❌ `acf-forms-frontend-creator-1.7.0` → debe ser `acf-forms-frontend-creator`
- ❌ `formularios-admin-1.4.0` → debe ser `formularios-admin`

Esto impide que WordPress reconozca las actualizaciones correctamente.

## Causa

Los ZIPs generados anteriormente usaban el patrón:
```
{plugin-slug}-v{version}.zip
```

Al extraer, algunos sistemas creaban la carpeta con el nombre completo del ZIP.

## Solución

### Paso 1: Acceder al servidor de producción

Conectate via SSH o acceso directo a los archivos:

```bash
cd /ruta/a/wp-content/plugins/
```

### Paso 2: Renombrar las carpetas existentes

**Opción A: Renombrar (Recomendado - mantiene toda la configuración)**

```bash
# Para formularios-admin
mv formularios-admin-1.4.0 formularios-admin

# Para acf-forms-frontend-creator
mv acf-forms-frontend-creator-1.7.0 acf-forms-frontend-creator
```

**Opción B: Backup + Desactivar (Si no tienes acceso SSH)**

1. Ve a **Plugins** en WordPress Admin
2. **Desactiva** ambos plugins:
   - `acf-forms-frontend-creator-1.7.0`
   - `formularios-admin-1.4.0`
3. **Elimina** ambos plugins (esto eliminará las carpetas)
4. Descarga los nuevos ZIPs desde:
   - `releases/v1.4.0/formularios-admin.zip`
   - `releases/v1.7.0/acf-forms-frontend-creator.zip`
5. **Instala** usando "Añadir nuevo" → "Subir plugin"

### Paso 3: Verificar en WordPress Admin

1. Ve a **Plugins**
2. Busca "Formularios Admin" y "ACF Forms Frontend Creator"
3. Verifica que aparezcan CON SUS NOMBRES CORRECTOS:
   - ✅ `formularios-admin`
   - ✅ `acf-forms-frontend-creator`
4. Ambos deberían estar activos

### Paso 4: Comprobar configuración

**Formularios Admin:**
- Accede a: **Impactos** → **Notificaciones al Usuario**
- Verifica que la configuración está intacta
- Prueba enviando un formulario

**ACF Forms Frontend Creator:**
- Accede a: **Impactos** → **Configuración de Formularios**
- Verifica que las opciones de reCAPTCHA están correctas
- Prueba un formulario en el frontend

## Nuevos ZIPs - Estructura Correcta

A partir de ahora, los ZIPs generados con `create-plugin-release.sh` usan:

**Nombre del archivo:**
```
{plugin-slug}.zip
```

**Contenido interno:**
```
{plugin-slug}/
├── includes/
├── assets/
├── {plugin-slug}.php (archivo principal)
└── ...
```

**Resultado al extraer:**
```
wp-content/plugins/{plugin-slug}/  ✅ Correcto
```

NO habrá más problemas como:
```
wp-content/plugins/{plugin-slug}-{version}/  ❌ Incorrecto
```

## Scripts Actualizados

- `create-plugin-release.sh` - Genera ZIPs con nombres correctos
- `create-all-releases.sh` - Genera ambos plugins
- Estructura de releases: `releases/v{version}/{plugin-slug}.zip`

## Después de la corrección

Cuando haya una nueva versión:

1. Incrementa la versión en el archivo principal del plugin
2. Ejecuta: `./create-all-releases.sh`
3. Descarga los ZIPs desde `releases/v{VERSION}/`
4. Instala/actualiza en WordPress de forma normal

WordPress reconocerá automáticamente que es una actualización porque:
- ✅ El slug es idéntico
- ✅ La versión es mayor
- ✅ Todos los datos se preservan

## Pasos para la Próxima Actualización

```bash
# 1. En tu máquina local, actualiza versión y código
# Modifica: acf-forms-frontend-creator.php o formularios-admin.php
# * Version: 1.5.0

# 2. Generar nuevo ZIP
./create-all-releases.sh

# 3. Los ZIPs estarán en:
# releases/v1.5.0/formularios-admin.zip
# releases/v1.5.0/acf-forms-frontend-creator.zip

# 4. En producción:
# - Descargar el ZIP
# - Ir a Plugins → Añadir nuevo → Subir plugin
# - WordPress detectará como "actualización" ✅
```

## Preguntas Frecuentes

**P: ¿Se pierden mis configuraciones al renombrar?**
A: No. Las configuraciones están en la BD de WordPress (wp_options), no en los archivos. Renombrar la carpeta NO afecta nada.

**P: ¿Debo desactivar los plugins antes de renombrar?**
A: Recomendado. Desactiva primero, luego renombra, luego reactiva.

**P: ¿Qué pasa si hago esto y algo falla?**
A: Simplemente revierte el nombre de la carpeta:
```bash
mv formularios-admin formularios-admin-1.4.0
```

**P: ¿Los datos de formularios enviados se pierden?**
A: No. Los datos están guardados como Custom Posts en la BD. No se afectan.

## Contacto

Si necesitas ayuda o algo falla durante el proceso, verifica:
1. Que tienes permisos de escritura en wp-content/plugins/
2. Que el servidor está corriendo (WP carga normalmente)
3. Que no hay plugins conflictivos activados

---

**Versión de este documento:** 1.0
**Fecha:** 1 de mayo de 2026
**Aplicable a:** formularios-admin v1.4.0+, acf-forms-frontend-creator v1.7.0+
