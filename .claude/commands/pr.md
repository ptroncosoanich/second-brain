---
description: Trae el detalle de un PR de GitHub y opcionalmente lo enlaza en refs/github.md del proyecto correcto
argument-hint: <número o URL del PR, ej. org/repo#1234 o URL completa>
category: sync
---

# /pr — Detalle de un PR de GitHub

Tu rol: traer el detalle de un PR con `gh` y, si el usuario quiere, archivar el link en `refs/github.md` del proyecto correspondiente.

> Lee `perfil.md`: si la fuente GitHub está `inactiva` (§3), avisar y terminar. La organización de GitHub y el repo por defecto están en `organizacion.md`.

## Input

`$ARGUMENTS`:
- URL completa: `https://github.com/<org>/<repo>/pull/1234`
- Corto: `<org>/<repo>#1234` o `<repo>#1234` (con la organización de `organizacion.md`)
- Solo número: `1234` → el repo por defecto de `organizacion.md`, salvo que la conversación deje claro otro.

## Proceso

### Paso 1: Parsear

Extraer owner, repo y número. Si es ambiguo, preguntar.

### Paso 2: Consultar

```bash
gh pr view <num> --repo <owner>/<repo> --json number,title,body,state,isDraft,author,labels,assignees,reviewRequests,reviews,mergedAt,closedAt,additions,deletions,changedFiles,url
```

Si falla, reportar y terminar.

### Paso 3: Mostrar

```
🔀 #1234 <owner>/<repo> — Open / Draft / Merged / Closed

Título: <texto>
Autor: <login>
Asignados: <lista>
Reviewers pedidos: <lista>
Reviews: <N approved, M changes requested, K commented>
Labels: <lista>
Cambios: +<additions> / -<deletions> en <changedFiles> archivos
Link: <url>

Descripción (resumida):
<primeros 500 caracteres del body; si pasa de 2000, "ver completo en GitHub">
```

### Paso 4: Sugerir proyecto del brain

1. `**Repo**: <owner>/<repo>` en la sección `## GitHub` de algún `AGENTS.md`.
2. `**Label**: <label>` que coincida con un label del PR.
3. Keyword overlap del título.
4. Sin match: no sugerir.

```
Este PR parece de: <proyecto>.
¿Lo archivo en 1-proyectos/<slug>/refs/github.md? (sí / no / otro <slug>)
```

### Paso 5: Si confirma, archivar

En `refs/github.md` (crearlo si no existe), sección `## PRs trackeados`:

```markdown
- [#1234 <owner>/<repo>](https://github.com/<owner>/<repo>/pull/1234) — <Estado> — "<Título>" (agregado vía /pr el YYYY-MM-DD)
```

Si ya está, actualizar el estado.

### Paso 6: Reportar

`✓ #1234 archivado en 1-proyectos/<slug>/refs/github.md` o `✓ Detalle mostrado (sin archivar).`

## Reglas

- **Solo lectura**: no crear, editar ni comentar PRs.
- PRs con keywords `security`, `hr` o `compliance`: mostrar metadata y advertir antes de archivar.

## Aprendizajes

*(Se acumulan errores encontrados al ejecutar esta skill y cómo se resolvieron. Ver la regla en el `AGENTS.md` raíz.)*
