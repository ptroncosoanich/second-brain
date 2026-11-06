# Second Brain

> **Contexto raíz** que Claude Code y Codex cargan al abrir este workspace: las reglas del sistema y cómo configurarlo. Los datos de la persona (quién es, su equipo, sus fuentes, su portafolio) viven en [`perfil.md`](perfil.md), y los valores internos que comparte la organización (Jira, GitHub, BigQuery, Buk Atlas) en `organizacion.md`, que no está en el repo público. El detalle de cada proyecto vive en `1-proyectos/<slug>/AGENTS.md`.
>
> **No crear archivos `CLAUDE.md`** en este repo: si hay uno en la raíz, Claude Code ignora todos los `AGENTS.md`; si hay uno en una subcarpeta, ignora el `AGENTS.md` de esa carpeta.

## Antes de cualquier tarea

1. **Lee `perfil.md` y `organizacion.md`** si no los leíste en esta sesión. En este archivo y en las skills, "el usuario" es la persona de la sección 1 de `perfil.md`.
   - **Si no existe `organizacion.md`**: decirle al usuario que se lo pida a **Pablo Troncoso** y lo deje en la raíz de esta carpeta, junto a `perfil.md` (fuera de Buk: copiar `organizacion.ejemplo.md` y completarlo). Mientras falte, las skills que usan Jira, GitHub, BigQuery o Buk Atlas avisan y no se ejecutan. Nunca inventar esos valores.
