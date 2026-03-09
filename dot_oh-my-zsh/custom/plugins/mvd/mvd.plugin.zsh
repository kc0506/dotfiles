# ~/.oh-my-zsh/custom/plugins/mvd/mvd.plugin.zsh

# Move latest (one or more) files from ~/Downloads to a destination.
mvd() {
  local downloads_dir="$HOME/downloads"
  local history_file="$HOME/.mvd_history"
  local dest="."
  local peek=0
  local count=1

  # --- Argument parsing ---
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p|--peek)
        peek=1
        shift
        ;;
      -n)
        shift
        if [[ "$1" =~ ^[0-9]+$ ]]; then
          count="$1"
          shift
        else
          echo "❌ Invalid value for -n. Expected a number."
          return 1
        fi
        ;;
      *)
        dest="$1"
        shift
        ;;
    esac
  done

  # --- Find latest N files ---
  local files
  files=($(ls -t "$downloads_dir" 2>/dev/null | head -n "$count"))
  if (( ${#files[@]} == 0 )); then
    echo "No files found in $downloads_dir"
    return 1
  fi

  # --- Destination handling ---
  if [[ ! -d "$dest" ]]; then
    echo "❌ Destination must be a directory."
    return 1
  fi

  # --- Peek mode ---
  if (( peek )); then
    echo "📦 Will move the following files:"
    for f in "${files[@]}"; do
      echo "  $downloads_dir/$f → $dest/$f"
    done
    return 0
  fi

  # --- Move files and log history ---
  for f in "${files[@]}"; do
    local src="$downloads_dir/$f"
    local target="$dest/$f"
    if mv "$src" "$target"; then
      echo "$src|$target|$(date '+%Y-%m-%d %H:%M:%S')" >> "$history_file"
      echo "✅ Moved '$f' → '$target'"
    else
      echo "⚠️ Failed to move '$f'"
    fi
  done
}

# Undo last move (works with multiple files)
umvd() {
  local history_file="$HOME/.mvd_history"
  local count=1

  # Optional -n <number>
  if [[ "$1" == "-n" && "$2" =~ ^[0-9]+$ ]]; then
    count="$2"
  fi

  if [[ ! -f "$history_file" ]]; then
    echo "No move history found."
    return 1
  fi

  local total_lines
  total_lines=$(wc -l < "$history_file" | tr -d ' ')
  if (( total_lines == 0 )); then
    echo "No moves to undo."
    return 1
  fi

  # Read last N entries
  local lines
  lines=($(tail -n "$count" "$history_file"))

  # Remove last N entries
  if (( total_lines > count )); then
    head -n $(( total_lines - count )) "$history_file" > "$history_file.tmp" && mv "$history_file.tmp" "$history_file"
  else
    > "$history_file"
  fi

  # Undo in reverse order
  for (( i=${#lines[@]}-1; i>=0; i-- )); do
    local entry="${lines[$i]}"
    local original moved_to
    IFS='|' read -r original moved_to _ <<< "$entry"

    if [[ ! -f "$moved_to" ]]; then
      echo "⚠️ File missing at destination: $moved_to"
      continue
    fi

    mv "$moved_to" "$original" && echo "↩️ Restored '$moved_to' → '$original'"
  done
}

# Show history nicely
lsmvd() {
  local history_file="$HOME/.mvd_history"
  [[ -f "$history_file" ]] || { echo "No move history."; return; }

  echo "📜 Move History:"
  column -t -s '|' "$history_file" | awk '{printf "%-60s %-60s %s\n", $1, $2, $3}'
}

alias mvd="mvd"
alias umvd="umvd"
alias lsmvd="lsmvd"

compdef _path_files mvd
