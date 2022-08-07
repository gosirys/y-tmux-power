#!/usr/bin/env bash
#===============================================================================
#  Forked version by Osirys to support tmux-lpvpns
#===============================================================================
#  -- ORIGINAL --
#  Author: Wenxuan
#    Email: wenxuangm@gmail.com
#  Created: 2018-04-05 17:37
#===============================================================================

SDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)


# $1: option
# $2: default value
tmux_get() {
    local value="$(tmux show -gqv "$1")"
    [ -n "$value" ] && echo "$value" || echo "$2"
}

# $1: option
# $2: value
tmux_set() {
    tmux set-option -gq "$1" "$2"
}

# Options

r_sep_icon=''
l_sep_icon=''
right_arrow_icon=$(tmux_get '@tmux_power_right_arrow_icon' '')
left_arrow_icon=$(tmux_get '@tmux_power_left_arrow_icon' '')


upload_speed_icon=$(tmux_get '@tmux_power_upload_speed_icon' '')
download_speed_icon=$(tmux_get '@tmux_power_download_speed_icon' '')
session_icon="$(tmux_get '@tmux_power_session_icon' '')"
user_icon="$(tmux_get '@tmux_power_user_icon' '')"
time_icon="$(tmux_get '@tmux_power_time_icon' '')"
date_icon="$(tmux_get '@tmux_power_date_icon' '')"


show_date="$(tmux_get @tmux_power_show_date false)"
show_time="$(tmux_get @tmux_power_show_time false)"


show_upload_speed="$(tmux_get @tmux_power_show_upload_speed false)"
show_download_speed="$(tmux_get @tmux_power_show_download_speed false)"
show_web_reachable="$(tmux_get @tmux_power_show_web_reachable false)"
prefix_highlight_pos=$(tmux_get '@tmux_power_prefix_highlight_pos' 'R')
time_format=$(tmux_get @tmux_power_time_format '%T')
date_format=$(tmux_get @tmux_power_date_format '%F')

show_hackon="$(tmux_get @tmux_power_show_hackon true)"
show_lpvpns_bar="$(tmux_get @tmux_power_show_lpvpns true)"

# short for Theme-Colour
TC=$(tmux_get '@tmux_power_theme' 'gold')
case $TC in
    'gold' )
        TC='#ffb86c'
        ;;
    'redwine' )
        TC='#b34a47'
        ;;
    'moon' )
        TC='#00abab'
        ;;
    'forest' )
        TC='#228b22'
        ;;
    'violet' )
        TC='#9370db'
        ;;
    'snow' )
        TC='#fffafa'
        ;;
    'coral' )
        TC='#ff7f50'
        ;;
    'sky' )
        TC='#87ceeb'
        ;;
    'default' ) # Useful when your term changes colour dynamically (e.g. pywal)
        TC='colour3'
        ;;
    'custom' ) # Useful when your term changes colour dynamically (e.g. pywal)
        TC=$(tmux_get '@tmux_power_theme_custom' 'colour3')
        ;;
esac

G01=#080808 #232
G02=#121212 #233
G03=#1c1c1c #234
G04=#262626 #235
G05=#303030 #236
G06=#3a3a3a #237
G07=#444444 #238
G08=#4e4e4e #239
G09=#585858 #240
G10=#626262 #241
G11=#6c6c6c #242
G12=#767676 #243
G13=#fefcfc





FG=$(tmux_get '@tmx_pwr_fg' '#afdab6')
BG=$(tmux_get '@tmx_pwr_bg' '#262626')
#HG=$(tmux_get '@tmx_pwr_hg' 'colour3')
#WR=$(tmux_get '@tmx_pwr_wr' 'colour3')


# FG="$G10"
# BG="$G04"

# Status options
tmux_set status-interval 1
tmux_set status on

# Basic status bar colors
tmux_set status-fg "$FG"
tmux_set status-bg "$BG"
tmux_set status-attr none

# tmux-prefix-highlight
tmux_set @prefix_highlight_fg "$BG"
tmux_set @prefix_highlight_bg "$FG"
tmux_set @prefix_highlight_show_copy_mode 'on'
tmux_set @prefix_highlight_copy_mode_attr "fg=$TC,bg=$BG,bold"
tmux_set @prefix_highlight_output_prefix "#[fg=$TC]#[bg=$BG]$left_arrow_icon#[bg=$TC]#[fg=$BG]"
tmux_set @prefix_highlight_output_suffix "#[fg=$TC]#[bg=$BG]$right_arrow_icon"

#     
# Left side of status bar
tmux_set status-left-bg "$G04"
tmux_set status-left-fg "$G12"
tmux_set status-left-length 150
user=$(whoami)
c_session=$(tmux display-message -p '#S')

# states:
#     current_target != session_name
#     0: session_name + current_target + lp status bar
#     1: session_name + current_target

#     current_target == session_name

#     2: combined[session + target] + lp status bar
#     3: combined[session + target]

#     hackon off or hackon on but no target selected
#     4: session_name + lp status bar

#     5: nothing

