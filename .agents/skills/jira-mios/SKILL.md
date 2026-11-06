---
name: jira-mios
description: "Sincroniza tus tickets de Jira (asignados o reportados) al brain — escribe refs/jira.md por proyecto y reporta cambios, sin generar resumen"
---

<!-- generado por .agents/sync-skills.sh desde .claude/commands/jira-mios.md; no editar a mano -->

# $jira-mios

Esta skill está definida en `.claude/commands/jira-mios.md`, compartida con Claude Code. Lee ese archivo completo y sigue sus instrucciones.

Argumentos esperados: `[filtro opcional: "abiertos" | "review" | "sprint" | "reporter"]`

- Donde el archivo diga `$ARGUMENTS`, usa el texto que el usuario escribió después de `$jira-mios` (vacío si no escribió nada).
- Donde mencione `/<skill>`, se refiere a la skill `$<skill>` de este mismo directorio.
- Si nombra herramientas propias de Claude Code (subagentes, `AskUserQuestion`, `TodoWrite`, conectores `mcp__claude_ai_*`), usa lo equivalente que tengas: preguntar en el chat, hacer el trabajo en secuencia o avisar que falta el conector.
- Si la skill pide registrar un aprendizaje, edita `.claude/commands/jira-mios.md`, no este adaptador.
