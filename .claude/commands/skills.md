---
description: Lista todas las skills del workspace agrupadas por categoría
argument-hint: [categoria opcional]
category: meta
---

# /skills — Listado de skills del workspace

Tu rol: leer `.claude/commands/*.md` y mostrar las skills agrupadas por categoría, con su descripción y argumentos.

## Proceso

### Paso 1: Recolectar

Desde la raíz del brain:

```bash
cd .claude/commands && for f in *.md; do
  cat=$(awk '/^category:/ {sub(/^category: */, ""); print; exit}' "$f")
  desc=$(awk '/^description:/ {sub(/^description: */, ""); print; exit}' "$f")
  hint=$(awk '/^argument-hint:/ {sub(/^argument-hint: */, ""); print; exit}' "$f")
  printf "%s|%s|%s|%s\n" "${cat:-otros}" "${f%.md}" "$desc" "$hint"
done
```

### Paso 2: Agrupar y mostrar

Orden de categorías:

1. **bootstrap** — `🚀 Configuración`
2. **captura** — `📥 Captura rápida`
3. **routine** — `⏰ Rutinas`
4. **gestion** — `🧹 Gestión del brain`
5. **busqueda** — `🔍 Búsqueda`
6. **sync** — `🔗 Sync con sistemas externos`
7. **meta** — `🛠  Meta`
8. **otros** — `❓ Sin categoría`

```markdown
## Skills del workspace

**🚀 Configuración**
- `/configurar` — Configura el brain para su usuario...
- `/para-init [días]` — Escanea actividad reciente...

**📥 Captura rápida**
- `/capturar <texto de la nota>` — Captura rápida de una nota...

...

Total: N skills. En Codex se invocan con `$<nombre>`.
```

Mostrar `argument-hint` solo si existe. Si `$ARGUMENTS` trae una categoría, filtrar por ella.

### Paso 3: Detectar skills sin categoría

```
⚠️  N skills sin `category:` en su frontmatter: <lista>
Sugerencia: agregar `category: <bootstrap|captura|routine|gestion|busqueda|sync|meta>`.
```

Si alguna skill no tiene adaptador en `.agents/skills/`, sugerir `bash .agents/sync-skills.sh`.

## Reglas

- Solo lectura.

## Aprendizajes

*(Se acumulan errores encontrados al ejecutar esta skill y cómo se resolvieron. Ver la regla en el `AGENTS.md` raíz.)*
