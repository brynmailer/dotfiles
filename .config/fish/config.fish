set -g fish_greeting

if status is-interactive
  # Commands to run in interactive sessions can go here
  fish_vi_key_bindings

  # Wal colors
  cat ~/.cache/wal/sequences
  source ~/.cache/wal/colors.fish

  alias get_idf=". $HOME/Tools/esp-idf/export.fish"
end
