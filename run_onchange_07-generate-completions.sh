#!/bin/bash

# Generate zsh completions for tools installed via mise

ZFUNC="$HOME/.zfunc"
mkdir -p "$ZFUNC"

command -v chezmoi &>/dev/null && chezmoi completion zsh > "$ZFUNC/_chezmoi"
command -v just &>/dev/null && just --completions zsh > "$ZFUNC/_just"
command -v uv &>/dev/null && uv generate-shell-completion zsh > "$ZFUNC/_uv"
command -v zellij &>/dev/null && zellij setup --generate-completion zsh > "$ZFUNC/_zellij"
