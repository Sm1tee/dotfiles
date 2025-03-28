#!/usr/bin/env bash

# Current Theme
dir="$HOME/.config/rofi/powermenu/type-2"
theme='style-10' # Убедитесь, что этот файл темы существует и настроен

# CMDs
# uptime="`uptime -p | sed -e 's/up //g'`" # Removed uptime variable
host=`hostname`

# Options (Используйте иконки, которые вам нравятся)
shutdown='🔌' # Или 🔴, 🛑, , ❌, 🔚, ⚫
reboot='♻️'   # Или 🔃, 🚀, 🔁, ⚙️, ⚡, ⏳, 🔙, 🆕, ↺, , 💡, ▶️
lock='🔒'     # Или 🔐, 🔑, ⌿
logout='🚪'   # Или →, ⇥, ⎋, X, 🔚
yes='✅'      # Используем текст для подтверждения
no='❌'

# Rofi CMD
rofi_cmd() {
	rofi -dmenu \
		-theme ${dir}/${theme}.rasi
}

# Confirmation CMD
confirm_cmd() {
	rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
		-theme-str 'mainbox {children: [ "message", "listview" ];}' \
		-theme-str 'listview {columns: 2; lines: 1;}' \
		-theme-str 'element-text {horizontal-align: 0.5;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
		-theme-str 'element { padding: 15px 20px; border-radius: 12px; }' \
		-dmenu \
		-p 'Подтверждение' \
		-mesg 'Вы уверены?' \
		-theme ${dir}/${theme}.rasi
}

# Ask for confirmation
confirm_exit() {
	echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$lock\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
	selected="$(confirm_exit)"
	# Используем текстовое сравнение для подтверждения
	if [[ "$selected" == "$yes" ]]; then
		if [[ $1 == '--shutdown' ]]; then
			systemctl poweroff
		elif [[ $1 == '--reboot' ]]; then
			systemctl reboot
		elif [[ $1 == '--logout' ]]; then
			hyprctl dispatch exit ""
		fi
	else
		exit 0
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
		run_cmd --shutdown
        ;;
    $reboot)
		run_cmd --reboot
        ;;
    $lock)
		hyprlock
        ;;
    $logout)
		run_cmd --logout
        ;;
esac