#! /usr/bin/env bash

set -euo pipefail

function save() {
  local tmux_state=$(tmux lsp -aF '#{session_name}>#{window_index}>#{window_layout}>#{pane_title}>#{pane_current_command}')
  # the object state, each key is a session name,
  # each session has a list of windows, each window has a layout and an index and a list of panes
  # each pane has a command
  local remux_state='{}'

  # Use a while loop to process each line
  while IFS= read -r line; do
    local session_name=$(echo "$line" | cut -d'>' -f1)
    local window_index=$(echo "$line" | cut -d'>' -f2)
    local window_layout=$(echo "$line" | cut -d'>' -f3)
    local pane_title=$(echo "$line" | cut -d'>' -f4)
    local pane_command=$(echo "$line" | cut -d'>' -f5)
  
    printf 'Session: %s, Window: %s, Layout: %s, Pane: %s, Command: %s\n' "$session_name" "$window_index" "$window_layout" "$pane_title" "$pane_command"

  done <<< "$tmux_state"
}

function restore() {
  printf 'Restoring tmux state...'
}

while getopts ":sr" opt; do
  case $opt in
    s)
      save
      ;;
    r)
      restore
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

