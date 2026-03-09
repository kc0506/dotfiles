#!/bin/bash

echo ">>> [03] Installing npm globals..."
export PATH="$HOME/.local/bin:$PATH"
eval "$(mise activate bash)"

npm install -g pnpm
