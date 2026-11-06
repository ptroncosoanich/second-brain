---
description: Snapshot vivo de los PRs de GitHub donde eres autor o reviewer; actualiza refs/github.md por proyecto
argument-hint: [filtro: "mios" | "review" | "recientes" | "<repo>"]
category: sync
---

# /mis-prs — PRs de GitHub del usuario

Tu rol: consultar GitHub con `gh` y mantener al día `refs/github.md` en el proyecto correspondiente. **No genera resumen**: el resultado es la actualización del brain y una notificación breve.

> Lee `perfil.md`: si la fuente GitHub está `inactiva` (§3), avisar y terminar. La organización de GitHub está en `organizacion.md` (`<org>` abajo).

## Input

`$ARGUMENTS`:
- vacío: PRs abiertos donde el usuario es autor o tiene review pedido (default).
- `"mios"`: solo como autor.
- `"review"`: solo con review pedido.
- `"recientes"`: cerrados o mergeados en los últimos 7 días donde participó.
- `"<repo>"`: un repo específico (ej. `buk-webapp`).

## Proceso

### Paso 1: Consultar

```bash
F=number,title,url,state,repository,labels,updatedAt,isDraft

# default (las dos)
gh search prs --owner=<org> --author=@me --state=open --json $F --limit 100
gh search prs --owner=<org> --review-requested=@me --state=open --json $F --limit 100

# recientes (fecha de hace 7 días: macOS `date -v-7d +%Y-%m-%d`, Linux `date -d '7 days ago' +%Y-%m-%d`)
gh search prs --owner=<org> --involves=@me --merged-at=">=<fecha>" --json $F --limit 100

# repo específico
gh pr list --repo <org>/<repo> --search "author:@me OR review-requested:@me" --state=open --json number,title,url,state,labels,updatedAt,isDraft
```

### Paso 2: Enrutar al brain

1. **Mapeo explícito**: sección `## GitHub` de los `AGENTS.md` con `**Repo**: <org>/<nombre>` o `**Label**: <label>`.
2. **Keyword overlap** del título con los `AGENTS.md` activos.
3. **Fallback**: `3-recursos/inbox-github.md`.

### Paso 3: Escribir `refs/github.md` por destino

Sobrescribir el snapshot (conservando debajo las secciones que agregan `/cierre-dia` o `/pr`):

```markdown
# GitHub — snapshot YYYY-MM-DD HH:MM

> Actualizado por `/mis-prs`. Re-correr para refrescar.

## Autor (N)
- [#1234 <org>/<repo>](https://github.com/<org>/<repo>/pull/1234) — Open — "Título" — labels: ...

## Pendientes de mi review (N)
- ...

## Mergeados recientes (7 días) (N)
- [#1230 <org>/<repo>](...) — Merged 2026-05-27 — "Título"
```

### Paso 4: Detectar cambios

Comparar con el snapshot anterior antes de sobrescribir: reviews nuevos, PRs mergeados, Draft → Ready.

### Paso 5: Reportar

```
✓ GitHub sincronizado:
- N PRs abiertos como autor en M proyectos
- K pendientes de tu review
- J mergeados en los últimos 7 días
- Cambios: +X nuevos / ✓Y mergeados / 🔄 Z transiciones
- L sin mapeo → 3-recursos/inbox-github.md
```

## Reglas

- **Solo lectura** sobre GitHub.
- Si `gh` falla por permisos, sugerir `gh auth status`.
- Si se corrió hace menos de 15 minutos, preguntar antes de refrescar.

## Aprendizajes

*(Se acumulan errores encontrados al ejecutar esta skill y cómo se resolvieron. Ver la regla en el `AGENTS.md` raíz.)*
