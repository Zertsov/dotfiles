# Dotfiles

Shell, git, terminal, editor, and herdr config for macOS. Config files are
symlinked from this repo, so a `git pull` updates the machine in place.

## New machine

1. Install [Homebrew](https://brew.sh).
2. Clone and run the installer:

   ```sh
   git clone https://github.com/Zertsov/dotfiles.git ~/git/dotfiles
   ~/git/dotfiles/run.sh
   ```

3. Open a new shell.
4. Install Node and pnpm: `fnm install --lts && corepack enable pnpm`.
5. Put anything machine-specific in `~/.zshrc.local` and `~/.gitconfig.local`
   (see [Local overrides](#local-overrides)).

`run.sh` is safe to re-run. Any regular file it would replace is moved to
`<file>.bak.<timestamp>` first.

## What `run.sh` does

Run every step with `./run.sh`, or only some with `./run.sh <step> [<step>...]`.

| Step      | What it does |
| --------- | ------------ |
| `brew`    | `brew bundle` with the [`Brewfile`](Brewfile). |
| `shell`   | Adds a managed block to `~/.zshrc` that sources this repo's `.zshrc`. |
| `git`     | Symlinks `git/gitconfig` to `~/.gitconfig` and `git/gitignore_global` to `~/.gitignore_global`. Creates `~/.gitconfig.local`. |
| `ghostty` | Symlinks `ghostty/config` into Ghostty's config location. |
| `nvim`    | Clones [kickstart.nvim](https://github.com/Zertsov/kickstart.nvim) to `~/.config/nvim`. |
| `herdr`   | Symlinks `herdr/config.toml` to `~/.config/herdr/config.toml` and links every plugin in `herdr/plugins/`. |

## herdr

[herdr](https://herdr.dev) is installed by the `brew` step (`brew install herdr`).
The `herdr` step then links the config and plugins. To update after a pull:

```sh
./run.sh herdr
```

Plugins are linked, not installed, so edits in this repo take effect
immediately.

| Plugin | Key       | What it does |
| ------ | --------- | ------------ |
| `find` | `prefix+f` | Fuzzy-find tabs across every workspace with fzf and jump to one. |

To add a plugin, create `herdr/plugins/<name>/herdr-plugin.toml` and re-run
`./run.sh herdr`. See the [herdr plugin docs](https://herdr.dev/docs/plugins/).

## Local overrides

These files are sourced or included if they exist, and are never tracked:

- `~/.zshrc.local`: machine-specific aliases, functions, PATH entries, and
  secrets.
- `~/.gitconfig.local`: work-specific git settings (for example `url.insteadOf`
  rules).

## Adding a shell

Add the shell's config file (for example `.bashrc`) and run `./run.sh shell`
from that shell. The script refuses to continue if the file is missing.
