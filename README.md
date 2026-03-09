# dotfiles

Managed with [chezmoi](https://www.chezmoi.io/).

## Setup

```bash
chezmoi init --apply git@github.com:kc0506/dotfiles.git
```

Prerequisites: `brew` (Linuxbrew) should be installed first. chezmoi `run_once` scripts handle the rest.

## What's managed

### Shell

- **zshrc** - oh-my-zsh (robbyrussell theme), zellij auto-start, bun/brew/opencode PATH setup
- **bashrc** - Kali-style two-line prompt
- **zshenv** - cargo env
- **zprofile** - login shell profile loading
- **inputrc** - arrow keys for history search

### Custom shell functions (in .zshrc)

| Function | Description |
|---|---|
| `del` | Safe delete — moves files to `~/trash/` instead of `rm` |
| `ivk` | WSL `Invoke-Item` wrapper — open files/folders in Windows |
| `clresume` | Resume Claude Code session with skip-permissions |

### Custom oh-my-zsh plugins

| Plugin | Description |
|---|---|
| `mvd` | Move latest file(s) from `~/Downloads` to current dir |
| `winexec` | Run Windows executables from WSL via `win <cmd>` |
| `zsh-python-module-completion` | Completion for `python -m` (installed via git clone) |

### Neovim

LazyVim-based config with custom keymaps, autocmds, and options.

### Terminal tools

| Tool | Notable config |
|---|---|
| **zellij** | Custom keybinds (clear-defaults, vim-style navigation) |
| **btop** | Default theme, truecolor enabled |
| **htop** | Custom field layout |

### Dev tools

| Tool | Notable config |
|---|---|
| **git** | user: kc0506, global ignore for `.claude/settings.local.json` |
| **gh** | HTTPS protocol, `co` alias for `pr checkout` |
| **mise** | Runtime version manager (config managed, tools installed separately) |
| **npm** | Global prefix `~/.npm-global` |
| **Claude Code** | language: Chinese, always-thinking enabled |

### Aliases

| Alias | Target |
|---|---|
| `vim` | `nvim` |

### Environment variables

| Variable | Value |
|---|---|
| `MANPAGER` | `nvim +Man!` |
| `EDITOR` | `vim` (in bashrc) |

## Auto-install scripts

- `run_once_install-oh-my-zsh.sh` - Installs oh-my-zsh (with `KEEP_ZSHRC=yes`) and external plugins
