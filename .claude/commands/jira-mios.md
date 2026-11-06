---
description: Sincroniza tus tickets de Jira (asignados o reportados) al brain — escribe refs/jira.md por proyecto y reporta cambios, sin generar resumen
argument-hint: [filtro opcional: "abiertos" | "review" | "sprint" | "reporter"]
category: sync
---

# /jira-mios — Tickets de Jira del usuario

Tu rol: consultar Jira con `acli` y mantener al día `refs/jira.md` en el o los proyectos correspondientes. **No genera resumen**: el resultado es la actualización del brain y una notificación breve.

> Lee `perfil.md`: si la fuente Jira está `inactiva` (§3), avisar y terminar. La URL base de Jira está en `organizacion.md` (`<JIRA>` abajo). Si existe el plugin `buk-skills:atlassian-cli`, sirve de referencia para `acli`.

## Input

`$ARGUMENTS`:
- vacío / `"abiertos"`: tickets no cerrados asignados al usuario (default).
- `"review"`: tickets en revisión donde es asignado o reviewer.
- `"sprint"`: tickets del sprint activo.
- `"reporter"`: tickets reportados por el usuario.

## Proceso

### Paso 1: Consultar

Verificar una vez `command -v acli`; si no está, dar la instalación (`brew tap atlassian/homebrew-acli && brew install acli`, luego `acli jira auth login --web`) y terminar.

```bash
# abiertos
acli jira workitem search --jql "assignee = currentUser() AND statusCategory != Done" --json --limit 100

# review
acli jira workitem search --jql "(assignee = currentUser() OR \"Reviewer\" = currentUser()) AND status in ('In Review','Code Review','Listo para Review')" --json --limit 100

# sprint
acli jira workitem search --jql "assignee = currentUser() AND sprint in openSprints()" --json --limit 100

# reporter
acli jira workitem search --jql "reporter = currentUser() AND statusCategory != Done" --json --limit 100
```

### Paso 2: Parsear y agrupar

Por ticket: `key`, `summary`, `status`, `priority`, `project.key`, `parent` (épica) y `updated`. Agrupar por proyecto de Jira.

### Paso 3: Enrutar al brain

1. **Match explícito**: secciones `## Jira` de `1-proyectos/*/AGENTS.md` y `2-areas/*/AGENTS.md` con `**Proyecto Jira**: KEY`, `**Épica**: KEY-NNNN` o `**Componente**: <nombre>`.
2. **Match por épica padre o componente.**
3. **Fallback**: `3-recursos/inbox-jira.md` para mapeo manual.

### Paso 4: Escribir `refs/jira.md` por destino

Sobrescribir completo (es un snapshot, no un log):

```markdown
# Jira — snapshot YYYY-MM-DD HH:MM

> Actualizado por `/jira-mios`. Fuente de verdad: Jira (`<JIRA>`).

## Tickets abiertos (asignados a mí)

### En progreso (N)
- [KEY-1234](<JIRA>/browse/KEY-1234) — High — "Resumen del ticket" (épica: KEY-1100)

### Por hacer (N)
- ...

### En review (N)
- ...

## Reportados por mí (no asignados)
- ...
```

Si el archivo tenía secciones agregadas por `/cierre-dia` o `/jira-ticket` (tickets mencionados o relacionados), conservarlas debajo del snapshot.

### Paso 5: Detectar cambios

Antes de sobrescribir, comparar con el snapshot anterior: tickets nuevos, cerrados (ya no aparecen) y cambios de estado significativos.

### Paso 6: Reportar

```
✓ Jira sincronizado:
- N tickets abiertos en M proyectos del brain.
- Desde el snapshot anterior: +X nuevos · ✓Y cerrados · ↻Z cambios de estado
- K tickets sin mapeo → 3-recursos/inbox-jira.md

Archivos actualizados:
- 1-proyectos/<slug>/refs/jira.md (N tickets)
```

## Reglas

- **Solo lectura** sobre Jira: nunca crear, editar, comentar ni transicionar tickets.
- **Snapshot reciente**: si se corrió hace menos de 15 minutos, preguntar antes de refrescar.
- **Mapeo nuevo**: si un ticket parece de un proyecto sin sección `## Jira`, sugerir agregar el mapeo.

## Aprendizajes

*(Se acumulan errores encontrados al ejecutar esta skill y cómo se resolvieron. Ver la regla en el `AGENTS.md` raíz.)*
