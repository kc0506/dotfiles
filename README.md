# dotfiles

Managed with [chezmoi](https://www.chezmoi.io/).

## Setup

### WSL

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply kc0506
```

### CSIE workstation

Home directory is shared across machines with limited space. Large directories are symlinked to `/tmp2` (per-machine disk). Chezmoi source is also stored on `/tmp2` to avoid conflicts with `.local/share` symlink.

```bash
# 1. Bootstrap symlinks first (before chezmoi)
mkdir -p /tmp2/$(whoami)/.symlinks
for d in .cache .cargo .claude .rustup .npm .npm-global .local/lib .local/share .linuxbrew miniforge3; do
  target="/tmp2/$(whoami)/.symlinks/$d"
  link="$HOME/$d"
  mkdir -p "$target" "$(dirname "$link")"
  [ -L "$link" ] || [ ! -e "$link" ] && ln -sfn "$target" "$link"
done
ln -sfn "/tmp2/$(whoami)" "$HOME/tmp2"

# 2. Init chezmoi with source on /tmp2
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --source "/tmp2/$(whoami)/.chezmoi-source" kc0506
```

## Machine types

Configured via `chezmoi init` prompt (`machine_type`):

- **wsl** — WSL on Windows, has sudo, includes `ivk()`, `winexec` plugin
- **csie** — CSIE DL workstation, no sudo, brew in `~/.linuxbrew`, conda/mamba, symlinks to `/tmp2`

## Auto-install scripts

Executed in order:

| Script | Description |
|--------|-------------|
| `00-symlinks-to-tmp2` | Symlink large dirs to `/tmp2` (csie only, run_onchange) |
| `01-install-brew` | Homebrew + mise, zellij, nvim, uv, just, chezmoi |
| `02-install-oh-my-zsh` | oh-my-zsh + external plugins |
| `03-install-mise-tools` | `mise install` (node, python, etc.) |
| `04-install-npm-globals` | pnpm |
| `05-install-rustup` | Rust toolchain |
| `06-install-miniforge` | Miniforge3 (csie only) |
| `07-install-claude-code` | Claude Code CLI |
