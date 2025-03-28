# Pass variables to rofi dmenu
run_rofi() {
    # Пути к вашим иконкам
    local icon_path="$HOME/.config/rofi/powermenu/type-2/icons"
    local lock_icon="$icon_path/lock.png"
    local logout_icon="$icon_path/logout.png"
    local reboot_icon="$icon_path/reboot.png"
    local shutdown_icon="$icon_path/shutdown.png"

    # Передаем разметку Rofi: " [пробел]\0icon\x1f/путь/к/файлу"
    # Важно: echo -e используется для обработки \0 и \x1f
    # Сохраняем оригинальные символы для case
    lock='🔒'
    logout='🚪'
    reboot='🌀'
    shutdown='🔌'

    # Формируем строки для Rofi
    local option_lock=" \0icon\x1f${lock_icon}"
    local option_logout=" \0icon\x1f${logout_icon}"
    local option_reboot=" \0icon\x1f${reboot_icon}"
    local option_shutdown=" \0icon\x1f${shutdown_icon}"

    # Передаем Rofi строки с путями к иконкам, но сохраняем map для выбора
    # Используем printf для надежной передачи строк с разделителями \0
    printf "%s\n%s\n%s\n%s" "$option_lock" "$option_logout" "$option_reboot" "$option_shutdown" | \
        rofi -dmenu \
             -theme ${dir}/${theme}.rasi \
             -p "Выберите действие:" \
             -format 's' \ # Возвращаем только строку (пробел)
             -selected-row 0 # Начинаем выбор с первого элемента (lock)
             # Добавляем маппинг для возврата исходного символа
             -display-map "${option_lock}:${lock};${option_logout}:${logout};${option_reboot}:${reboot};${option_shutdown}:${shutdown}" \
             -parse-hosts # Необходимо для работы -display-map
}

# Actions
# Получаем исходный символ благодаря -display-map
chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
        run_cmd --shutdown
        ;;
    $reboot)
        run_cmd --reboot
        ;;
    $lock)
        if command -v hyprlock >/dev/null; then
            hyprlock
        else
            notify-send "Ошибка" "Команда 'hyprlock' не найдена."
            exit 1
        fi
        ;;
    $logout)
        run_cmd --logout
        ;;
esac