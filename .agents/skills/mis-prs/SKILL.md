---
name: mis-prs
description: "Snapshot vivo de los PRs de GitHub donde eres autor o reviewer; actualiza refs/github.md por proyecto"
---

<!-- generado por .agents/sync-skills.sh desde .claude/commands/mis-prs.md; no editar a mano -->

# $mis-prs

Esta skill está definida en `.claude/commands/mis-prs.md`, compartida con Claude Code. Lee ese archivo completo y sigue sus instrucciones.

Argumentos esperados: `[filtro: "mios" | "review" | "recientes" | "<repo>"]`

- Donde el archivo diga `$ARGUMENTS`, usa el texto que el usuario escribió después de `$mis-prs` (vacío si no escribió nada).
- Donde mencione `/<skill>`, se refiere a la skill `$<skill>` de este mismo directorio.
- Si nombra herramientas propias de Claude Code (subagentes, `AskUserQuestion`, `TodoWrite`, conectores `mcp__claude_ai_*`), usa lo equivalente que tengas: preguntar en el chat, hacer el trabajo en secuencia o avisar que falta el conector.
- Si la skill pide registrar un aprendizaje, edita `.claude/commands/mis-prs.md`, no este adaptador.
