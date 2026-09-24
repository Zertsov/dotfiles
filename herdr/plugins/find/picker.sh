#!/usr/bin/env bash
# Lists every tab as "<workspace>  <tab>  <agent status>", fuzzy-filters with fzf,
# and focuses the selected tab.
set -euo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"

if ! command -v fzf >/dev/null; then
	echo "zertsov.find needs fzf (brew install fzf)." >&2
	read -r -n 1 -p "Press any key to close." _
	exit 1
fi

workspaces=$("$herdr" workspace list)
selection=$("$herdr" tab list | jq -r --argjson ws "$workspaces" '
	($ws.result.workspaces | map({(.workspace_id): .label}) | add) as $names
	| .result.tabs[]
	| [.tab_id, $names[.workspace_id], .label, .agent_status] | @tsv' |
	fzf --delimiter='\t' --with-nth=2.. --tabstop=4 --prompt='find> ' \
		--header='workspace / tab / agent' --layout=reverse) || exit 0

"$herdr" tab focus "$(cut -f1 <<<"$selection")" >/dev/null
