#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Helpers ────────────────────────────────────────────────────────────────

log() { echo "[dotfiles] $*"; }

# Detect OS
detect_os() {
    case "$OSTYPE" in
        darwin*) echo "mac" ;;
        linux*)  echo "linux" ;;
        *)       echo "unknown" ;;
    esac
}
OS="$(detect_os)"

# Copy dotfile only if missing or drifted
install_dotfile() {
    local src="$DOTFILES_DIR/$1"
    local dest="$HOME/$1"

    if [[ ! -f "$dest" ]]; then
        log "Installing $1 (new)"
        cp "$src" "$dest"
    elif ! diff -q "$src" "$dest" &>/dev/null; then
        log "Updating $1 (drift detected)"
        cp "$src" "$dest"
    else
        log "Skipping $1 (up to date)"
    fi
}

# Install a brew formula only if not already present
brew_install() {
    if brew list "$1" &>/dev/null 2>&1; then
        log "Skipping brew:$1 (already installed)"
    else
        log "Installing brew:$1"
        brew install "$1"
    fi
}

# ─── Dotfiles ───────────────────────────────────────────────────────────────

install_dotfile .alias
install_dotfile .funcs
install_dotfile .zshrc

# ─── Directories ────────────────────────────────────────────────────────────

mkdir -p "$HOME/git"
mkdir -p "$HOME/sandbox"

# ─── macOS ──────────────────────────────────────────────────────────────────

if [[ "$OS" == "mac" ]]; then
    if ! command -v brew &>/dev/null; then
        log "Installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo >> "$HOME/.zprofile"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        log "Skipping Homebrew (already installed)"
    fi

    brew_install fnm
    brew_install ripgrep
    brew_install neovim
    brew_install pnpm
fi

# ─── Linux ──────────────────────────────────────────────────────────────────

if [[ "$OS" == "linux" ]]; then
    if command -v apt-get &>/dev/null; then
        command -v rg    &>/dev/null || { log "Installing ripgrep"; sudo apt-get install -y ripgrep; }
        command -v nvim  &>/dev/null || { log "Installing neovim";  sudo apt-get install -y neovim;  }
    fi

    if ! command -v fnm &>/dev/null; then
        log "Installing fnm"
        curl -fsSL https://fnm.vercel.app/install | bash
    else
        log "Skipping fnm (already installed)"
    fi

    if ! command -v pnpm &>/dev/null; then
        log "Installing pnpm"
        curl -fsSL https://get.pnpm.io/install.sh | sh -
    else
        log "Skipping pnpm (already installed)"
    fi
fi

# ─── Node ───────────────────────────────────────────────────────────────────

if command -v fnm &>/dev/null; then
    eval "$(fnm env --use-on-cd --shell bash)"
    if ! fnm list | grep -q "lts-latest" 2>/dev/null; then
        log "Installing Node LTS via fnm"
        fnm install --lts
    else
        log "Skipping Node (already installed)"
    fi
fi

# ─── Done ───────────────────────────────────────────────────────────────────

log ""
log "Done. Next steps:"
log "  1. Restart shell or: source ~/.zshrc"
log "  2. Install neovim config: git clone git@github.com:Zertsov/kickstart.nvim.git ~/.config/nvim"
log "  3. Generate SSH keys if needed: ssh-keygen -t ed25519 -C 'your@email.com'"
