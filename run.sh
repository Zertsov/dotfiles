#!/usr/bin/env bash
set -euo pipefail

MARKER_START="# >>> dotfiles initialization (managed - do not edit) >>>"
MARKER_END="# <<< dotfiles initialization (managed - do not edit) <<<"

main() {
	local repo_dir shell_path shell_name config_file source_file

	repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	shell_path="${SHELL:-}"

	if [[ -z "$shell_path" ]]; then
		echo "Unable to determine current shell (SHELL is not set)." >&2
		exit 1
	fi

	shell_name="$(basename "$shell_path")"
	printf "Detected shell: %s\n" "$shell_name"

	case "$shell_name" in
	zsh)
		config_file="${ZDOTDIR:-$HOME}/.zshrc"
		source_file="$repo_dir/.zshrc"
		;;
	bash)
		config_file="$HOME/.bash_profile"
		source_file="$repo_dir/.bashrc"
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

	ensure_config_file "$config_file"
	remove_existing_block "$config_file"
	append_snippet "$config_file" "$repo_dir" "$source_file" "$shell_name"

	printf "Linked %s to %s\n" "$config_file" "$source_file"
}

ensure_config_file() {
	local file="$1"
	mkdir -p "$(dirname "$file")"
	if [[ ! -f "$file" ]]; then
		touch "$file"
	fi
}

remove_existing_block() {
	local file="$1"
	local tmp

	tmp="$(mktemp)"
	if [[ -f "$file" ]]; then
		awk -v start="$MARKER_START" -v end="$MARKER_END" '
			$0 == start {in_block=1; next}
			$0 == end {if (in_block) {in_block=0; next}}
			!in_block {print}
		' "$file" > "$tmp"
	fi
	if [[ -s "$tmp" ]]; then
		mv "$tmp" "$file"
	else
		# Preserve empty files
		: > "$file"
		rm -f "$tmp"
	fi
}

append_snippet() {
	local file="$1"
	local repo_dir="$2"
	local source_file="$3"
	local shell_name="$4"
	local relative_path

	relative_path="${source_file#$repo_dir/}"
	if [[ "$relative_path" == "$source_file" ]]; then
		printf "Could not determine relative path for %s within %s\n" "$source_file" "$repo_dir" >&2
		exit 1
	fi

	if [[ -s "$file" ]]; then
		printf '\n' >> "$file"
	fi

	cat <<EOF >> "$file"
$MARKER_START
export DOTFILES_DIR="$repo_dir"
export DOTFILES_SHELL="$shell_name"
dotfiles_rc="\$DOTFILES_DIR/$relative_path"
if [ -f "\$dotfiles_rc" ]; then
	. "\$dotfiles_rc"
fi
unset dotfiles_rc
$MARKER_END
EOF
}

main "$@"
