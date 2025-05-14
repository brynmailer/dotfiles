set -g fish_greeting

set -x SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket

# Execute Node Version Manager via Bash
function nvm
  set -x NVM_DIR $XDG_CONFIG_HOME/nvm
  if test -x $NVM_DIR/nvm.sh
    bash -c "source $NVM_DIR/nvm.sh; nvm $argv"
  end
end

if status is-interactive
  fish_vi_key_bindings
end
