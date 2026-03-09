#!/bin/bash

# Install mise
if ! command -v mise &>/dev/null; then
  curl https://mise.run | sh
fi

export PATH="$HOME/.local/bin:$PATH"

# Install all tools defined in ~/.config/mise/config.toml
mise install --yes
