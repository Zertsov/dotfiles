#!/bin/sh
# Keybindings can only invoke plugin actions, so this action opens the picker pane.
exec "${HERDR_BIN_PATH:-herdr}" plugin pane open --plugin "$HERDR_PLUGIN_ID" --entrypoint picker
