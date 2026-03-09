#!/usr/bin/env zsh
# ~/.oh-my-zsh/custom/plugins/winexec/winexec.plugin.zsh

# --- Config ---
WINEXEC_CACHEFILE="$HOME/.cache/winexec_commands.txt"
WINEXEC_UPDATER="$WINEXEC_PLUGIN_DIR/bin/update-win-cmds"

# --- Command definition ---
win() {
  local cmd="$1"
  shift
  if [[ -z "$cmd" ]]; then
    echo "Usage: win <command> [args...]" >&2
    return 1
  fi
  /mnt/c/Users/kc0506/scoop/shims/pwsh.exe -NoProfile -c "$cmd" "$@" 
}

# Optional alias so you can type win:code
alias win:='win '

# --- Completion system ---
_winexec_complete() {
  local -a cmds
  [[ -f "$WINEXEC_CACHEFILE" ]] || "$WINEXEC_UPDATER" >/dev/null 2>&1
  cmds=(${(f)"$(<"$WINEXEC_CACHEFILE")"})
  compadd -a cmds
}
compdef _winexec_complete win win:


# --- Cache refresh (async on first load) ---
if [[ ! -f "$WINEXEC_CACHEFILE" || -n $(find "$WINEXEC_CACHEFILE" -mtime +7 2>/dev/null) ]]; then
  nohup "$WINEXEC_UPDATER" >/dev/null 2>&1 & disown
fi

