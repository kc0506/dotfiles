#!/bin/bash

echo ">>> [07] Generating zsh completions..."
# Generate zsh completions for tools installed via mise

# chezmoi runs scripts in a non-interactive shell where mise is not activated,
# so mise-managed tools (just, uv, ...) are not on PATH by default. Add mise
# shims (and ~/.local/bin for mise itself) so `command -v <tool>` finds them.
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

ZFUNC="$HOME/.zfunc"
mkdir -p "$ZFUNC"

command -v chezmoi &>/dev/null && chezmoi completion zsh > "$ZFUNC/_chezmoi"
command -v just &>/dev/null && just --completions zsh > "$ZFUNC/_just"
command -v uv &>/dev/null && uv generate-shell-completion zsh > "$ZFUNC/_uv"
command -v zellij &>/dev/null && zellij setup --generate-completion zsh > "$ZFUNC/_zellij"
command -v cc-link &>/dev/null && SHELL=/bin/zsh cc-link --show-completion > "$ZFUNC/_cc-link" 2>/dev/null

exit 0
