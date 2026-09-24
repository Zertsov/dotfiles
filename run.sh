#!/usr/bin/env bash
# Bootstraps this machine from the dotfiles repo. Safe to re-run.
#
#   ./run.sh              run every step
#   ./run.sh herdr nvim   run only the named steps
#
# Steps: brew shell git ghostty nvim herdr
set -euo pipefail

MARKER_START="# >>> dotfiles initialization (managed - do not edit) >>>"
MARKER_END="# <<< dotfiles initialization (managed - do not edit) <<<"
NVIM_REPO="https://github.com/Zertsov/kickstart.nvim.git"
ALL_STEPS=(brew shell git ghostty nvim herdr)

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

main() {
	local steps=("$@") step
	if [[ ${#steps[@]} -eq 0 ]]; then
		steps=("${ALL_STEPS[@]}")
	fi

	for step in "${steps[@]}"; do
		case "$step" in
		brew | shell | git | ghostty | nvim | herdr)
			printf '\n==> %s\n' "$step"
			"setup_$step"
			;;
		*)
			printf "Unknown step '%s'. Steps: %s\n" "$step" "${ALL_STEPS[*]}" >&2
			exit 1
			;;
		esac
	done
}

# Symlinks $1 (repo file) to $2. A regular file already at $2 is backed up first.
link_file() {
	local src="$1" dest="$2"
	mkdir -p "$(dirname "$dest")"
	if [[ -e "$dest" && ! -L "$dest" ]]; then
		mv "$dest" "$dest.bak.$(date +%Y%m%d%H%M%S)"
		printf "Backed up existing %s\n" "$dest"
	fi
	ln -sfn "$src" "$dest"
	printf "Linked %s -> %s\n" "$dest" "$src"
}

setup_brew() {
	if ! command -v brew >/dev/null; then
		echo "Homebrew not found. Install it from https://brew.sh, then re-run." >&2
		exit 1
	fi
	brew bundle --file="$REPO_DIR/Brewfile"
}

setup_shell() {
	local shell_name config_file source_file

	shell_name="$(basename "${SHELL:-}")"
	case "$shell_name" in
	zsh)
		config_file="${ZDOTDIR:-$HOME}/.zshrc"
		source_file="$REPO_DIR/.zshrc"
		;;
	bash)
		config_file="$HOME/.bash_profile"
		source_file="$REPO_DIR/.bashrc"
		;;
	*)
		printf "Shell '%s' is not yet supported by these dotfiles.\n" "$shell_name" >&2
		exit 1
		;;
	esac

	if [[ ! -f "$source_file" ]]; then
		printf "Expected to source '%s', but it does not exist.\n" "$source_file" >&2
		exit 1
	fi

	[[ -f "$config_file" ]] || touch "$config_file"
	remove_existing_block "$config_file"
	append_snippet "$config_file" "$shell_name" "${source_file#"$REPO_DIR"/}"
	printf "Linked %s to %s\n" "$config_file" "$source_file"
}

remove_existing_block() {
	local file="$1" tmp
	tmp="$(mktemp)"
	awk -v start="$MARKER_START" -v end="$MARKER_END" '
		$0 == start {in_block=1; next}
		$0 == end {if (in_block) {in_block=0; next}}
		!in_block {print}
	' "$file" >"$tmp"
	cat "$tmp" >"$file"
	rm -f "$tmp"
}

append_snippet() {
	local file="$1" shell_name="$2" relative_path="$3"
	if [[ -s "$file" ]]; then
		printf '\n' >>"$file"
	fi
	cat <<SNIPPET >>"$file"
$MARKER_START
export DOTFILES_DIR="$REPO_DIR"
export DOTFILES_SHELL="$shell_name"
dotfiles_rc="\$DOTFILES_DIR/$relative_path"
if [ -f "\$dotfiles_rc" ]; then
	. "\$dotfiles_rc"
fi
unset dotfiles_rc
$MARKER_END
SNIPPET
}

setup_git() {
	link_file "$REPO_DIR/git/gitconfig" "$HOME/.gitconfig"
	link_file "$REPO_DIR/git/gitignore_global" "$HOME/.gitignore_global"
	if [[ ! -f "$HOME/.gitconfig.local" ]]; then
		printf '# Machine- or work-specific git config. Included by ~/.gitconfig.\n' >"$HOME/.gitconfig.local"
		echo "Created ~/.gitconfig.local"
	fi
}

setup_ghostty() {
	local dest="$HOME/.config/ghostty/config"
	if [[ "$(uname)" == "Darwin" ]]; then
		dest="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
	fi
	link_file "$REPO_DIR/ghostty/config" "$dest"
}

setup_nvim() {
	local dest="$HOME/.config/nvim" remote
	if [[ -d "$dest/.git" ]]; then
		remote="$(git -C "$dest" remote get-url origin 2>/dev/null || true)"
		if [[ "$remote" == *"Zertsov/kickstart.nvim"* ]]; then
			echo "kickstart.nvim already cloned at $dest"
			return
		fi
	fi
	if [[ -e "$dest" ]]; then
		mv "$dest" "$dest.bak.$(date +%Y%m%d%H%M%S)"
		printf "Backed up existing %s\n" "$dest"
	fi
	git clone "$NVIM_REPO" "$dest"
}

# Symlinks the herdr config and links every plugin under herdr/plugins.
setup_herdr() {
	local plugin_dir plugin_id

	if ! command -v herdr >/dev/null; then
		echo "herdr not found (run ./run.sh brew); skipping."
		return
	fi
	command -v fzf >/dev/null || echo "Warning: fzf not found; the find plugin needs it (run ./run.sh brew)."

	link_file "$REPO_DIR/herdr/config.toml" "$HOME/.config/herdr/config.toml"

	for plugin_dir in "$REPO_DIR"/herdr/plugins/*/; do
		plugin_dir="${plugin_dir%/}"
		plugin_id="$(awk -F'"' '/^id = /{print $2; exit}' "$plugin_dir/herdr-plugin.toml")"
		# Relink so the registration points at this clone.
		herdr plugin unlink "$plugin_id" >/dev/null 2>&1 || true
		herdr plugin link "$plugin_dir" >/dev/null
		printf "Linked herdr plugin %s\n" "$plugin_id"
	done

	herdr server reload-config >/dev/null 2>&1 || true
}

main "$@"
