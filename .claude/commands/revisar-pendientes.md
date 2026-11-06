---
description: Genera un documento consolidado de pendientes abiertos para edición masiva; al terminar aplica los cambios a los archivos originales
argument-hint: [filtro opcional: "sin-procesar" | "priorizados" | "<slug-proyecto>"]
category: gestion
---

# /revisar-pendientes — Revisión masiva por documento consolidado

Tu rol: ayudar al usuario a revisar sus pendientes **de una sola pasada, editando un único documento**, en vez de ítem por ítem.

Dos fases:

1. **Generar** un documento consolidado con todos los pendientes abiertos. El usuario lo edita a mano (reprioriza, completa, descarta, reformula).
2. **Aplicar**: cuando avisa que terminó, escribes sus cambios de vuelta en los `pendientes.md` originales y borras el temporal.

## Detección de fase

Al invocar la skill, revisar si existe `REVISION-PENDIENTES.md` en la raíz del workspace (está en `.gitignore`):

- **No existe** → **Fase 1 (Generar)**.
- **Existe** → **Fase 2 (Aplicar)**. Si el usuario pide "regenerar", borrarlo y volver a la Fase 1.

Así la skill es idempotente y reanudable.

---

## Qué pendientes entran

```bash
find 1-proyectos 2-areas -name 'pendientes.md' -type f
```

Cada línea de pendiente sigue una de **dos familias**:

- **Familia A (backtick)**: `` - `[TAG]` YYYY-MM-DD — texto (metadata...) `` con `TAG` ∈ `propuesto`, `confirmado`, `P1`…`P5`, `completado:YYYY-MM-DD`.
- **Familia B (checkbox)**: `- [ ] texto — Responsable [Px] *(de: fecha — título)*`; la prioridad `[Px]` va al final y, si falta, está sin priorizar.

| Categoría | Criterio |
|---|---|
| **Sin procesar** | Familia A con `[propuesto]` o `[confirmado]`, o Familia B sin `[Px]` |
| **Priorizado** | Tiene `[P1]`…`[P5]` y no está completado |
| **Excluir** | `[completado:...]`, líneas bajo `## Completados`, `- [x]` |

`$ARGUMENTS` como filtro: vacío → todo; `"sin-procesar"`; `"priorizados"`; `"<slug>"` → solo ese proyecto o área.

---

## Fase 1 — Generar el documento

### Paso 1.1: Recolectar y parsear

Por cada ítem abierto guardar:

- `id` — correlativo global de dos dígitos (`#01`, `#02`, …).
- `file` — ruta relativa del `pendientes.md`.
- `raw` — la línea **exacta**, tal cual está en el archivo.
- `familia` — `A` o `B`.
- `tag` — prioridad o estado actual.
- `fecha`, `texto`, `categoria`.

Hacerlo con un script que **no imprima todos los originales** por terminal: guardar el JSON en un archivo temporal y devolver solo un resumen (una salida larga llega truncada y deja de ser JSON válido).

### Paso 1.2: Escribir `REVISION-PENDIENTES.md`

En la raíz del workspace:

```markdown
# Revisión de pendientes — <YYYY-MM-DD>

> Edita este archivo y avísame ("listo") cuando termines.
> Aplicaré tus cambios a los `pendientes.md` originales y borraré este archivo.
>
> **Cómo marcar cada línea** (solo toca el tag entre corchetes o el texto):
> - **Reprioriza**: cambia el tag a `[P1]`…`[P5]`.
> - **Completa**: cambia el tag a `[x]`.
> - **Descarta**: cambia el tag a `[-]`.
> - **Reformula**: edita el texto después del `—`.
> - **Sin cambios**: no toques la línea.
> - ⚠️ **No borres líneas ni el `#NN` inicial**: lo uso para ubicar el original. Borrar una línea NO la elimina; para eso usa `[-]`.

## Sin procesar (<N>)

### <slug-proyecto-o-area>
- `#01` `[propuesto]` 2026-06-16 — <texto>
- `#02` `[ ]` — <texto>   ← (familia B sin prioridad se muestra como `[ ]`)

## Priorizados (<M>)

### <slug-proyecto-o-area>
- `#12` `[P1]` 2026-05-28 — <texto>

