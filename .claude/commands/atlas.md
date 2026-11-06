---
description: Búsqueda directa en la wiki Buk Atlas; opcionalmente guarda el link en refs/ de un proyecto
argument-hint: <consulta>
category: busqueda
---

# /atlas — Búsqueda directa en Buk Atlas

Tu rol: buscar en la wiki interna de Buk (Buk Atlas, un Shared Drive de Google) y opcionalmente guardar links relevantes en `refs/` de un proyecto del brain.

> Lee `perfil.md`: si la fuente Buk Atlas está `inactiva` (§3), avisar y terminar. El ID del Shared Drive está en `organizacion.md` (`<ATLAS_ID>` abajo).

## Input

`$ARGUMENTS`: pregunta o keywords.

## Proceso

### Paso 1: Buscar

Atlas es un **Shared Drive**: toda query necesita `supportsAllDrives: true`, `includeItemsFromAllDrives: true` y `trashed = false`.

Por texto completo:

```bash
gws drive files list --params "{\"q\": \"fullText contains '<consulta>' and driveId='<ATLAS_ID>' and trashed = false\", \"supportsAllDrives\": true, \"includeItemsFromAllDrives\": true, \"driveId\": \"<ATLAS_ID>\", \"corpora\": \"drive\", \"pageSize\": 15, \"fields\": \"files(id,name,mimeType,modifiedTime,webViewLink,owners(displayName))\"}"
```

Si no hay resultados, por nombre:

```bash
gws drive files list --params "{\"q\": \"name contains '<consulta>' and driveId='<ATLAS_ID>' and trashed = false\", \"supportsAllDrives\": true, \"includeItemsFromAllDrives\": true, \"driveId\": \"<ATLAS_ID>\", \"corpora\": \"drive\", \"pageSize\": 10, \"fields\": \"files(id,name,mimeType,modifiedTime,webViewLink,owners(displayName))\"}"
```

Parsear desde la primera llave (la línea `Using keyring backend` va a stderr).

### Paso 2: Filtrar y rankear

- Docs y Sheets antes que PDFs y Slides.
- Modificados en los últimos 6 meses primero (más probable que estén vigentes).
- Máximo 5.

### Paso 3: Reportar

```
🔍 Buk Atlas — resultados para "<consulta>":

1. 📘 <nombre> (<tipo>, mod. <fecha>)
   Owner: <owner>
   <link>

2. ...

¿Guardo alguno en refs/ de un proyecto? Indica número y proyecto.
```

### Paso 4: Si el usuario pide guardar

1. Ubicar el proyecto o área por slug exacto o parcial.
2. Crear `refs/` y `refs/README.md` (con `# Referencias`) si no existen.
3. Agregar:
   ```markdown
   - [<nombre del doc>](<webViewLink>) — Buk Atlas, mod. <fecha>. Guardado vía /atlas el <YYYY-MM-DD>.
   ```
4. Confirmar: `✓ Guardado en <ruta>/refs/README.md`

## Reglas

- Solo lectura sobre Atlas: nunca subir ni modificar archivos de la wiki.
- Con cero resultados, sugerir 2-3 sinónimos o términos relacionados.
- Si el doc es confidencial (compensación, evaluaciones), advertir antes de guardar el link.

## Aprendizajes

*(Se acumulan errores encontrados al ejecutar esta skill y cómo se resolvieron. Ver la regla en el `AGENTS.md` raíz.)*
