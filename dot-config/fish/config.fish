set -g fish_greeting

set -x SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket

# Start flavours
# End flavours

if status is-interactive
  fish_vi_key_bindings
end
