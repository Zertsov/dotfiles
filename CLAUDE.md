# Dotfiles

Personal dotfiles for cross-platform (macOS + Linux/WSL) shell setup.

## Structure

| File | Purpose |
|------|---------|
| `.alias` | Shell aliases (sourced by `.zshrc`) |
| `.funcs` | Custom zsh functions (sourced by `.zshrc`) |
| `.zshrc` | Main zsh config — prompt, sources alias/funcs, PATH setup |
| `run.sh` | Idempotent bootstrap script |

## How setup works

`run.sh` is the single entrypoint:
- Copies `.alias`, `.funcs`, `.zshrc` to `$HOME` only if missing or drifted (`diff -q`)
- Creates `~/git` and `~/sandbox` directories
- macOS: installs Homebrew if absent, then installs tools via `brew install` (skips if already present)
- Linux: installs via `apt-get` / `curl` installers (skips if command already exists)
- Installs Node LTS via `fnm` (skips if already installed)

## Tools managed

- `fnm` — Node version manager
- `ripgrep` — required (`.alias` remaps `grep` to `rg`)
- `neovim` — primary editor (aliased as `vim`)
- `pnpm` — preferred Node package manager (aliased as `pn`)
- Neovim config lives externally: `git@github.com:Zertsov/kickstart.nvim.git` → `~/.config/nvim`

## Cross-platform notes

`.alias` and `.zshrc` use `$OSTYPE` guards for platform-specific behavior:
- Clipboard: `pbcopy` on macOS, `xclip`/`xsel` on Linux
- Lock screen: `pmset displaysleepnow` on macOS, `loginctl lock-session` on Linux
- Local IP: `ipconfig getifaddr en0` on macOS, `hostname -I` on Linux
- PNPM home: `~/Library/pnpm` on macOS, `~/.local/share/pnpm` on Linux
- Finder aliases (`show`, `hide`, `dsclean`) are macOS-only

## Key aliases / functions

| Name | Expands to |
|------|-----------|
| `cc` | `claude --dangerously-skip-permissions` |
| `cmb` | `clean_local_branches` — prunes local branches whose remotes are gone |
| `gaf` | `git_add_by_partial_filename` — git add by partial filename via ripgrep |
| `pn` | `pnpm` |
| `gs/ga/gc/gp/co` | common git shorthands |

## Making changes

1. Edit files in this repo
2. Run `./run.sh` to sync to `$HOME` (only changed files will be updated)
3. `source ~/.zshrc` or restart shell to pick up changes
