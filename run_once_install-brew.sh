#!/bin/bash

# Install Homebrew (Linuxbrew)
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
fi

# Install mise
if ! command -v mise &>/dev/null; then
  brew install mise
fi
