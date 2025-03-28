#!/usr/bin/env bash

# Current Theme
dir="$HOME/.config/rofi/powermenu/type-2"
theme='style-10' # Убедись, что этот файл темы существует и настроен

# CMDs
host=`hostname`

# Options (Используйте иконки, которые вам нравятся)
shutdown='🔌'
reboot='♻️'
lock='🔒'
logout='🚪'
yes='✅'
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
        # Уменьшаем кнопки подтверждения
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

# Execute Command (с правильными командами)
run_cmd() {
	selected="$(confirm_exit)"
	# Используем текстовое сравнение для подтверждения
	if [[ "$selected" == "$yes" ]]; then
		if [[ $1 == '--shutdown' ]]; then
			# Идеальная команда для выключения
			systemctl poweroff
		elif [[ $1 == '--reboot' ]]; then
			# Идеальная команда для перезагрузки
			systemctl reboot
		elif [[ $1 == '--logout' ]]; then
			# Идеальная команда для выхода из сеанса Hyprland
			hyprctl dispatch exit ""
		fi
	else
		exit 0 # Выход, если выбрано "Нет"
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
		# Запускаем hyprlock напрямую, без подтверждения
        if command -v hyprlock >/dev/null; then
            hyprlock # Просто выполняем команду
        else
             notify-send "Ошибка Powermenu" "'hyprlock' не найден."
             exit 1
        fi
        ;;
    $logout)
		run_cmd --logout
        ;;
esac