# dotfiles

Managed with [chezmoi](https://www.chezmoi.io/).

## Setup

### WSL

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply kc0506
```

### CSIE workstation

Home directory is shared across machines with limited space. Large directories are symlinked to `/tmp2` (per-machine disk). Chezmoi source is stored on `/tmp2` to avoid conflicts with `.local/share` symlink.

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --source "/tmp2/$(whoami)/.chezmoi-source" kc0506
```

Symlinks are created automatically by the `run_onchange_00` script. If a target path already exists as a real directory, the script will abort — remove it manually first.

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
