---
name: capturar
description: "Captura rápida de una nota — la clasifica al proyecto o área correcto sin que tengas que elegir"
---

<!-- generado por .agents/sync-skills.sh desde .claude/commands/capturar.md; no editar a mano -->

# $capturar

Esta skill está definida en `.claude/commands/capturar.md`, compartida con Claude Code. Lee ese archivo completo y sigue sus instrucciones.

Argumentos esperados: `<texto de la nota>`

- Donde el archivo diga `$ARGUMENTS`, usa el texto que el usuario escribió después de `$capturar` (vacío si no escribió nada).
- Donde mencione `/<skill>`, se refiere a la skill `$<skill>` de este mismo directorio.
- Si nombra herramientas propias de Claude Code (subagentes, `AskUserQuestion`, `TodoWrite`, conectores `mcp__claude_ai_*`), usa lo equivalente que tengas: preguntar en el chat, hacer el trabajo en secuencia o avisar que falta el conector.
- Si la skill pide registrar un aprendizaje, edita `.claude/commands/capturar.md`, no este adaptador.
