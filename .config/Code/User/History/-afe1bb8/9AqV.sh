#!/usr/bin/env bash

# Current Theme
dir="$HOME/.config/rofi/powermenu/type-2"
theme='style-10' # Убедись, что этот файл темы существует и настроен

# CMDs
host=`hostname`

# Options (Иконки)
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

# --- ИЗМЕНЕНО: Используем loginctl и полные пути ---
# Execute Command
run_cmd() {
	selected="$(confirm_exit)"
	if [[ "$selected" == "$yes" ]]; then
		if [[ $1 == '--shutdown' ]]; then
			# Пробуем loginctl
			/usr/bin/loginctl poweroff
		elif [[ $1 == '--reboot' ]]; then
			# Пробуем loginctl
			/usr/bin/loginctl reboot
		elif [[ $1 == '--logout' ]]; then
			# Используем полный путь
			/usr/bin/hyprctl dispatch exit ""
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
		# --- ИЗМЕНЕНО: Используем полный путь ---
        # Запускаем hyprlock напрямую, без подтверждения
        if command -v /usr/bin/hyprlock >/dev/null; then
             # Используем полный путь
            /usr/bin/hyprlock
        else
             # Убедись, что notify-send установлен, если используешь уведомления
             notify-send "Ошибка Powermenu" "'hyprlock' не найден."
             exit 1
        fi
        ;;
    $logout)
		run_cmd --logout
        ;;
esac
# --- Конец изменений ---