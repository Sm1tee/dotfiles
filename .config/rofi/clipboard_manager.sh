#!/bin/bash

# Функция для запуска rofi
launch_rofi() {
    BUFFER_LIST=$(cliphist list)
    OPTIONS="Очистить буфер\n$BUFFER_LIST"

    # Выбор из rofi
    SELECTION=$(echo -e "$OPTIONS" | rofi -dmenu -p "Буфер обмена" -no-sort)

    # Обработка выбора
    if [ "$SELECTION" == "Очистить буфер" ]; then
        cliphist wipe
        notify-send "Буфер обмена очищен"
    elif [ -n "$SELECTION" ]; then
        echo "$SELECTION" | cliphist decode | wl-copy
    fi
}

# Бесконечный цикл для удержания rofi открытым
while true; do
    launch_rofi
done
