---
name: datos
description: "Consulta el data warehouse (BigQuery) traduciendo una pregunta natural a SQL; muestra el resultado y opcionalmente guarda la query en 3-recursos/queries/"
---

<!-- generado por .agents/sync-skills.sh desde .claude/commands/datos.md; no editar a mano -->

# $datos

Esta skill está definida en `.claude/commands/datos.md`, compartida con Claude Code. Lee ese archivo completo y sigue sus instrucciones.

Argumentos esperados: `<pregunta o consulta en lenguaje natural>`

- Donde el archivo diga `$ARGUMENTS`, usa el texto que el usuario escribió después de `$datos` (vacío si no escribió nada).
- Donde mencione `/<skill>`, se refiere a la skill `$<skill>` de este mismo directorio.
- Si nombra herramientas propias de Claude Code (subagentes, `AskUserQuestion`, `TodoWrite`, conectores `mcp__claude_ai_*`), usa lo equivalente que tengas: preguntar en el chat, hacer el trabajo en secuencia o avisar que falta el conector.
- Si la skill pide registrar un aprendizaje, edita `.claude/commands/datos.md`, no este adaptador.
