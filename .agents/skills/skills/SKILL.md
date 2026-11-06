---
name: skills
description: "Lista todas las skills del workspace agrupadas por categoría"
---

<!-- generado por .agents/sync-skills.sh desde .claude/commands/skills.md; no editar a mano -->

# $skills

Esta skill está definida en `.claude/commands/skills.md`, compartida con Claude Code. Lee ese archivo completo y sigue sus instrucciones.

Argumentos esperados: `[categoria opcional]`

- Donde el archivo diga `$ARGUMENTS`, usa el texto que el usuario escribió después de `$skills` (vacío si no escribió nada).
- Donde mencione `/<skill>`, se refiere a la skill `$<skill>` de este mismo directorio.
- Si nombra herramientas propias de Claude Code (subagentes, `AskUserQuestion`, `TodoWrite`, conectores `mcp__claude_ai_*`), usa lo equivalente que tengas: preguntar en el chat, hacer el trabajo en secuencia o avisar que falta el conector.
- Si la skill pide registrar un aprendizaje, edita `.claude/commands/skills.md`, no este adaptador.
