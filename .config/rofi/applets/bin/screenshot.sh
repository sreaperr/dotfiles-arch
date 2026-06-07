#!/usr/bin/env bash

## Author  : Aditya Shakya (adi1090x)
## Github  : @adi1090x
#
## Applets : Screenshot

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Theme Elements
prompt='Screenshot'
mesg="DIR: $HOME/Pictures/screenshots"

if [[ "$theme" == *'type-1'* ]]; then
	list_col='1'
	list_row='5'
	win_width='400px'
elif [[ "$theme" == *'type-3'* ]]; then
	list_col='1'
	list_row='5'
	win_width='120px'
elif [[ "$theme" == *'type-5'* ]]; then
	list_col='1'
	list_row='5'
	win_width='520px'
elif [[ ( "$theme" == *'type-2'* ) || ( "$theme" == *'type-4'* ) ]]; then
	list_col='5'
	list_row='1'
	win_width='670px'
fi

# Options
layout=`cat ${theme} | grep 'USE_ICON' | cut -d'=' -f2`
if [[ "$layout" == 'NO' ]]; then
	option_1=" Capture Desktop"
	option_2=" Capture Area"
	option_3=" Capture Window"
	option_4=" Capture in 5s"
	option_5=" Capture in 10s"
else
	option_1=""
	option_2=""
	option_3=""
	option_4=""
	option_5=""
fi

# Rofi CMD
rofi_cmd() {
	rofi -theme-str "window {width: $win_width;}" \
		-theme-str "listview {columns: $list_col; lines: $list_row;}" \
		-theme-str 'textbox-prompt-colon {str: "";}' \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		-markup-rows \
		-theme ${theme}
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5" | rofi_cmd
}

# Screenshot
dir="$HOME/Pictures/screenshots"

if [[ ! -d "$dir" ]]; then
	mkdir -p "$dir"
fi

# countdown
countdown () {
	for sec in `seq $1 -1 1`; do
		notify-send -t 900 "Capturando en $sec..."
		sleep 1
	done
}

# take shots
shotnow () {
	local file="$dir/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
	sleep 0.5 && grim - | tee "$file" | wl-copy
	notify-send -u low "Screenshot guardado" "$file"
}

shot5 () {
	countdown '5'
	local file="$dir/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
	grim - | tee "$file" | wl-copy
	notify-send -u low "Screenshot guardado" "$file"
}

shot10 () {
	countdown '10'
	local file="$dir/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
	grim - | tee "$file" | wl-copy
	notify-send -u low "Screenshot guardado" "$file"
}

shotwin () {
	local file="$dir/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
	local geom=$(hyprctl activewindow -j | python3 -c "import sys,json; w=json.load(sys.stdin); print('{},{} {}x{}'.format(*w['at'],*w['size']))")
	[[ -n "$geom" ]] && grim -g "$geom" - | tee "$file" | wl-copy
	notify-send -u low "Screenshot ventana guardado" "$file"
}

shotarea () {
	local file="$dir/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
	local geom=$(slurp)
	[[ -n "$geom" ]] && grim -g "$geom" - | tee "$file" | wl-copy && notify-send -u low "Screenshot área guardado" "$file"
}

# Execute Command
run_cmd() {
	if [[ "$1" == '--opt1' ]]; then
		shotnow
	elif [[ "$1" == '--opt2' ]]; then
		shotarea
	elif [[ "$1" == '--opt3' ]]; then
		shotwin
	elif [[ "$1" == '--opt4' ]]; then
		shot5
	elif [[ "$1" == '--opt5' ]]; then
		shot10
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
    $option_4)
		run_cmd --opt4
        ;;
    $option_5)
		run_cmd --opt5
        ;;
esac


