# brain-sync: commit + pull --rebase + push del brain en un solo comando.
#
# Cárgalo desde ~/.zshrc (o ~/.bashrc), con la ruta de tu brain:
#   export BRAIN_DIR="$HOME/ruta/al/brain"
#   source "$BRAIN_DIR/.claude/routines/brain-sync.sh"
#
# Uso: brain-sync ["mensaje"]   (sin mensaje usa la fecha dd/mm)

brain-sync() {
  local msg="${1:-$(date +%d/%m)}"
  local d="${BRAIN_DIR:-}"
  if [ -z "$d" ] || [ ! -d "$d/.git" ]; then
    echo "brain-sync: define BRAIN_DIR con la ruta del brain (ver .claude/routines/README.md)"
    return 1
  fi
  git -C "$d" add -A
  git -C "$d" diff --cached --quiet || git -C "$d" commit -qm "$msg"
  git -C "$d" pull --rebase -q || { echo "brain-sync: conflicto al traer cambios, resolver en $d"; return 1; }
  git -C "$d" push -q && echo "brain-sync: ok ($d)"
}
