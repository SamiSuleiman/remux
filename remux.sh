#! /usr/bin/env bash

set -euo pipefail

function save() {
  printf 'Saving tmux state...'
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

