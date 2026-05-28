#!/usr/bin/env bash
# Statusline — shows $CLAUDE_MODE, cwd basename, model.

set -euo pipefail

input="$(cat)"
mode="${CLAUDE_MODE:-simple}"
cwd="$(printf '%s' "$input" | jq -r '.cwd // .workspace.current_dir // ""')"
model="$(printf '%s' "$input" | jq -r '.model.display_name // .model.id // ""')"

short_cwd="${cwd##*/}"

case "$mode" in
  simple)      color=$'\e[90m' ;;  # grey
  professor)   color=$'\e[34m' ;;  # blue
  scribe)     color=$'\e[33m' ;;  # yellow
  engineer) color=$'\e[32m' ;;  # green
  *)           color=$'\e[35m' ;;  # magenta
esac
bold=$'\e[1m'
dim=$'\e[2m'
reset=$'\e[0m'

printf '%s%s%-11s%s  %s%s%s  %s%s%s' \
  "$color" "$bold" "$mode" "$reset" \
  "$bold" "$short_cwd" "$reset" \
  "$dim" "$model" "$reset"
