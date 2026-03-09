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

# Clean previous source if exists (ensure fresh clone)
rm -rf "$CHEZMOI_SOURCE"

# Install chezmoi and init
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --source "$CHEZMOI_SOURCE" kc0506

# Clean up bootstrap chezmoi (mise installs its own)
rm -f "$HOME/bin/chezmoi"
