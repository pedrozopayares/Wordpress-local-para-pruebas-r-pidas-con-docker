# Checklist de Implementación - Corrección de Nombres de Plugins

## ✅ Hecho Localmente

- [x] Scripts `create-plugin-release.sh` y `create-all-releases.sh` creados
- [x] Nombres de ZIPs ajustados: `{slug}.zip` (sin versión)
- [x] ZIPs almacenados en: `releases/v{VERSION}/{slug}.zip`
- [x] Nuevos ZIPs generados:
  - `releases/v1.4.0/formularios-admin.zip`
  - `releases/v1.7.0/acf-forms-frontend-creator.zip`
- [x] Documentación completa:
  - `FIX-PRODUCTION.md` - Instrucciones para producción
  - `QUICK-REFERENCE.md` - Referencia rápida
  - `RELEASES.md` - Guía actualizada
  - `TESTING-UPDATES.md` - Verificación

---

## 📋 A Hacer en Producción

### Fase 1: Solucionar Nombres Incorrectos (URGENTE)

**Opción A: Por SSH (Recomendado)**
- [ ] Conectarse al servidor por SSH
- [ ] Navegar a: `cd /ruta/a/wp-content/plugins/`
- [ ] Ejecutar: `mv acf-forms-frontend-creator-1.7.0 acf-forms-frontend-creator`
- [ ] Ejecutar: `mv formularios-admin-1.4.0 formularios-admin`
- [ ] Verificar: `ls -la | grep formularios` (debe mostrar solo `formularios-admin`)
- [ ] Verificar: `ls -la | grep acf` (debe mostrar solo `acf-forms-frontend-creator`)

**Opción B: Por WordPress Admin**
- [ ] Ir a: **Plugins**
- [ ] Desactivar: "acf-forms-frontend-creator-1.7.0"
- [ ] Desactivar: "formularios-admin-1.4.0"
- [ ] Eliminar: "acf-forms-frontend-creator-1.7.0"
- [ ] Eliminar: "formularios-admin-1.4.0"
- [ ] Ir a: **Plugins → Añadir nuevo**
- [ ] Descargar: `releases/v1.7.0/acf-forms-frontend-creator.zip` (local)
- [ ] Subir: archivo ZIP
- [ ] Instalar y activar
- [ ] Repetir para `formularios-admin.zip`

### Fase 2: Verificación en Producción

- [ ] Abrir WordPress Admin: **Plugins**
- [ ] Verificar "Formularios Admin" aparece con nombre correcto
- [ ] Verificar "ACF Forms Frontend Creator" aparece con nombre correcto
- [ ] Ambos plugins están **activados** ✅
- [ ] Ni "formularios-admin-1.4.0" ni "acf-forms-frontend-creator-1.7.0" aparecen

### Fase 3: Pruebas Funcionales

**Formularios Admin:**
- [ ] Ir a: **Impactos → Notificaciones al Usuario**
- [ ] Verificar que la configuración se preservó intacta
- [ ] Probar enviando un formulario desde el frontend
- [ ] Verificar que se recibe email de confirmación en el usuario

**ACF Forms Frontend Creator:**
- [ ] Ir a: **Impactos → Configuración de Formularios**
- [ ] Verificar que las opciones de reCAPTCHA están intactas
- [ ] Probar un formulario en el frontend
- [ ] Verificar que reCAPTCHA funciona si está activado

### Fase 4: Subir a GitHub Releases (Opcional pero Recomendado)

- [ ] En tu máquina local, navega a la carpeta del proyecto
- [ ] Ejecutar: `./create-all-releases.sh`
- [ ] Verificar que los ZIPs se generaron correctamente
- [ ] Para **formularios-admin**:
  ```bash
  gh release upload v1.4.0 'releases/v1.4.0/formularios-admin.zip'
  ```
- [ ] Para **acf-forms-frontend-creator**:
  ```bash
  gh release upload v1.7.0 'releases/v1.7.0/acf-forms-frontend-creator.zip'
  ```
- [ ] Verificar en GitHub que los archivos aparecen en los releases

---

## 📚 Documentación a Consultar

| Documento | Cuándo leerlo | Contenido |
|---|---|---|
| `FIX-PRODUCTION.md` | Antes de arreglar producción | Pasos detallados con explicaciones |
| `QUICK-REFERENCE.md` | Referencia rápida | Tablas y comandos esenciales |
| `RELEASES.md` | Cuando generes nuevos ZIPs | Características y validación |
| `TESTING-UPDATES.md` | Para testing y troubleshooting | Pruebas y diagnósticos |

---

## 🚀 Flujo para Próximas Versiones

### Cuando haya una nueva versión:

1. **En tu máquina local:**
   ```bash
   # 1. Editar el archivo principal del plugin
   # Cambiar: * Version: 1.4.0  →  * Version: 1.5.0
   # nano formularios-admin.php  (o tu editor)
   
   # 2. Generar ZIPs
   ./create-all-releases.sh
   
   # 3. Subir a GitHub
   gh release create v1.5.0 releases/v1.5.0/formularios-admin.zip
   ```

2. **En producción:**
   ```bash
   # Descargar el ZIP
   curl -O https://github.com/usuario/repo/releases/download/v1.5.0/formularios-admin.zip
   
   # Ir a WordPress Admin → Plugins → Actualizar
   # O extrae manualmente en wp-content/plugins/
   ```

3. **WordPress detectará automáticamente que es una actualización** ✅

---

## ⚠️ Notas de Seguridad

- [ ] Hacer backup antes de cambios (recomendado)
- [ ] Desactivar plugins antes de renombrar (recomendado)
- [ ] Verificar permisos: `chmod 755 wp-content/plugins/`
- [ ] Los datos en BD nunca se afectan (safe to rename)

---

## 🔍 Verificación Final

```bash
# En producción, verificar estructura:
ls -la /ruta/a/wp-content/plugins/ | grep -E "formularios|acf"
# Debe mostrar:
# drwxr-xr-x  formularios-admin
# drwxr-xr-x  acf-forms-frontend-creator
# (Sin números de versión)
```

---

## 📞 Troubleshooting

| Problema | Solución |
|---|---|
| Carpeta aún tiene nombre incorrecto | Renombrar manualmente o reinstalar desde ZIP |
| WordPress no reconoce actualización | Verificar que slug es exactamente igual |
| Datos se perdieron | Restaurar backup de BD (datos NO se pierden al renombrar) |
| Plugins no funcionan después | Verifica que están activados en WordPress Admin |

---

## ✨ Al Completarse

- [ ] Problemas de actualización RESUELTOS
- [ ] Sistema de releases implementado y testeado
- [ ] Documentación lista para futuras versiones
- [ ] Scripts automáticos creados y funcionando
- [ ] Equipo capacitado en nuevo flujo

---

**Estado General:** 🟢 LISTA PARA IMPLEMENTAR

**Tiempo Estimado:** 
- Opción A (SSH): ~5 minutos
- Opción B (Admin): ~10 minutos
- Pruebas: ~10 minutos
- **Total: 15-20 minutos**

---

**Documento:** IMPLEMENTATION-CHECKLIST.md  
**Versión:** 1.0  
**Fecha:** 1 de mayo de 2026  
**Aplicable a:** formularios-admin v1.4.0+, acf-forms-frontend-creator v1.7.0+