if [[ "$show_hackon" ]]; then

    tf=$(tmux show-environment -g | grep -oP '(?<=current_target_file=)([^\s]+)')
    selected_target="$(cat "$tf")"

    if [[ -n "${selected_target}" ]]; then

        if [[ "$selected_target" != "$c_session" ]]; then
            dynamic_state=1
            if [[ "$show_lpvpns_bar" ]]; then
                dynamic_state=0
            fi
        else
            dynamic_state=3
            if [[ "$show_lpvpns_bar" ]]; then
                dynamic_state=2
            fi
        fi
    else
        dynamic_state=5
        if [[ "$show_lpvpns_bar" ]]; then
           dynamic_state=4
        fi
    fi
else
    dynamic_state=5
    if [[ "$show_lpvpns_bar" ]]; then
        dynamic_state=4
    fi
fi



LS="#[fg=$TC,bg=$G07,bold] $user@#h #[fg=$TC,bg=$G06,nobold]${r_sep_icon}"



ls_sep_2="#[fg=$G06,bg=$TC]${r_sep_icon}"
ls_sep_3="#[fg=$TC,bg=$TC]${r_sep_icon}"

color_for_segment_2="#[fg=$G04,bg=$TC]"
color_for_segment_3="#[fg=$G05,bg=$TC]"

# echo -e "dynamic_state: $dynamic_state" >> "$HOME/.tmux_power_debug"


if [[ $dynamic_state == 0 ]]; then
    # session_name + current_target + lp status bar
    LS="$LS#[fg=$TC,bg=$G06] $session_icon #S ${ls_sep_2}${color_for_segment_2}#{target_sel}${ls_sep_3}${color_for_segment_3}#{lpvpns_bar}"

elif [[ $dynamic_state == 1 ]]; then
    # session_name + current_target
    LS="$LS#[fg=$TC,bg=$G06] $session_icon #S ${ls_sep_2}${color_for_segment_2}#{target_sel}"

elif [[ $dynamic_state == 2 ]]; then
    # combined[session + target] + lp status bar
    LS="$LS#[fg=$TC,bg=$G06]#{target_sel}${ls_sep_2}${color_for_segment_2}#{lpvpns_bar}"

elif [[ $dynamic_state == 3 ]]; then
    # combined[session + target]
    LS="$LS#[fg=$TC,bg=$G06]#{target_sel}"

elif [[ $dynamic_state == 4 ]]; then
    # session_name + lp status bar
    LS="$LS#[fg=$TC,bg=$G06] $session_icon #S ${ls_sep_2}${color_for_segment_2}#{lpvpns_bar}"
fi





# if "$show_upload_speed"; then
#     LS="$LS#[fg=$G04,bg=$G03]$r_sep_icon#[fg=$TC,bg=$G03] $upload_speed_icon #{upload_speed} #[fg=$G03,bg=$BG]$r_sep_icon"
# else
    LS="$LS#[fg=$TC,bg=$G03]$r_sep_icon"
# 

if [[ $prefix_highlight_pos == 'L' || $prefix_highlight_pos == 'LR' ]]; then
    LS="$LS#{prefix_highlight}"
fi
tmux_set status-left "$LS"




# Right side of status bar
tmux_set status-right-bg "$BG"
tmux_set status-right-fg "$FG"
tmux_set status-right-length 150



if "$show_date"; then
    RS=" $date_icon $date_format $l_sep_icon $RS"

fi

if "$show_time"; then
    RS=" $time_icon $time_format $l_sep_icon $RS"

fi


if "$show_download_speed"; then
    RS=" $download_speed_icon #{download_speed} $l_sep_icon $RS"
fi

if "$show_upload_speed"; then
    RS=" $upload_speed_icon #{upload_speed} $l_sep_icon $RS"

fi



if [[ $prefix_highlight_pos == 'R' || $prefix_highlight_pos == 'LR' ]]; then
    RS="#{prefix_highlight}$RS"
fi
tmux_set status-right "$RS"

# Window status
tmux_set window-status-format " #I:#W#F "
tmux_set window-status-current-format "#[fg=$BG,bg=$TC]$right_arrow_icon#[fg=$BG,bg=$TC,bold] #I:#W#F #[fg=$TC,bg=$BG,nobold]$right_arrow_icon"

# Window separator
tmux_set window-status-separator ""

# Window status alignment
tmux_set status-justify centre

# # Current window status
# tmux_set window-status-current-status "fg=magenta,bg=yellow"

# Pane border
tmux_set pane-border-style "fg=$TC"
#tmux set -g pane-border-style "fg=#afdab6"
#tmux set -g pane-active-border-style "bg=#afdab6,fg=#afdab6"

# Active pane border
tmux_set pane-active-border-style "fg=$TC,bg=$TC"
#tmux set -g pane-active-border-style "bg=#afdab6,fg=#afdab6"

# Pane number indicator
tmux_set display-panes-colour "$G07"
tmux_set display-panes-active-colour "$TC"

# Clock mode
tmux_set clock-mode-colour "$TC"
tmux_set clock-mode-style 24

# Message
tmux_set message-style "fg=$TC,bg=$BG"

# Command message
tmux_set message-command-style "fg=$TC,bg=$BG"

# Copy mode highlight
tmux_set mode-style "bg=$TC,fg=$FG"

# set -g pane-active-border-style "bg=default,fg=#fefcfc"
# set -g pane-border-style "fg=#afdab6"
# tmux set -g pane-active-border-style fg=yellow,bg=cyan
# tmux set -g pane-border-style fg=green,bg=magenta
# set -g pane-active-border-style "bg=#afdab6,fg=#afdab6"
# set -g pane-border-style "fg=#afdab6"
