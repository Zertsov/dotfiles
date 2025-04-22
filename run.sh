local user_profile=

# Add local dotfiles first
cp .alias ~/.alias
cp .funcs ~/.funcs

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
