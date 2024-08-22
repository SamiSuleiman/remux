#! /usr/bin/env bash

set -euo pipefail

remux_state_file=~/.local/share/remux.txt

function tmux_session_exists() {
  local session_name=${1}
  return $(tmux has-session -t ${session_name} &> /dev/null && echo 0 || echo 1)
}

function save() {
  local tmux_state=$(tmux lsp -aF '#{session_name}>#{window_index}>#{window_layout}>#{pane_index}>#{pane_current_command}>#{pane_current_path}')

  mkdir -p $(dirname "${remux_state_file}")

  printf "${tmux_state}" > "${remux_state_file}"
}

function restore() {
  local remux_state=$(<"${remux_state_file}")

  if [ -z "${remux_state}" ]; then
    echo "No remux save found"
    exit 1
  fi

  while IFS= read -r line; do
    local session_name=$(echo "$line" | cut -d'>' -f1)
    local window_index=$(echo "$line" | cut -d'>' -f2)
    local window_layout=$(echo "$line" | cut -d'>' -f3)
    local pane_index=$(echo "$line" | cut -d'>' -f4)
    local pane_command=$(echo "$line" | cut -d'>' -f5)
    local pane_path=$(echo "$line" | cut -d'>' -f6)

    if ! tmux_session_exists ${session_name}; then
      tmux new-session -d -s ${session_name}
    fi 

    printf 'Session: %s, Window: %s, Layout: %s, Pane: %s, Command: %s, Path: %s\n' "${session_name}" "${window_index}" "${window_layout}" "${pane_index}" "${pane_command}" "${pane_path}"

  done <<< "${remux_state}"
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

