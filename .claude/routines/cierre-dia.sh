#!/bin/bash
# Wrapper de la rutina /cierre-dia. Lo ejecuta launchd (macOS) o cron (Linux) según lo
# que instale instalar-rutina.sh, y también se puede correr a mano para probar.
#
# Uso: cierre-dia.sh [YYYY-MM-DD]     (sin fecha procesa hoy)
# Log: ~/Library/Logs/cierre-dia/YYYY-MM-DD.log (macOS) o ~/.local/state/cierre-dia/ (Linux)

set -uo pipefail

# Rutas derivadas del usuario y de la ubicación del script: sirven en cualquier máquina.
export HOME="${HOME:-$(cd ~ && pwd)}"
BRAIN_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
if [ "$(uname -s)" = "Darwin" ]; then
  LOG_DIR="$HOME/Library/Logs/cierre-dia"
else
  LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/cierre-dia"
fi
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$(date +%Y-%m-%d).log"

# launchd y cron arrancan con un PATH mínimo. Se usa el PATH del shell de login para que
# claude encuentre gws (script de Node que necesita sus shims), gh, acli y bq igual que
# en la terminal. Si falla, queda un PATH base razonable.
LOGIN_SHELL="${SHELL:-/bin/zsh}"
[ -x "$LOGIN_SHELL" ] || LOGIN_SHELL=/bin/bash
LOGIN_PATH="$("$LOGIN_SHELL" -lic 'printf "%s\n" "$PATH"' 2>/dev/null </dev/null | tail -1)"
export PATH="${LOGIN_PATH:-$HOME/.local/bin:$HOME/.nodenv/shims:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin}"

FECHA="${1:-}"
[ -t 1 ] && echo "Corriendo /cierre-dia ${FECHA:-de hoy}. Log: $LOG_FILE"

{
  echo "==== /cierre-dia ${FECHA} — $(date) ===="
  for c in claude gws gh acli bq python3; do
    echo "$c: $(command -v "$c" || echo NO_ENCONTRADO)"
  done
  echo "brain: $BRAIN_DIR"
  echo "------"

  cd "$BRAIN_DIR" || { echo "FATAL: no pude entrar a $BRAIN_DIR"; exit 1; }
  command -v claude >/dev/null || { echo "FATAL: no encontré claude en el PATH del shell de login"; exit 1; }
  if grep -q "COMPLETAR" perfil.md; then
    echo "FATAL: perfil.md todavía tiene campos COMPLETAR. Corre /configurar antes de usar la rutina."
    exit 1
  fi
  if [ ! -f organizacion.md ]; then
    echo "AVISO: falta organizacion.md (pídeselo a Pablo Troncoso). La rutina sigue, sin Jira, GitHub ni Buk Atlas."
  fi

  # Requisito: haber abierto Claude Code una vez en esta carpeta y aceptado el diálogo de
  # confianza. Sin eso, claude --print ignora los permisos de .claude/settings.json y
  # rechaza todos los comandos de gws, gh y acli.
  # python3 se permite solo en esta corrida: el barrido paralelo de Chat lo necesita
  # y no hay nadie para aprobar el permiso.
  claude \
    --print \
    --permission-mode acceptEdits \
    --allowedTools "Bash(python3:*)" \
    --output-format text \
    --append-system-prompt "Estás corriendo como rutina automática de /cierre-dia, sin usuario interactivo. Sigue .claude/commands/cierre-dia.md con los datos de perfil.md. No pidas confirmaciones: lo que la requiera (crear un proyecto nuevo, por ejemplo) déjalo propuesto en 3-recursos/inbox.md y en el reporte. Al terminar imprime el reporte del Paso 8. Si algo falla, deja en el log qué falló y por qué." \
    "/cierre-dia ${FECHA}" </dev/null
  echo "==== fin: $(date) ===="
} >> "$LOG_FILE" 2>&1
