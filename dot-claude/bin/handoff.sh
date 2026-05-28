#!/usr/bin/env bash
# Hand off to a new agent in the secondary pane of the current tmux window.
# Usage: handoff.sh <agent-name> [context-file]
#
# - Must be run inside tmux.
# - Kills every pane in the current window except the caller, enforcing the
#   "at most two panes" workflow.
# - Splits horizontally and launches `claude --agent <agent>`.
# - If a context file is given, the new session's system prompt is appended
#   with its contents via --append-system-prompt-file.

set -euo pipefail

agent="${1:?usage: handoff.sh <agent-name> [context-file]}"
context_file="${2:-}"

if [[ -z "${TMUX:-}" ]]; then
  echo "handoff.sh: not in tmux; cannot split pane." >&2
  exit 1
fi

current_pane="$(tmux display-message -p '#{pane_id}')"

while IFS= read -r pid; do
  [[ "$pid" != "$current_pane" ]] && tmux kill-pane -t "$pid"
done < <(tmux list-panes -F '#{pane_id}')

cmd="env CLAUDE_MODE=engineer claude --agent $(printf %q "$agent")"
if [[ -n "$context_file" ]]; then
  if [[ ! -f "$context_file" ]]; then
    echo "handoff.sh: context file not found: $context_file" >&2
    exit 1
  fi
  cmd="$cmd --append-system-prompt-file $(printf %q "$context_file")"
fi

tmux split-window -h -t "$current_pane" "$cmd"
