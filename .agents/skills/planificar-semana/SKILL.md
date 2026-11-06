---
name: planificar-semana
description: "Propone el foco de la semana leyendo todos los pendientes abiertos; los ordena por prioridad y antigüedad, los agrupa por esfuerzo y propone bloques en el calendario"
---

<!-- generado por .agents/sync-skills.sh desde .claude/commands/planificar-semana.md; no editar a mano -->

# $planificar-semana

Esta skill está definida en `.claude/commands/planificar-semana.md`, compartida con Claude Code. Lee ese archivo completo y sigue sus instrucciones.

Argumentos esperados: `[YYYY-MM-DD opcional — lunes de la semana a planificar; por defecto la semana en curso]`

- Donde el archivo diga `$ARGUMENTS`, usa el texto que el usuario escribió después de `$planificar-semana` (vacío si no escribió nada).
- Donde mencione `/<skill>`, se refiere a la skill `$<skill>` de este mismo directorio.
- Si nombra herramientas propias de Claude Code (subagentes, `AskUserQuestion`, `TodoWrite`, conectores `mcp__claude_ai_*`), usa lo equivalente que tengas: preguntar en el chat, hacer el trabajo en secuencia o avisar que falta el conector.
- Si la skill pide registrar un aprendizaje, edita `.claude/commands/planificar-semana.md`, no este adaptador.
