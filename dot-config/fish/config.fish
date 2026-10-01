set -g fish_greeting

fish_add_path ~/.local/bin

set -gx PAGER "nvimpager"
set -gx TINTED_TMUX_OPTION_STATUSBAR 1
set -gx GPG_TTY $tty
set -gx AWS_PROFILE predastore
set -gx JAVA_HOME /usr/lib/jvm/default
set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket

function ssh-add-key
    set selected_key (ls -I 'config' -I 'agent' -I 'known*' -I '*.pub' ~/.ssh | fzf)
    if test -n "$selected_key"
        clear
        ssh-add ~/.ssh/$selected_key
        commandline -f repaint
    end
end

if status is-interactive
  fish_vi_key_bindings

  bind -M insert ctrl-s ssh-add-key
end
