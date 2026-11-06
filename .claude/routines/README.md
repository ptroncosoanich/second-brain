# Rutinas

Ejecución automática de `/cierre-dia` en tu máquina y el atajo `brain-sync`.

| Archivo | Rol |
|---|---|
| `cierre-dia.sh` | Wrapper que corre `claude --print "/cierre-dia"` con el PATH de tu shell y deja un log por día |
| `instalar-rutina.sh` | Instala, desinstala o muestra la rutina (launchd en macOS, cron en Linux) |
| `brain-sync.sh` | Función `brain-sync` para commit + pull + push del brain |

## Instalar

La hora sale de `perfil.md` §4 (por defecto, lunes a viernes a las 19:00):

```bash
bash .claude/routines/instalar-rutina.sh 19:00            # lunes a viernes
bash .claude/routines/instalar-rutina.sh 18:30 --dias 1-4 # otra hora y días
bash .claude/routines/instalar-rutina.sh --estado
bash .claude/routines/instalar-rutina.sh --desinstalar    # pausar (vacaciones)
```

Para probar sin esperar a la hora: `bash .claude/routines/cierre-dia.sh` (o `… cierre-dia.sh 2026-11-05` para otro día). En macOS también `launchctl kickstart -k gui/$(id -u)/com.second-brain.cierre-dia`.

## Requisitos

- **Claude Code CLI** (`claude`) en la máquina, aunque uses Codex para el resto: la rutina corre con `claude --print`. Con Codex solo, corre `$cierre-dia` a mano.
- **Haber abierto Claude Code una vez en la carpeta del brain y aceptado el diálogo de confianza.** Sin eso, `claude --print` ignora los permisos de `.claude/settings.json` y rechaza todos los comandos de `gws`, `gh` y `acli` (en el log aparece `Ignoring … permissions.allow entries … this workspace has not been trusted`). Si corriste `/configurar` desde Claude Code, ya está.
- `perfil.md` sin campos `COMPLETAR`: si quedan, el wrapper termina sin llamar al agente y lo deja en el log.
- `organizacion.md` en la raíz del brain. Sin él la rutina igual procesa reuniones y Chat, pero no enlaza Jira, GitHub ni Buk Atlas (queda un aviso en el log).

## Por qué local (launchd o cron) y no un agente en la nube

`/cierre-dia` necesita lo que solo existe en tu máquina: el filesystem del brain, las CLIs autenticadas (`gws`, `gh`, `acli`, `bq`) y sus credenciales en el llavero. Un agente remoto programado no tiene nada de eso.

## Logs

- macOS: `~/Library/Logs/cierre-dia/YYYY-MM-DD.log` (salida del agente) y `launchd.{out,err}.log` (errores del propio launchd).
- Linux: `~/.local/state/cierre-dia/YYYY-MM-DD.log`.

```bash
tail -100 ~/Library/Logs/cierre-dia/$(date +%Y-%m-%d).log
```

## Limitaciones

- **La máquina tiene que estar encendida y con sesión iniciada.** En macOS, si estaba dormida, launchd corre la rutina al despertar (varias ejecuciones perdidas se juntan en una); si estaba apagada, esa ejecución se pierde. Se puede recuperar con `/cierre-dia <fecha>` a mano.
- **Necesita internet** al correr, para Workspace, Jira y GitHub.
- La corrida no tiene a nadie para aprobar permisos: lo que no esté en `.claude/settings.json` (o en el `--allowedTools` del wrapper) se rechaza y queda en el log.

## Si algo falla

1. Revisar el log del día: la cabecera dice qué CLIs encontró (`NO_ENCONTRADO` = problema de PATH).
2. En macOS, revisar `launchd.err.log`. **`Operation not permitted`** suele ser la protección de macOS sobre Escritorio, Documentos y Descargas: mover el brain a otra carpeta (ej. `~/brain`) o dar "Acceso total al disco" a `/bin/bash` en Configuración del Sistema → Privacidad y seguridad. Después, reinstalar la rutina.
3. Si un comando de la skill falló, la skill debería haber registrado su `## Aprendizajes` (regla del `AGENTS.md` raíz).

## brain-sync

En `~/.zshrc` (o `~/.bashrc`):

```bash
export BRAIN_DIR="$HOME/ruta/al/brain"
source "$BRAIN_DIR/.claude/routines/brain-sync.sh"
```

Uso: `brain-sync "mensaje"` (sin mensaje usa la fecha). Hace `git add -A`, commit, `pull --rebase` y push. Útil al final del día o al cambiar de máquina.
