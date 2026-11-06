---
name: revisar-pendientes
description: "Genera un documento consolidado de pendientes abiertos para edición masiva; al terminar aplica los cambios a los archivos originales"
---

<!-- generado por .agents/sync-skills.sh desde .claude/commands/revisar-pendientes.md; no editar a mano -->

# $revisar-pendientes

Esta skill está definida en `.claude/commands/revisar-pendientes.md`, compartida con Claude Code. Lee ese archivo completo y sigue sus instrucciones.

Argumentos esperados: `[filtro opcional: "sin-procesar" | "priorizados" | "<slug-proyecto>"]`

- Donde el archivo diga `$ARGUMENTS`, usa el texto que el usuario escribió después de `$revisar-pendientes` (vacío si no escribió nada).
- Donde mencione `/<skill>`, se refiere a la skill `$<skill>` de este mismo directorio.
- Si nombra herramientas propias de Claude Code (subagentes, `AskUserQuestion`, `TodoWrite`, conectores `mcp__claude_ai_*`), usa lo equivalente que tengas: preguntar en el chat, hacer el trabajo en secuencia o avisar que falta el conector.
- Si la skill pide registrar un aprendizaje, edita `.claude/commands/revisar-pendientes.md`, no este adaptador.
