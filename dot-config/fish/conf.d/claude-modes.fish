# Claude Code workflow launchers.
# Each abbreviation exports CLAUDE_MODE (drives the simple-drift hook and statusline color)
# and may select an --agent (sets the session's system prompt).

function __cc_launch -d "Launch claude with CLAUDE_MODE set and optional --agent"
    set -l mode $argv[1]
    set -l agent $argv[2]
    set -e argv[1 2]
    if test -n "$agent"
        env CLAUDE_MODE=$mode claude --agent $agent $argv
    else
        env CLAUDE_MODE=$mode claude $argv
    end
end

# Top-level modes — stage agents are dispatched by the engineer orchestrator
# via handoff.sh into the secondary pane.
abbr -a cc  '__cc_launch simple'
abbr -a ccp '__cc_launch professor professor'
abbr -a cce '__cc_launch engineer  engineer'
abbr -a ccs '__cc_launch scribe    scribe'
