---
name: pr
description: "Trae el detalle de un PR de GitHub y opcionalmente lo enlaza en refs/github.md del proyecto correcto"
---

<!-- generado por .agents/sync-skills.sh desde .claude/commands/pr.md; no editar a mano -->

# $pr

Esta skill está definida en `.claude/commands/pr.md`, compartida con Claude Code. Lee ese archivo completo y sigue sus instrucciones.

Argumentos esperados: `<número o URL del PR, ej. org/repo#1234 o URL completa>`

- Donde el archivo diga `$ARGUMENTS`, usa el texto que el usuario escribió después de `$pr` (vacío si no escribió nada).
- Donde mencione `/<skill>`, se refiere a la skill `$<skill>` de este mismo directorio.
- Si nombra herramientas propias de Claude Code (subagentes, `AskUserQuestion`, `TodoWrite`, conectores `mcp__claude_ai_*`), usa lo equivalente que tengas: preguntar en el chat, hacer el trabajo en secuencia o avisar que falta el conector.
- Si la skill pide registrar un aprendizaje, edita `.claude/commands/pr.md`, no este adaptador.
