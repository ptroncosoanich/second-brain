---
name: idea
description: "Captura una idea para un proyecto futuro con plantilla estructurada en 3-recursos/ideas-proyectos/"
---

<!-- generado por .agents/sync-skills.sh desde .claude/commands/idea.md; no editar a mano -->

# $idea

Esta skill está definida en `.claude/commands/idea.md`, compartida con Claude Code. Lee ese archivo completo y sigue sus instrucciones.

Argumentos esperados: `<concepto, slug o frase descriptiva>`

- Donde el archivo diga `$ARGUMENTS`, usa el texto que el usuario escribió después de `$idea` (vacío si no escribió nada).
- Donde mencione `/<skill>`, se refiere a la skill `$<skill>` de este mismo directorio.
- Si nombra herramientas propias de Claude Code (subagentes, `AskUserQuestion`, `TodoWrite`, conectores `mcp__claude_ai_*`), usa lo equivalente que tengas: preguntar en el chat, hacer el trabajo en secuencia o avisar que falta el conector.
- Si la skill pide registrar un aprendizaje, edita `.claude/commands/idea.md`, no este adaptador.
