set -g fish_greeting

fish_add_path ~/.local/bin

set -x NVM_DIR ~/.nvm
set -x MANPAGER "nvim +Man!"
set -x TINTED_TMUX_OPTION_STATUSBAR 1
set -x GPG_TTY $tty

# Fish compatibility wrapper for NVM
function nvm
  set -x current_path $(mktemp)
	bash -c "source $NVM_DIR/nvm.sh --no-use; nvm $argv; dirname \$(nvm which current) > $current_path"
	fish_add_path -m $(cat $current_path)
	rm $current_path
end

# Use Node version in .nvmrc
function load_nvm
	set -l default_node_version $(nvm version default)
	set -l node_version $(nvm version)
	set -l nvmrc_path $(bash -c "source $NVM_DIR/nvm.sh --no-use; nvm_find_nvmrc")
	if test -n "$nvmrc_path"
		set -l nvmrc_node_version $(nvm version (cat $nvmrc_path))
		if test "$nvmrc_node_version" = "N/A"
			nvm install $(cat $nvmrc_path)
		else if test "$nvmrc_node_version" != "$node_version"
			nvm use $nvmrc_node_version
		end
	else if test "$node_version" != "$default_node_version"
		echo "Reverting to default Node version"
		nvm use default
	end
end

# Fzf tmuxp workspaces
function open-workspace
  if test "$TERM_PROGRAM" != "tmux"
    fzf-workspaces
  end
end

function keychain-add
    set selected_key (ls -I 'known*' -I '*.pub' ~/.ssh | fzf)
    if test -n "$selected_key"
        keychain --eval ~/.ssh/$selected_key | source
        commandline -f repaint
    end
end

if status is-interactive
  fish_vi_key_bindings

  bind -M insert ctrl-f open-workspace
  bind -M insert ctrl-s keychain-add
end
