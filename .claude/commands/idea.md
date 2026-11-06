---
description: Captura una idea para un proyecto futuro con plantilla estructurada en 3-recursos/ideas-proyectos/
argument-hint: <concepto, slug o frase descriptiva>
category: captura
---

# /idea — Captura estructurada de una idea para un proyecto futuro

Tu rol: tomar una idea que ya tiene cierta forma (más de una línea) y crear un archivo dedicado en `3-recursos/ideas-proyectos/<slug>.md` con plantilla.

**Cuándo NO usar esta skill**:
- Idea de una línea → `/capturar "idea: ..."` (va a `inbox.md`).
- Compromiso con deadline → es un proyecto activo: va a `1-proyectos/`.
- Pendiente accionable → `pendientes.md` del proyecto o área.

## Input

`$ARGUMENTS` puede ser un slug (`onboarding-pms`), un nombre legible (`"onboarding de PMs"`) o una frase con contexto (`"flujo de onboarding para PMs nuevos con sesiones de shadow y checklist"`).

## Proceso

### Paso 1: Derivar el slug

- Si `$ARGUMENTS` ya está en kebab-case sin acentos, usarlo.
- Si no, convertirlo: máximo 5-6 palabras, descriptivo.
- Verificar que `3-recursos/ideas-proyectos/<slug>.md` no exista. Si existe, ofrecer una variante o editar el existente.

### Paso 2: Si el input es muy escueto, preguntar

Solo si la idea es ambigua (una palabra, un slug suelto). Mínimo para crear el archivo: **slug + una línea de qué es**. Lo demás puede quedar `*(por completar)*`.

### Paso 3: Crear el archivo

```markdown
# Idea: <título legible>

**Slug**: `<slug>`
**Capturada**: YYYY-MM-DD vía /idea
**Madurez**: semilla
**Estado**: activa

## Qué es

<1-2 párrafos: qué se haría si esto se convirtiera en proyecto>

## Por qué importa

<problema que resuelve, oportunidad que abre, evidencias>

## Contexto / origen

<de dónde salió: reunión, conversación, observación; link si aplica>

## Stakeholders potenciales

<personas o equipos que se involucrarían>

## Próximos pasos para madurar

<qué hay que saber, explorar o conversar antes de promoverla a proyecto>

## Notas y evidencias

<bullets a medida que la idea evoluciona>
```

### Paso 4: Reportar

```
✓ Idea capturada en 3-recursos/ideas-proyectos/<slug>.md
  Madurez inicial: semilla. Edita el archivo para enriquecerla.
```

Cuando la idea madure, sugerir promoverla a `1-proyectos/<slug>/` (ver el ciclo de vida en `3-recursos/ideas-proyectos/README.md`).

## Reglas

- **NO crear** si el slug ya existe.
- **NO promover automáticamente** a `1-proyectos/`: requiere decisión explícita del usuario (deadline, dueño, alcance).
- **Privacidad**: aplicar el nivel de `perfil.md` §5 si la idea toca temas sensibles.

## Aprendizajes

*(Se acumulan errores encontrados al ejecutar esta skill y cómo se resolvieron. Ver la regla en el `AGENTS.md` raíz.)*
