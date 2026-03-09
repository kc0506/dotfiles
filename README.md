# dotfiles

Managed with [chezmoi](https://www.chezmoi.io/).

## Setup

### WSL

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply kc0506
```

### CSIE workstation

> Workarounds with such a tiny quota on the NFS home directory is just painful...

Home directory is shared across machines with limited space. Large directories are symlinked to `/tmp2` (per-machine disk). Chezmoi source is stored on `/tmp2` to avoid conflicts with `.local/share` symlink.

```bash
curl -fsSL https://raw.githubusercontent.com/kc0506/dotfiles/main/setup-csie.sh | bash
```

Symlinks are created automatically by the `run_onchange_00` script. If a target path already exists as a real directory, the script will abort — remove it manually first.

## Machine types

Configured via `chezmoi init` prompt (`machine_type`):

- **wsl** — WSL on Windows, has sudo, includes `ivk()`, `winexec` plugin
- **csie** — CSIE DL workstation, no sudo, conda/mamba, symlinks to `/tmp2`

## Auto-install scripts

Executed in order:

| Script | Description |
|--------|-------------|
| `00-symlinks-to-tmp2` | Symlink large dirs to `/tmp2` (csie only, run_onchange) |
| `01-install-oh-my-zsh` | oh-my-zsh + external plugins |
| `02-install-mise` | mise + all tools (chezmoi, uv, just, zellij, nvim, node, python) |
| `03-install-npm-globals` | pnpm |
| `04-install-rustup` | Rust toolchain |
| `05-install-miniforge` | Miniforge3 (csie only) |
| `06-install-claude-code` | Claude Code CLI |
