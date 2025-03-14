# Set Fish shell colors using pywal colors
set -U fish_color_normal {foreground.strip}
set -U fish_color_command {color4.strip}
set -U fish_color_keyword {color5.strip}
set -U fish_color_quote {color2.strip}
set -U fish_color_redirection {color1.strip}
set -U fish_color_end {color6.strip}
set -U fish_color_error {color9.strip} --bold
set -U fish_color_param {color15.strip}
set -U fish_color_comment {color8.strip}
set -U fish_color_selection {color0.strip} --background={color4.strip}
set -U fish_color_search_match --background={color3.strip}
set -U fish_color_operator {color6.strip}
set -U fish_color_escape {color5.strip}
set -U fish_color_autosuggestion {color8.strip}
set -U fish_color_valid_path --underline
set -U fish_color_history_current {color4.strip}
set -U fish_color_cancel {color9.strip}

# Pager colors
set -U fish_pager_color_progress {color8.strip}
set -U fish_pager_color_background
set -U fish_pager_color_prefix {color4.strip} --bold
set -U fish_pager_color_completion {foreground.strip}
set -U fish_pager_color_description {color8.strip}
set -U fish_pager_color_selected_background --background={color0.strip}
set -U fish_pager_color_selected_prefix {color4.strip} --bold
set -U fish_pager_color_selected_completion {foreground.strip}
set -U fish_pager_color_selected_description {color8.strip}

# Define wal colors as variables for easy use in other Fish scripts
set -U color0 {color0.strip}
set -U color1 {color1.strip}
set -U color2 {color2.strip}
set -U color3 {color3.strip}
set -U color4 {color4.strip}
set -U color5 {color5.strip}
set -U color6 {color6.strip}
set -U color7 {color7.strip}
set -U color8 {color8.strip}
set -U color9 {color9.strip}
set -U color10 {color10.strip}
set -U color11 {color11.strip}
set -U color12 {color12.strip}
set -U color13 {color13.strip}
set -U color14 {color14.strip}
set -U color15 {color15.strip}
set -U foreground {foreground.strip}
set -U background {background.strip}
set -U cursor {cursor.strip}
