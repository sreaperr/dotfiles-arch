#!/usr/bin/env bash

## Author  : Aditya Shakya (adi1090x)
## Github  : @adi1090x
#
## Applets : Volume

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Volume Info (PipeWire via wpctl)
sink_raw="`wpctl get-volume @DEFAULT_AUDIO_SINK@`"
source_raw="`wpctl get-volume @DEFAULT_AUDIO_SOURCE@`"
mixer="PipeWire"
speaker="`echo "$sink_raw" | awk '{printf "%d%%", $2*100}'`"
mic="`echo "$source_raw" | awk '{printf "%d%%", $2*100}'`"

active=""
urgent=""

# Speaker Info
if [[ "$sink_raw" != *'MUTED'* ]]; then
	active="-a 1"
	stext='Unmute'
	sicon=''
else
	urgent="-u 1"
	stext='Mute'
	sicon=''
fi

# Microphone Info
if [[ "$source_raw" != *'MUTED'* ]]; then
    [ -n "$active" ] && active+=",2" || active="-a 2"
	mtext='Unmute'
	micon=''
else
    [ -n "$urgent" ] && urgent+=",2" || urgent="-u 2"
	mtext='Mute'
	micon=''
fi

# Theme Elements
prompt="S:$stext, M:$mtext"
mesg="$mixer - Speaker: $speaker, Mic: $mic"

if [[ "$theme" == *'type-1'* ]]; then
	list_col='1'
	list_row='3'
	win_width='400px'
elif [[ "$theme" == *'type-3'* ]]; then
	list_col='3'
	list_row='1'
	win_width='420px'
elif [[ "$theme" == *'type-5'* ]]; then
	list_col='1'
	list_row='3'
	win_width='520px'
elif [[ ( "$theme" == *'type-2'* ) || ( "$theme" == *'type-4'* ) ]]; then
	list_col='3'
	list_row='1'
	win_width='500px'
fi

# Options
layout=`cat ${theme} | grep 'USE_ICON' | cut -d'=' -f2`
if [[ "$layout" == 'NO' ]]; then
	option_1="$sicon $stext"
	option_2="$micon $mtext"
	option_3=" Settings"
else
	option_1="$sicon"
	option_2="$micon"
	option_3=""
fi

# Rofi CMD
rofi_cmd() {
	rofi -theme-str "window {width: $win_width;}" \
		-theme-str "listview {columns: $list_col; lines: $list_row;}" \
		-theme-str 'textbox-prompt-colon {str: "";}' \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		${active} ${urgent} \
		-markup-rows \
		-theme ${theme}
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3" | rofi_cmd
}

# Execute Command
run_cmd() {
	if [[ "$1" == '--opt1' ]]; then
		wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
	elif [[ "$1" == '--opt2' ]]; then
		wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
	elif [[ "$1" == '--opt3' ]]; then
		pavucontrol
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $option_1)
		run_cmd --opt1
        ;;
    $option_2)
		run_cmd --opt2
        ;;
    $option_3)
		run_cmd --opt3
        ;;
esac
