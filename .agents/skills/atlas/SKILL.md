---
name: atlas
description: "Búsqueda directa en la wiki Buk Atlas; opcionalmente guarda el link en refs/ de un proyecto"
---

<!-- generado por .agents/sync-skills.sh desde .claude/commands/atlas.md; no editar a mano -->

# $atlas

Esta skill está definida en `.claude/commands/atlas.md`, compartida con Claude Code. Lee ese archivo completo y sigue sus instrucciones.

Argumentos esperados: `<consulta>`

- Donde el archivo diga `$ARGUMENTS`, usa el texto que el usuario escribió después de `$atlas` (vacío si no escribió nada).
- Donde mencione `/<skill>`, se refiere a la skill `$<skill>` de este mismo directorio.
- Si nombra herramientas propias de Claude Code (subagentes, `AskUserQuestion`, `TodoWrite`, conectores `mcp__claude_ai_*`), usa lo equivalente que tengas: preguntar en el chat, hacer el trabajo en secuencia o avisar que falta el conector.
- Si la skill pide registrar un aprendizaje, edita `.claude/commands/atlas.md`, no este adaptador.
