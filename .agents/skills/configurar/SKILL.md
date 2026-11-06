---
name: configurar
description: "Configura el brain para su usuario — revisa organizacion.md, llena perfil.md, verifica las CLIs, crea el área del equipo, genera los adaptadores de Codex, instala la rutina y revisa que el repo sea privado"
---

<!-- generado por .agents/sync-skills.sh desde .claude/commands/configurar.md; no editar a mano -->

# $configurar

Esta skill está definida en `.claude/commands/configurar.md`, compartida con Claude Code. Lee ese archivo completo y sigue sus instrucciones.

Argumentos esperados: `[organizacion | perfil | fuentes | parametros | estructura | codex | rutina | git — opcional, para correr un solo bloque]`

- Donde el archivo diga `$ARGUMENTS`, usa el texto que el usuario escribió después de `$configurar` (vacío si no escribió nada).
- Donde mencione `/<skill>`, se refiere a la skill `$<skill>` de este mismo directorio.
- Si nombra herramientas propias de Claude Code (subagentes, `AskUserQuestion`, `TodoWrite`, conectores `mcp__claude_ai_*`), usa lo equivalente que tengas: preguntar en el chat, hacer el trabajo en secuencia o avisar que falta el conector.
- Si la skill pide registrar un aprendizaje, edita `.claude/commands/configurar.md`, no este adaptador.
