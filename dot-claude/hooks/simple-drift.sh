#!/usr/bin/env bash
# UserPromptSubmit hook — simple-mode scope-creep detector.
# Active only when $CLAUDE_MODE is unset or "simple".
# First trip: inject nudge via systemMessage. Second trip in the same session: block the prompt.
# To unblock: switch modes (cck/cce/ccw) or rephrase.

set -euo pipefail

mode="${CLAUDE_MODE:-simple}"
[[ "$mode" != "simple" ]] && exit 0

input="$(cat)"
prompt="$(printf '%s' "$input" | jq -r '.prompt // ""')"
session_id="$(printf '%s' "$input" | jq -r '.session_id // "nosession"')"

state_file="/tmp/claude-drift-${session_id}"
lower="$(printf '%s' "$prompt" | tr '[:upper:]' '[:lower:]')"

arch_re='(architecture|architectural|refactor|redesign|abstraction|design pattern|hexagonal|should we |what.?s the (best|right) (way|approach)|best approach to|how should (i|we) (design|structure|model|architect))'
explore_re='(^|[^a-z])(how does|how do|why does|why do|why is|why are|explain |what is |what.?s the )'

drift=0
printf '%s' "$lower" | grep -qE "$arch_re"    && drift=1
printf '%s' "$lower" | grep -qE "$explore_re" && drift=1

if [[ "$drift" -eq 0 ]]; then
  rm -f "$state_file" 2>/dev/null || true
  exit 0
fi

read -r -d '' NUDGE <<'EOF' || true
[drift detector] This prompt looks like it leaves simple-mode scope (architectural language or open-ended/exploratory phrasing detected). Consider switching modes:
  cck — professor (concept building, socratic)
  cce — engineer  (design + implementation)
  ccw — scribe    (article structure, source aggregation)
If this really is a rote task, rephrase to avoid trigger words and re-submit.
EOF

if [[ -f "$state_file" ]]; then
  # Second strike — block.
  jq -n --arg reason "$NUDGE" '{
    decision: "block",
    reason: ($reason + "\n\n[blocked: drift detected twice in a row]"),
    suppressOriginalPrompt: false,
    hookSpecificOutput: { hookEventName: "UserPromptSubmit" }
  }'
  rm -f "$state_file" 2>/dev/null || true
  exit 0
fi

# First strike — nudge, mark state.
touch "$state_file"
jq -n --arg msg "$NUDGE" '{
  systemMessage: $msg,
  hookSpecificOutput: { hookEventName: "UserPromptSubmit", additionalContext: $msg }
}'
exit 0
