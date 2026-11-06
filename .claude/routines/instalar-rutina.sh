#!/bin/bash
# Instala, desinstala o muestra la rutina diaria de /cierre-dia.
#   macOS: LaunchAgent en ~/Library/LaunchAgents, cargado con launchctl.
#   Linux: una línea en el crontab del usuario.
#
# Uso:
#   instalar-rutina.sh [HH:MM] [--dias 1-5]   instala o reinstala (default 19:00, lunes a viernes)
#   instalar-rutina.sh --estado               muestra si está instalada
#   instalar-rutina.sh --desinstalar          la quita (por ejemplo, en vacaciones)
#
# Días: 1 = lunes … 5 = viernes, 6 = sábado, 0 = domingo. Rangos y listas: 1-5, 1,3,5.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WRAPPER="$SCRIPT_DIR/cierre-dia.sh"
LABEL="com.second-brain.cierre-dia"
MARCA="# second-brain:cierre-dia"
HORA="19:00"
DIAS="1-5"
ACCION="instalar"

while [ $# -gt 0 ]; do
  case "$1" in
    --desinstalar) ACCION="desinstalar" ;;
    --estado) ACCION="estado" ;;
    --dias) DIAS="${2:?falta el valor de --dias}"; shift ;;
    [0-9]*:[0-9]*) HORA="$1" ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "Argumento desconocido: $1 (ver --help)"; exit 1 ;;
  esac
  shift
done

if ! [[ "$HORA" =~ ^([01]?[0-9]|2[0-3]):[0-5][0-9]$ ]]; then
  echo "Hora inválida: $HORA (formato HH:MM)"; exit 1
fi
if ! [[ "$DIAS" =~ ^[0-7]([-,][0-7])*$ ]]; then
  echo "Días inválidos: $DIAS (ej. 1-5 o 1,3,5)"; exit 1
fi
H=$((10#${HORA%%:*}))
M=$((10#${HORA##*:}))

# Expande "1-5" o "1,3,5" a una lista de días.
expandir_dias() {
  local parte desde hasta d out=""
  IFS=',' read -ra partes <<< "$1"
  for parte in "${partes[@]}"; do
    if [[ "$parte" == *-* ]]; then
      desde=${parte%-*}; hasta=${parte#*-}
      for ((d = desde; d <= hasta; d++)); do out+="$d "; done
    else
      out+="$parte "
    fi
  done
  echo "$out"
}

instalar_macos() {
  local plist="$HOME/Library/LaunchAgents/$LABEL.plist"
  local logs="$HOME/Library/Logs/cierre-dia"
  local wrapper_xml="${WRAPPER//&/&amp;}"
  local intervalos="" d
  for d in $(expandir_dias "$DIAS"); do
    intervalos+="    <dict><key>Weekday</key><integer>$d</integer><key>Hour</key><integer>$H</integer><key>Minute</key><integer>$M</integer></dict>
"
  done
  mkdir -p "$HOME/Library/LaunchAgents" "$logs"
  cat > "$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$wrapper_xml</string>
  </array>
  <key>StartCalendarInterval</key>
  <array>
$intervalos  </array>
  <key>StandardOutPath</key>
  <string>$logs/launchd.out.log</string>
  <key>StandardErrorPath</key>
  <string>$logs/launchd.err.log</string>
</dict>
</plist>
EOF
  plutil -lint "$plist" >/dev/null
  launchctl bootout "gui/$(id -u)" "$plist" 2>/dev/null || true
  launchctl bootstrap "gui/$(id -u)" "$plist"
  echo "✓ Rutina instalada: $HORA, días $DIAS"
  echo "  LaunchAgent: $plist"
  echo "  Logs: $logs/"
  echo "  Probar ahora: launchctl kickstart -k gui/$(id -u)/$LABEL"
}

instalar_linux() {
  command -v crontab >/dev/null || { echo "No encontré crontab. Agrega a mano: $M $H * * $DIAS /bin/bash '$WRAPPER'"; exit 1; }
  local linea="$M $H * * $DIAS /bin/bash '$WRAPPER' $MARCA"
  { crontab -l 2>/dev/null | grep -vF "$MARCA" || true; echo "$linea"; } | crontab -
  echo "✓ Rutina instalada en crontab: $HORA, días $DIAS"
  echo "  $linea"
  echo "  Logs: ${XDG_STATE_HOME:-$HOME/.local/state}/cierre-dia/"
}

case "$(uname -s)-$ACCION" in
  Darwin-instalar) instalar_macos ;;
  Darwin-desinstalar)
    plist="$HOME/Library/LaunchAgents/$LABEL.plist"
    launchctl bootout "gui/$(id -u)" "$plist" 2>/dev/null || true
    rm -f "$plist"
    echo "✓ Rutina desinstalada (para reactivarla, vuelve a correr este script)" ;;
  Darwin-estado)
    plist="$HOME/Library/LaunchAgents/$LABEL.plist"
    if [ -f "$plist" ] && launchctl print "gui/$(id -u)/$LABEL" >/dev/null 2>&1; then
      valor() { grep -o "$1</key><integer>[0-9]*" "$plist" | grep -o '[0-9]*$'; }
      printf '✓ Instalada: %02d:%02d, días %s\n  %s\n' \
        "$(valor Hour | head -1)" "$(valor Minute | head -1)" "$(valor Weekday | paste -sd, -)" "$plist"
    else
      echo "✗ No instalada"
    fi ;;
  *-instalar) instalar_linux ;;
  *-desinstalar)
    { crontab -l 2>/dev/null | grep -vF "$MARCA" || true; } | crontab -
    echo "✓ Rutina desinstalada del crontab" ;;
  *-estado)
    crontab -l 2>/dev/null | grep -F "$MARCA" || echo "✗ No instalada" ;;
esac
