# Dotfiles

Bootstrap your shell by sourcing the dotfiles directly from this repository
instead of copying them into `$HOME`.

## Quick start

1. Clone this repository to the machine you want to configure.
2. From the repository root, run `./run.sh`.
3. Open a new shell (or re-source the relevant config) to pick up the changes.

The script will:

- Detect the directory it lives in and the current login shell (`$SHELL`).
- Choose the appropriate shell start-up file (currently `.zshrc`; other shells
will report as unsupported until their configs are added).
- Insert or update a managed block that exports `DOTFILES_DIR` and sources the
matching configuration from this repo.

You can rerun `./run.sh` at any time—it's idempotent and will refresh the
managed block to point at the current clone location.

## Extending to additional shells

Support for a shell is enabled by adding the corresponding configuration file
to the repository (for example `.bashrc`) and re-running `./run.sh` while
that shell is your default. The script will refuse to proceed if the file it
intends to source doesn't exist, which prevents partially configured environments.
