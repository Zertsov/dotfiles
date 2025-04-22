# Add local dotfiles first
cp .alias ~/.alias
cp .funcs ~/.funcs

# Make logical directories for things
mkdir -p /Users/voz/git
mkdir -p /Users/voz/sandbox

# Get Brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Do the brew things
echo >> /Users/voz/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/voz/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install Brew things
brew install fnm     # fast node manager
brew install ripgrep # better grep
brew install neovim  # better vim
brew install pnpm    # better npm

# Get fnm completions
fnm completions --shell zsh

# Install latest Node
fnm i $(fnm list-remote | tail -n 1)

# Use fnm on `cd` into an appropriate dir
echo 'eval "$(fnm env --use-on-cd --shell zsh)"' >> /Users/voz/.zshrc

echo "Now - install kickstart neovim from git@github.com:Zertsov/kickstart.nvim.git"
echo "You'll need to do the ssh key gen"
