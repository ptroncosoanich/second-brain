---
name: cierre-dia
description: "Procesa reuniones y Google Chat del día y enriquece el brain — enruta cada fuente al proyecto correcto, extrae decisiones, pendientes y conflictos"
---

<!-- generado por .agents/sync-skills.sh desde .claude/commands/cierre-dia.md; no editar a mano -->

# $cierre-dia

Esta skill está definida en `.claude/commands/cierre-dia.md`, compartida con Claude Code. Lee ese archivo completo y sigue sus instrucciones.

Argumentos esperados: `[YYYY-MM-DD | varias fechas | rango — opcional, default hoy]`

- Donde el archivo diga `$ARGUMENTS`, usa el texto que el usuario escribió después de `$cierre-dia` (vacío si no escribió nada).
- Donde mencione `/<skill>`, se refiere a la skill `$<skill>` de este mismo directorio.
- Si nombra herramientas propias de Claude Code (subagentes, `AskUserQuestion`, `TodoWrite`, conectores `mcp__claude_ai_*`), usa lo equivalente que tengas: preguntar en el chat, hacer el trabajo en secuencia o avisar que falta el conector.
- Si la skill pide registrar un aprendizaje, edita `.claude/commands/cierre-dia.md`, no este adaptador.
