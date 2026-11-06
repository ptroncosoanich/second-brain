---
name: para-init
description: "Escanea actividad reciente (Calendar, Gmail, Drive, Chat) y propone la estructura inicial de proyectos y áreas"
---

<!-- generado por .agents/sync-skills.sh desde .claude/commands/para-init.md; no editar a mano -->

# $para-init

Esta skill está definida en `.claude/commands/para-init.md`, compartida con Claude Code. Lee ese archivo completo y sigue sus instrucciones.

Argumentos esperados: `[días hacia atrás — opcional, default 14]`

- Donde el archivo diga `$ARGUMENTS`, usa el texto que el usuario escribió después de `$para-init` (vacío si no escribió nada).
- Donde mencione `/<skill>`, se refiere a la skill `$<skill>` de este mismo directorio.
- Si nombra herramientas propias de Claude Code (subagentes, `AskUserQuestion`, `TodoWrite`, conectores `mcp__claude_ai_*`), usa lo equivalente que tengas: preguntar en el chat, hacer el trabajo en secuencia o avisar que falta el conector.
- Si la skill pide registrar un aprendizaje, edita `.claude/commands/para-init.md`, no este adaptador.
