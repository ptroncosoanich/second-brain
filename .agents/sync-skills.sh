#!/usr/bin/env bash
# Genera los adaptadores de Codex (.agents/skills/<nombre>/SKILL.md) a partir de
# las skills de Claude Code (.claude/commands/<nombre>.md), que son la fuente única.
# Idempotente: volver a ejecutar al crear, renombrar o borrar una skill.
set -euo pipefail

cd "$(dirname "$0")/.."
src=".claude/commands"
dst=".agents/skills"
marker="generado por .agents/sync-skills.sh"

# Lee un campo del frontmatter YAML (bloque entre los dos primeros ---).
field() {
  awk -v k="$1" '
    NR == 1 && $0 == "---" { inside = 1; next }
    inside && $0 == "---" { exit }
    inside && index($0, k ": ") == 1 { sub("^" k ": *", ""); print; exit }
  ' "$2"
}

# Escapa un valor para un string YAML entre comillas dobles.
yaml_quote() {
  local v="${1//\\/\\\\}"
  printf '"%s"' "${v//\"/\\\"}"
}

mkdir -p "$dst"

# Borra adaptadores generados cuya skill ya no existe (nunca toca skills hechas a mano).
for dir in "$dst"/*/; do
  [ -d "$dir" ] || continue
  name="$(basename "$dir")"
  if [ ! -f "$src/$name.md" ] && grep -qF "$marker" "$dir/SKILL.md" 2>/dev/null; then
    rm -r "$dir"
    echo "eliminado: $name"
  fi
done

for file in "$src"/*.md; do
  name="$(basename "$file" .md)"
  description="$(field description "$file")"
  hint="$(field argument-hint "$file")"
  out="$dst/$name/SKILL.md"

  if [ -f "$out" ] && ! grep -qF "$marker" "$out"; then
    echo "omitido (hecho a mano): $name"
    continue
  fi

  mkdir -p "$dst/$name"
  {
    printf -- '---\nname: %s\ndescription: %s\n---\n\n' "$name" "$(yaml_quote "$description")"
    printf '<!-- %s desde %s; no editar a mano -->\n\n' "$marker" "$file"
    printf '# $%s\n\n' "$name"
    printf 'Esta skill está definida en `%s`, compartida con Claude Code. Lee ese archivo completo y sigue sus instrucciones.\n\n' "$file"
    if [ -n "$hint" ]; then
      printf 'Argumentos esperados: `%s`\n\n' "$hint"
    fi
    printf -- '- Donde el archivo diga `$ARGUMENTS`, usa el texto que el usuario escribió después de `$%s` (vacío si no escribió nada).\n' "$name"
    printf -- '- Donde mencione `/<skill>`, se refiere a la skill `$<skill>` de este mismo directorio.\n'
    printf -- '- Si nombra herramientas propias de Claude Code (subagentes, `AskUserQuestion`, `TodoWrite`, conectores `mcp__claude_ai_*`), usa lo equivalente que tengas: preguntar en el chat, hacer el trabajo en secuencia o avisar que falta el conector.\n'
    printf -- '- Si la skill pide registrar un aprendizaje, edita `%s`, no este adaptador.\n' "$file"
  } > "$out"
  echo "ok: $name"
done
