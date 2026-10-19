#!/bin/bash
set -e

SYMLINK_BASE="/tmp2/$(whoami)/.symlinks"
CHEZMOI_CONFIG_DIR="$SYMLINK_BASE/.config/chezmoi"
CHEZMOI_SOURCE="/tmp2/$(whoami)/.chezmoi-source"

# Symlink chezmoi config/state to /tmp2 (must be per-machine)
mkdir -p "$CHEZMOI_CONFIG_DIR"
mkdir -p "$HOME/.config"
ln -sfn "$CHEZMOI_CONFIG_DIR" "$HOME/.config/chezmoi"

# Pre-set machine_type so chezmoi doesn't prompt
if [ ! -f "$CHEZMOI_CONFIG_DIR/chezmoi.toml" ]; then
  cat > "$CHEZMOI_CONFIG_DIR/chezmoi.toml" << 'EOF'
[data]
    machine_type = "csie"
EOF
fi

# Reuse an existing clone (keeps local commits/edits); only re-clone if broken.
if git -C "$CHEZMOI_SOURCE" rev-parse --git-dir >/dev/null 2>&1; then
  git -C "$CHEZMOI_SOURCE" pull --ff-only
else
  rm -rf "$CHEZMOI_SOURCE"
fi

# Install chezmoi and init
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --source "$CHEZMOI_SOURCE" kc0506

# Clean up bootstrap chezmoi (mise installs its own)
rm -f "$HOME/bin/chezmoi"