2. **Si `perfil.md` todavía tiene `COMPLETAR`**, el brain no está configurado: ofrece correr `/configurar` (`$configurar` en Codex) antes de cualquier skill que dependa del perfil. Las preguntas sobre cómo configurar algo se responden con la sección [Configuración](#configuración).
3. **Antes de trabajar sobre un proyecto o área**, lee su `AGENTS.md` (Codex carga automáticamente solo los que están entre la raíz y la carpeta donde se abrió).

## Cómo trabajamos

- **Idioma**: español para todo (skills, notas, decisiones, conversaciones).
- **Brevedad**: respuestas concisas; bullets antes que prosa larga.
- **El brain es la base, no un resumen pasivo**: las rutinas actualizan archivos; las conversaciones consumen ese contexto. No producir "morning briefs" ni digests salvo que se pidan.
- **Fuentes crudas antes que IA**: al procesar reuniones, preferir siempre la transcripción verbatim sobre el resumen generado por IA, que puede omitir matices, atribuir mal compromisos o suavizar conflictos. Si solo hay resumen, marcarlo en la nota (`**Fuente**: resumen IA`).
- **Clasificación**: antes de crear una carpeta en `1-proyectos/` o `2-areas/`, confirmar con el usuario si no es obvia. Para crearla, partir de `3-recursos/plantillas/` y agregarla al portafolio de `perfil.md`.
- **Acciones externas**: SIEMPRE confirmar antes de crear Google Tasks o eventos, enviar correos o mensajes, o comentar, crear o mover tickets y PRs. Modificar los archivos del brain es libre.
- **Herramientas**: usar las de la sección 3 de `perfil.md`. Si una fuente está `inactiva`, avisar y no intentarlo; si dice `conector`, usar el conector MCP equivalente en vez de la CLI.
- **Privacidad**: el nivel de detalle en temas sensibles lo define la sección 5 de `perfil.md`. Nunca se guardan tokens ni contraseñas.
- **Idempotencia**: las rutinas deben ser seguras de re-ejecutar. Antes de agregar a `pendientes.md` o `decisiones/`, verificar duplicados.

### Las skills se auto-mejoran con errores

Si al ejecutar una skill (los `.md` de `.claude/commands/`) un comando falla con un error real (no un rechazo del usuario ni un permiso denegado), al terminar la tarea:

1. Agregar o actualizar la sección `## Aprendizajes` al final de esa skill con: **fecha**, **comando o paso que falló**, **causa raíz** y **solución aplicada o patrón a evitar**.
2. Decirlo en la respuesta final: "Actualicé la skill `<nombre>` con un aprendizaje sobre `<X>`".
3. Si el aprendizaje no depende de los datos del usuario (por ejemplo, una rareza de `gws`), sugerirle proponerlo como PR al repo plantilla para que le sirva a todo el equipo.

No aplica a errores triviales (un typo del usuario) ni a rechazos legítimos de permisos.

## Estructura PARA

```
.
├── perfil.md        # Quién eres, equipo, fuentes, parámetros y portafolio
├── organizacion.md  # Valores internos compartidos (no versionado; ver organizacion.ejemplo.md)
├── 1-proyectos/     # Activos con deadline o entregable claro
├── 2-areas/         # Responsabilidades continuas (sin deadline)
├── 3-recursos/      # Referencia transversal, plantillas, inboxes
└── 4-archivo/       # Proyectos terminados (no borrar)
```

Cada proyecto activo (`1-proyectos/<slug>/`) y cada área tienen:

- `AGENTS.md` — contexto: qué es, por qué existe, stakeholders, hitos, y los mapeos de Chat, Jira y GitHub.
- `reuniones/YYYY-MM-DD-titulo.md` — una nota por reunión.
- `chat/YYYY-MM-DD-tema.md` — síntesis de hilos relevantes de Google Chat.
- `decisiones/YYYY-MM-DD-titulo.md` — una decisión por archivo.
- `pendientes.md` — action items abiertos del usuario (ver abajo).
- `conflictos.md` — tensiones, riesgos y bloqueos.
- `refs/` — links a docs, dashboards y Buk Atlas (`README.md`), y snapshots vivos `jira.md` y `github.md`.

**Pendientes**: un solo `pendientes.md` por carpeta. Formato `` - `[TAG]` YYYY-MM-DD — texto (responsable: X, de [reunión](...)) ``, con `TAG` = `propuesto` (recién capturado) o `P1`…`P5` (priorizado por el usuario con `/revisar-pendientes`). Sin `responsable` significa que es del usuario. Los cierres automáticos de `/cierre-dia` van a una sección `## Completados` al final, con su cita de evidencia; lo que el usuario completa o descarta en `/revisar-pendientes` se elimina (el historial queda en git).

Detalle del método: [3-recursos/frameworks/PARA.md](3-recursos/frameworks/PARA.md).

**Convenciones**: fechas ISO `YYYY-MM-DD`, semanas `YYYY-Www`; slugs en kebab-case sin acentos (`onboarding-pms`, no `Onboarding PMs`).

## Skills

La fuente única de cada skill es `.claude/commands/<nombre>.md`. En Claude Code se invocan con `/<nombre>`; en Codex con `$<nombre>` (o `/skills`), a través de los adaptadores de `.agents/skills/` que genera `.agents/sync-skills.sh` (re-ejecutarlo al crear, renombrar o borrar una skill; los adaptadores no se editan a mano).

- **Configuración**: `/configurar` (primera vez y cada cambio de perfil), `/para-init` (propone proyectos y áreas desde 2 semanas de actividad), `/mapear-chat-spaces` (asocia spaces de Chat a proyectos).
- **Rutinas**: `/cierre-dia [YYYY-MM-DD]` (procesa reuniones y Chat del día, enruta cada fuente y extrae decisiones, pendientes y conflictos; pensada para correr sola L-V, ver `.claude/routines/`) y `/planificar-semana` (foco de la semana con bloques propuestos en el calendario).
- **Captura**: `/capturar "<nota>"` (clasifica una nota al lugar correcto), `/idea "<concepto>"` (idea de proyecto futuro con plantilla).
- **Gestión**: `/revisar-pendientes` (revisión masiva editando un solo documento).
- **Búsqueda**: `/donde-esta "<concepto>"` (brain y luego Buk Atlas), `/atlas "<consulta>"`.
- **Sync**: `/jira-mios`, `/jira-ticket KEY-123`, `/mis-prs`, `/pr <num-o-url>`, `/datos "<pregunta>"`, `/amplitude "<pregunta>"`.
- **Meta**: `/skills [categoria]` — lista todas las skills.

## Configuración

### Dónde vive cada cosa

| Quiero cambiar… | Dónde |
|---|---|
| Mis datos, equipo, fuentes, horarios, cupos, portafolio | `perfil.md` |
| URL de Jira, organización de GitHub, proyecto de BigQuery, ID de Buk Atlas, spaces a ignorar, catálogo de datos | `organizacion.md` (compartido: se reemplaza entero cuando hay una versión nueva) |
| La forma de un proyecto o área nuevo | `3-recursos/plantillas/` |
| Qué hace una skill | `.claude/commands/<skill>.md` (después, `bash .agents/sync-skills.sh`) |
| Qué puede hacer Claude sin preguntar | `.claude/settings.json` (compartido) o `.claude/settings.local.json` (solo tuyo, ignorado por git) |
| A qué proyecto va cada space de Chat | `/mapear-chat-spaces` → `## Spaces de Chat asociados` del `AGENTS.md` de cada destino |
| A qué proyecto va cada ticket o PR | secciones `## Jira` y `## GitHub` del `AGENTS.md` de cada proyecto |
| La hora de la rutina | `perfil.md` §4 y reinstalar con `.claude/routines/instalar-rutina.sh` |

### Primera configuración (lo que guía `/configurar`)

0. **Organización**: tener `organizacion.md` en la raíz (pedírselo a Pablo Troncoso). Con él, `/configurar` no pregunta nada de Jira, GitHub, BigQuery ni Atlas.
1. **Perfil**: nombre, cómo te nombran, email, rol, manager, reportes directos, pares, área de rituales, privacidad.
2. **Fuentes**: verificar cada CLI y su sesión — `gws calendar calendarList list --params '{"maxResults":1}'`, `gh auth status`, `acli jira workitem search --jql "assignee = currentUser()" --limit 1 --json`, `bq ls --max_results=1 --project_id=<proyecto>` — y marcar cada fuente `activa` o `inactiva`.
3. **Estructura**: crear el área de rituales del equipo y dejarla en el portafolio.
4. **Codex**: `bash .agents/sync-skills.sh`.
5. **Proyectos**: `/para-init`, después `/mapear-chat-spaces`.
6. **Rutina**: `bash .claude/routines/instalar-rutina.sh HH:MM` (launchd en macOS, `crontab` en Linux). Corre con `claude --print`: requiere Claude Code y haber aceptado su diálogo de confianza en esta carpeta.
7. **Sync**: agregar `brain-sync` a `~/.zshrc` y confirmar que el repo remoto es **privado**.

### Preguntas frecuentes

- **Qué es `organizacion.md` y por qué no está en el repo**: guarda los IDs internos de Buk (Shared Drive de Atlas, proyecto de BigQuery, catálogo de Amplitude, canal de acceso a datos, repo por defecto). El repo plantilla es público, así que esos valores se comparten aparte: pídeselo a Pablo Troncoso. Está en `.gitignore`; si tu brain es privado y quieres versionarlo, sácalo de ahí.
- **Instalar las CLIs**: `gws` y `bq` vienen con buk-cli (guía interna de Buk; `/atlas buk-cli` la encuentra). `gh`: `brew install gh && gh auth login`. `acli`: `brew tap atlassian/homebrew-acli && brew install acli`, luego `acli jira auth login --web`.
- **Uso Codex**: todas las skills funcionan con `$<nombre>`. La rutina automática igual necesita Claude Code CLI; sin él, corre `$cierre-dia` a mano al final del día.
- **No tengo Jira / no uso BigQuery**: marcar la fuente `inactiva` en `perfil.md` §3. Las skills de esa fuente avisan y terminan.
- **Prefiero conectores MCP a `gws`**: escribir `conector` en la columna Herramienta. La rutina programada necesita que el conector esté disponible en `claude --print`; si no lo está, usar `gws`.
- **Cambiar la hora de la rutina o pausarla**: editar `perfil.md` §4 y correr `bash .claude/routines/instalar-rutina.sh HH:MM`; para pausar, `bash .claude/routines/instalar-rutina.sh --desinstalar`. Detalle en `.claude/routines/README.md`.
- **Crear una skill**: un archivo nuevo en `.claude/commands/<nombre>.md` con frontmatter `description`, `argument-hint` (opcional) y `category` (`bootstrap`, `captura`, `routine`, `gestion`, `busqueda`, `sync` o `meta`), terminado en `## Aprendizajes`. Luego `bash .agents/sync-skills.sh`.
- **Traer mejoras de la plantilla**: `git remote add plantilla <url-del-repo-plantilla>` (una vez) y `git pull plantilla main --allow-unrelated-histories` la primera vez (después, solo `git pull plantilla main`). Los conflictos suelen quedar en las secciones `## Aprendizajes` (conservar los de ambos lados) y en `perfil.md` si la plantilla agrega un parámetro (conservar tus valores y sumar el nuevo).
