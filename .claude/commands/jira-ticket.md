---
description: Trae el detalle de un ticket de Jira y opcionalmente lo enlaza en refs/ del proyecto correcto del brain
argument-hint: <KEY del ticket, ej. ABC-1234>
category: sync
---

# /jira-ticket — Detalle de un ticket de Jira

Tu rol: traer el detalle de un ticket con `acli` y, si el usuario quiere, archivar el link en `refs/jira.md` del proyecto correspondiente.

> Lee `perfil.md`: si la fuente Jira está `inactiva` (§3), avisar y terminar. La URL base está en `organizacion.md` (`<JIRA>` abajo).

## Input

`$ARGUMENTS`: clave del ticket, formato `[A-Z]+-\d+`.

## Proceso

### Paso 1: Validar

Regex `^[A-Z][A-Z0-9]*-\d+$`. Si no calza, pedir que lo reformule.

### Paso 2: Consultar

```bash
acli jira workitem view <KEY> --json
```

Si falla con "not found", reportar y terminar. Si `acli` no está instalado, dar la instalación (ver `/jira-mios`).

### Paso 3: Mostrar el detalle

```
🎫 KEY-1234 — In Progress — High

Summary: <texto>
Tipo: Story | Bug | Task | Epic | Subtask
Asignado: <nombre>
Reporter: <nombre>
Sprint: <nombre>
Épica padre: KEY-XXXX
Componentes: <lista>
Labels: <lista>
Creado: <fecha> · Actualizado: <fecha>

Link: <JIRA>/browse/KEY-1234

Descripción:
<texto plano extraído del ADF: jq '.fields.description | .. | .text? // empty'>
```

Tablas, código o adjuntos de la descripción: mencionarlos, sin renderizarlos.

### Paso 4: Sugerir proyecto del brain

1. Épica padre mapeada en la sección `## Jira` de algún `AGENTS.md`.
2. Componente que calce con un proyecto.
3. Keyword overlap del summary con los `AGENTS.md` activos.
4. Sin match claro: no sugerir y terminar.

```
Este ticket parece de: <proyecto>.
¿Lo agrego a 1-proyectos/<slug>/refs/jira.md? (sí / no / otro <slug>)
```

### Paso 5: Si confirma, archivar

En `refs/jira.md` (crearlo si no existe), sección `## Tickets relacionados`:

```markdown
- [KEY-1234](<JIRA>/browse/KEY-1234) — <Status> — <Priority> — "<Summary>" (agregado vía /jira-ticket el YYYY-MM-DD)
```

Si el KEY ya está, actualizar el estado en vez de duplicar.

### Paso 6: Reportar

`✓ KEY-1234 archivado en 1-proyectos/<slug>/refs/jira.md` o `✓ Detalle mostrado (sin archivar).`

## Reglas

- **Solo lectura**: no editar, transicionar ni comentar el ticket.
- Sin confirmación, no tocar `refs/jira.md`.
- Tickets con labels `confidencial`, `hr` o `security`: mostrar metadata y advertir antes de archivar.

## Aprendizajes

*(Se acumulan errores encontrados al ejecutar esta skill y cómo se resolvieron. Ver la regla en el `AGENTS.md` raíz.)*