<!--
CONTROL — NO EDITAR. Bloque que uso para aplicar los cambios.
[
  {"id":"01","file":"1-proyectos/<slug>/pendientes.md","familia":"A","tag":"propuesto","raw":"- `[propuesto]` 2026-06-16 — ..."}
]
-->
```

Reglas:

- Agrupar por categoría y, dentro, por proyecto o área.
- `#NN` primero, luego el tag, la fecha y el texto.
- El **bloque CONTROL** es la fuente de verdad de la Fase 2. **Nunca** depender del número de línea; ubicar por `raw`.
- **Privacidad**: si un ítem viene de una carpeta `sensible/` o tiene un tag `[confidencial]`, mostrar solo `#NN` y `— [contenido sensible]`, pero conservar su `raw` real en CONTROL.

### Paso 1.3: Avisar

```
📄 Generé REVISION-PENDIENTES.md con <N> sin procesar + <M> priorizados (<total> en <K> proyectos/áreas).

Edítalo y avísame cuando termines:
- [P1]..[P5] para (re)priorizar
- [x] para completar
- [-] para descartar
- edita el texto para reformular
```

Terminar acá. La Fase 1 no modifica ningún `pendientes.md`.

---

## Fase 2 — Aplicar cambios

### Paso 2.1: Leer y comparar

1. Leer `REVISION-PENDIENTES.md` completo, incluido CONTROL.
2. **Normalizar** los tags editados: `p1`…`p5` → `P1`…`P5`, `[X]` → `[x]`, espacios sobrantes.
3. Comparar original vs editado por `id`:

| Cambio | Acción |
|---|---|
| Tag pasó a `[x]` | **Completar** |
| Tag pasó a `[-]` | **Descartar** |
| Tag cambió entre `P1..P5` / `propuesto` / `confirmado` | **Repriorizar** |
| Solo cambió el texto | **Reformular** (conservar el tag) |
| Cambiaron tag y texto | Ambos |
| Sin cambios | **Omitir** |

Si aparece un `#NN` que no está en CONTROL, o uno de CONTROL desapareció del doc, **no adivinar**: reportar la anomalía y pedir confirmación antes de tocar ese ítem.

### Paso 2.2: Escribir de vuelta

Agrupar por `file` y ubicar cada línea por su `raw` (match exacto).

- **Repriorizar**: Familia A, cambiar `` `[<viejo>]` `` → `` `[<nuevo>]` ``. Familia B, cambiar el `[Px]` final o agregarlo antes del `*(de: ...)*`.
- **Reformular**: reemplazar el texto conservando tag, fecha y metadata (responsable, links, anotaciones).
- **Completar** y **Descartar**: eliminar la línea de `pendientes.md`. El historial queda en git; no se crean archivos de completados ni descartados.

Al eliminar, borrar solo la línea del ítem (y, como mucho, una línea en blanco que quede pegada). No reformatear el resto del archivo: verificar con `git diff --stat` que el número de líneas tocadas coincide con las acciones.

### Paso 2.3: Borrar el temporal y reportar

1. Borrar `REVISION-PENDIENTES.md`.
2. Reportar:

```
✓ Cambios aplicados:

- 📌 Repriorizados: <a>
- ✅ Completados: <b>  → eliminados de pendientes.md
- 🗑  Descartados: <c>  → eliminados de pendientes.md
- ✏️  Reformulados: <d>
- ⏭  Sin cambios: <e>

Archivos tocados:
- <ruta> (...)

🧹 Borré REVISION-PENDIENTES.md.
```

---

## Reglas críticas

- **La Fase 1 nunca escribe en `pendientes.md`.**
- **Nunca crear archivos adicionales** además del temporal.
- **Match por `raw`, nunca por número de línea.**
- **Ante ambigüedad** (línea borrada, `#NN` desconocido, duplicado): preguntar.
- **Idempotencia**: si la Fase 2 se interrumpe, re-invocar es seguro: lo ya aplicado no vuelve a calzar por `raw`.
- **Preservar metadata** al reescribir una línea.

## Aprendizajes

*(Se acumulan errores encontrados al ejecutar esta skill y cómo se resolvieron. Ver la regla en el `AGENTS.md` raíz.)*

### Heredados del brain original

- **2026-11-03 — JSON truncado.** Imprimir todos los originales junto con los cambios superó el límite de salida y el JSON llegó cortado. Procesar dentro del script y devolver solo los cambios y un resumen.
- **2026-11-04 — Prioridades en minúscula y formato colapsado.** El usuario escribió `[p2]` y el diff lo tomó como tag desconocido (de ahí la normalización del Paso 2.1). Además, el script de escritura colapsó las líneas en blanco de todo el archivo: eliminar solo la línea del ítem y verificar con `git diff --stat`.
