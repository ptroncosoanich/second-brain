---
description: Captura rápida de una nota — la clasifica al proyecto o área correcto sin que tengas que elegir
argument-hint: <texto de la nota>
category: captura
---

# /capturar — Captura clasificada

Tu rol: tomar una nota corta y archivarla en el lugar correcto del brain sin que el usuario tenga que elegir destino.

> Lee `perfil.md` (portafolio en §6, equipo en §2) si no lo leíste en esta sesión.

## Input

`$ARGUMENTS` es el texto de la nota. Puede ser una idea ("idea: cambiar el onboarding de PMs"), un pendiente ("recordar pedirle feedback a Ana sobre la migración"), un fragmento de conversación ("Diego dijo que la integración se atrasa 2 semanas"), un link con contexto o una decisión informal.

## Proceso

### Paso 1: Clasificar el tipo

- **Idea para un proyecto futuro** (todavía no es compromiso; sin deadline) → línea en `3-recursos/ideas-proyectos/inbox.md` con fecha. Señales: "podríamos hacer", "sería interesante explorar", "algún día", "no urgente pero…". Si la idea tiene cuerpo (más de un párrafo), sugerir `/idea "<slug>"`.
- **Idea o hipótesis sobre un proyecto activo** → `<destino>/ideas.md` (crear si no existe).
- **Pendiente** → línea en `<destino>/pendientes.md` con flag `[propuesto]` y fecha.
- **Decisión** → archivo nuevo `<destino>/decisiones/YYYY-MM-DD-<slug-corto>.md`.
- **Conflicto o bloqueo** → línea en `<destino>/conflictos.md` con fecha.
- **Referencia (link)** → línea en `<destino>/refs/README.md`.
- **Nota de reunión informal** → `<destino>/reuniones/YYYY-MM-DD-<slug>.md`.

Si no es obvio, default a `ideas.md` con el texto completo.

**`/capturar` vs `/cierre-dia`**: cuando el usuario captura a mano, el filtro de pendientes es permisivo — si dice "captura este pendiente: X", se crea aunque no sea claramente suyo (él ya hizo el juicio). El filtro estricto es para `/cierre-dia`. Si el pendiente es de otra persona, declararlo: `(responsable: <persona>)`.

### Paso 2: Clasificar el destino

Reglas en orden:

1. **Contexto explícito**: la nota nombra un proyecto o área por nombre o slug → ese.
2. **Conversación reciente**: si en esta sesión se viene trabajando un proyecto o área → ese.
3. **Keywords**: cruzar la nota con los `AGENTS.md` de `1-proyectos/*/` y `2-areas/*/` (nombres, stakeholders, temas). Una persona del 1:1 (`2-areas/1-a-1s/<persona>/`) si la nota es sobre la relación con ella.
4. **Si es dudoso**: `3-recursos/inbox.md` y avisar.

### Paso 3: Escribir

`Edit` si el archivo existe, `Write` si no. Formato para pendientes y conflictos:

```markdown
- `[propuesto]` 2026-05-25 — <texto> (capturado vía /capturar)
```

Para ideas:

```markdown
## 2026-05-25 — <título inferido o primera línea>

<texto completo>

*(capturado vía /capturar)*
```

### Paso 4: Reportar

```
✓ Capturado en <ruta relativa>
```

Si fue dudoso:
```
✓ Capturado en 3-recursos/inbox.md (no clasifiqué con certeza). ¿A qué proyecto pertenece?
```

## Reglas

- **NUNCA** crear Google Tasks, enviar mensajes ni modificar nada fuera del brain.
- **NO pedir confirmación** en casos obvios: el valor de `/capturar` es la velocidad.
- **SÍ pedirla** antes de crear una carpeta nueva en `1-proyectos/` o `2-areas/`.
- Idempotencia: si la misma nota ya se archivó hoy, no duplicar.

## Aprendizajes

*(Se acumulan errores encontrados al ejecutar esta skill y cómo se resolvieron. Ver la regla en el `AGENTS.md` raíz.)*
