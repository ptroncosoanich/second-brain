---
name: donde-esta
description: "Busca un concepto en el brain local; si no encuentra suficiente, escala a Buk Atlas"
---

<!-- generado por .agents/sync-skills.sh desde .claude/commands/donde-esta.md; no editar a mano -->

# $donde-esta

Esta skill está definida en `.claude/commands/donde-esta.md`, compartida con Claude Code. Lee ese archivo completo y sigue sus instrucciones.

Argumentos esperados: `<concepto o pregunta>`

- Donde el archivo diga `$ARGUMENTS`, usa el texto que el usuario escribió después de `$donde-esta` (vacío si no escribió nada).
- Donde mencione `/<skill>`, se refiere a la skill `$<skill>` de este mismo directorio.
- Si nombra herramientas propias de Claude Code (subagentes, `AskUserQuestion`, `TodoWrite`, conectores `mcp__claude_ai_*`), usa lo equivalente que tengas: preguntar en el chat, hacer el trabajo en secuencia o avisar que falta el conector.
- Si la skill pide registrar un aprendizaje, edita `.claude/commands/donde-esta.md`, no este adaptador.
