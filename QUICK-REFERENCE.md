# Referencia Rápida - Nombres de Plugins Correctos

## El Problema 🔴

En tu servidor de producción, los plugins fueron instalados con nombres incorrectos:

| Instalado (Incorrecto) | Debe ser |
|---|---|
| `acf-forms-frontend-creator-1.7.0` | `acf-forms-frontend-creator` |
| `formularios-admin-1.4.0` | `formularios-admin` |

**Consecuencia:** WordPress no reconoce las actualizaciones.

---

## La Solución ✅

### Paso 1: Solucionar Producción (AHORA)

**Opción A: Por SSH (Rápido)**
```bash
cd /ruta/a/wp-content/plugins/
mv acf-forms-frontend-creator-1.7.0 acf-forms-frontend-creator
mv formularios-admin-1.4.0 formularios-admin
```

**Opción B: Por WordPress Admin (Seguro)**
1. Desactiva ambos plugins
2. Elimina ambos plugins
3. Descarga ZIPs correctos desde: `releases/v{VERSION}/{plugin-slug}.zip`
4. Reinstala desde Plugins → Añadir nuevo

### Paso 2: Futuro (Próximas Versiones)

Los nuevos ZIPs usan nombres simples:
- `releases/v1.4.0/formularios-admin.zip` → instala como `formularios-admin/` ✅
- `releases/v1.7.0/acf-forms-frontend-creator.zip` → instala como `acf-forms-frontend-creator/` ✅

---

## Estructura de Directorios

### Antes (Incorrecto)
```
wp-content/plugins/
├── acf-forms-frontend-creator-1.7.0/    ❌ MALO
├── formularios-admin-1.4.0/              ❌ MALO
└── ...
```

### Ahora (Correcto)
```
wp-content/plugins/
├── acf-forms-frontend-creator/           ✅ BIEN
├── formularios-admin/                    ✅ BIEN
└── ...
```

---

## Generar Nuevos ZIPs

```bash
# Incrementar versión en el archivo principal
# Ejemplo: formularios-admin.php
# * Version: 1.4.0  →  * Version: 1.5.0

# Generar ZIPs
./create-all-releases.sh

# Resultado
releases/
├── v1.5.0/
│   ├── formularios-admin.zip
│   └── acf-forms-frontend-creator.zip
└── v1.4.0/
    ├── formularios-admin.zip
    └── acf-forms-frontend-creator.zip
```

---

## Instalación en WordPress

### Primera Instalación
1. Descargar ZIP de `releases/v{VERSION}/{plugin-slug}.zip`
2. Plugins → Añadir nuevo → Subir plugin
3. Activa

### Actualización (Versión Mayor)
1. Descargar ZIP de `releases/v{VERSION}/{plugin-slug}.zip`
2. Plugins → Actualizar → Seleccionar archivo
3. WordPress detecta automáticamente que es una actualización
4. **Todos los datos se preservan** ✅

---

## Verificación Rápida

**Verificar que el ZIP es correcto:**
```bash
unzip -l releases/v1.4.0/formularios-admin.zip | head -5
# Debe mostrar:
#   formularios-admin/
#   formularios-admin/formularios/
#   (SIN "-1.4.0" en el nombre)
```

**En WordPress Admin:**
- Plugins → Buscar "Formularios Admin"
- Debe mostrar: `formularios-admin` (sin versión)
- Debe estar activo y funcionando

---

## Notas Importantes

| Aspecto | Detalles |
|---|---|
| **Datos** | Renombrar/actualizar NO pierde datos (están en BD) |
| **Configuración** | Se preserva automáticamente en wp_options |
| **Reversa** | Si algo falla, renombra de vuelta (es seguro) |
| **Tiempo** | El proceso toma < 2 minutos |

---

## Checklist de Verificación

- [ ] Plugins desactivados (si los haces)
- [ ] Carpetas renombradas correctamente
- [ ] WordPress carga normalmente
- [ ] Plugins aparecen con nombres correctos en admin
- [ ] Plugins están activos
- [ ] Pruebas funcionales pasan

---

## Próximos Pasos

1. **Hoy**: Renombra carpetas en producción
2. **Próxima versión**: Usa `./create-all-releases.sh` para generar ZIPs
3. **Distribución**: Descarga desde `releases/v{VERSION}/`
4. **Instalación**: Usar WordPress admin o programático

---

## Contacto/Ayuda

Si necesitas ayuda:
- Revisa `FIX-PRODUCTION.md` para pasos detallados
- Revisa `RELEASES.md` para información de ZIPs
- Verifica permisos en `wp-content/plugins/`

**Versión:** 1.0  
**Fecha:** 1 de mayo de 2026
