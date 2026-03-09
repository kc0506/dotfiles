#!/bin/bash

echo ">>> [06] Installing claude code..."
if ! command -v claude &>/dev/null; then
  curl -fsSL https://claude.ai/install.sh | bash
fi
