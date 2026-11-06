---
name: jira-ticket
description: "Trae el detalle de un ticket de Jira y opcionalmente lo enlaza en refs/ del proyecto correcto del brain"
---

<!-- generado por .agents/sync-skills.sh desde .claude/commands/jira-ticket.md; no editar a mano -->

# $jira-ticket

Esta skill está definida en `.claude/commands/jira-ticket.md`, compartida con Claude Code. Lee ese archivo completo y sigue sus instrucciones.

Argumentos esperados: `<KEY del ticket, ej. ABC-1234>`

- Donde el archivo diga `$ARGUMENTS`, usa el texto que el usuario escribió después de `$jira-ticket` (vacío si no escribió nada).
- Donde mencione `/<skill>`, se refiere a la skill `$<skill>` de este mismo directorio.
- Si nombra herramientas propias de Claude Code (subagentes, `AskUserQuestion`, `TodoWrite`, conectores `mcp__claude_ai_*`), usa lo equivalente que tengas: preguntar en el chat, hacer el trabajo en secuencia o avisar que falta el conector.
- Si la skill pide registrar un aprendizaje, edita `.claude/commands/jira-ticket.md`, no este adaptador.
