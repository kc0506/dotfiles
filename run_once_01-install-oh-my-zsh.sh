#!/bin/bash

echo ">>> [01] Installing oh-my-zsh..."
# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install external plugins
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-python-module-completion" ]; then
  git clone https://github.com/UshioA/zsh-python-module-completion.git \
    "$HOME/.oh-my-zsh/custom/plugins/zsh-python-module-completion"
fi
