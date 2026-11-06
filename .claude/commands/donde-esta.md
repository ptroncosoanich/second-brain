---
description: Busca un concepto en el brain local; si no encuentra suficiente, escala a Buk Atlas
argument-hint: <concepto o pregunta>
category: busqueda
---

# /donde-esta — Búsqueda en dos niveles

Tu rol: encontrar información sobre un concepto, primero en el brain y después en la wiki Buk Atlas si el brain no tiene suficiente.

## Input

`$ARGUMENTS`: concepto, frase o pregunta.

## Proceso

### Paso 1: Buscar en el brain

Desde la raíz del brain, excluyendo `4-archivo/` por defecto:

```bash
rg -i --type md -C 2 "<concepto>" 1-proyectos 2-areas 3-recursos perfil.md
```

Si el concepto tiene varias palabras, probar variaciones (con y sin acentos, sinónimos obvios). Si el usuario pide incluir lo archivado, agregar `4-archivo`.

Por cada match: archivo y línea, 2-3 líneas de contexto, y el proyecto o área al que pertenece.

### Paso 2: Evaluar suficiencia

- **Suficiente**: al menos un match claro y relevante → Paso 4.
- **Insuficiente**: cero matches, o solo coincidencias de palabras sueltas → Paso 3.

### Paso 3: Escalar a Buk Atlas

Solo si la fuente Buk Atlas está activa en `perfil.md` §3. Avisar primero:

```
Sin matches útiles en el brain. Buscando en Buk Atlas...
```

Con el ID del Shared Drive de `organizacion.md`:

```bash
gws drive files list --params "{\"q\": \"fullText contains '<concepto>' and driveId='<ATLAS_ID>' and trashed = false\", \"supportsAllDrives\": true, \"includeItemsFromAllDrives\": true, \"driveId\": \"<ATLAS_ID>\", \"corpora\": \"drive\", \"pageSize\": 10, \"fields\": \"files(id,name,mimeType,modifiedTime,webViewLink)\"}"
```

Listar los 3-5 mejores: nombre, tipo, última modificación y link.

### Paso 4: Reportar

**Si encontró en el brain**:
```
Encontré <N> referencias en el brain:

📁 1-proyectos/<slug>/<archivo>:<línea>
   <contexto>

[si aplica: hay <N> resultados relacionados en Buk Atlas — ¿los busco?]
```

**Si solo encontró en Atlas**:
```
Sin resultados en el brain. En Buk Atlas:

📘 <nombre del doc> (<tipo>, mod. <fecha>)
   <link>

¿Guardo el más relevante en refs/ de algún proyecto?
```

**Si no encontró nada**:
```
Sin resultados ni en el brain ni en Buk Atlas.

Sugerencias:
- Probar con: <2-3 sinónimos>
- ¿Apareció hoy en una reunión? Corre /cierre-dia primero.
```

## Reglas

- Solo lectura. La única escritura permitida es guardar un link en `refs/README.md` si el usuario lo confirma.
- Priorizar matches en `decisiones/` y `AGENTS.md` (alta señal) sobre `reuniones/` (mucho ruido).
- Si la consulta es muy ambigua ("estrategia", "Q3"), pedir clarificación antes de buscar.

## Aprendizajes

*(Se acumulan errores encontrados al ejecutar esta skill y cómo se resolvieron. Ver la regla en el `AGENTS.md` raíz.)*
