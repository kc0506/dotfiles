#!/bin/bash

# Ensure mise is available
if ! command -v mise &>/dev/null; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
fi

# Install all tools defined in ~/.config/mise/config.toml
if command -v mise &>/dev/null; then
  mise install --yes
fi
