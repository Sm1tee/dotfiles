#!/bin/bash

echo "=== ПРОБЛЕМНЫЕ СЕРВИСЫ ==="
failed_services=$(systemctl --user --failed --plain --no-legend | awk '{print $1}' | grep -v "^$")
system_failed=$(systemctl --failed --plain --no-legend | awk '{print $1}' | grep -v "^$")

if [ -n "$failed_services" ]; then
    echo "Пользовательские сервисы:"
    systemctl --user --failed --no-pager
    echo
fi

if [ -n "$system_failed" ]; then
    echo "Системные сервисы:"
    systemctl --failed --no-pager
    echo
fi

if [ -z "$failed_services" ] && [ -z "$system_failed" ]; then
    echo "Нет проблемных сервисов"
    read -p "Press Enter to close..."
    exit 0
fi

echo "=== РЕКОМЕНДУЕМЫЕ ДЕЙСТВИЯ ==="
echo "Попробуйте в таком порядке:"
echo

# Для каждого пользовательского сервиса
for service in $failed_services; do
    echo "🔧 $service:"
    echo "   1. Перезапуск: systemctl --user restart $service"
    echo "   2. Проверка логов: journalctl --user -u $service --no-pager -n 20"
    echo "   3. Если не помогает: systemctl --user disable $service"
    echo
done

# Для каждого системного сервиса
for service in $system_failed; do
    echo "🔧 $service (системный):"
    echo "   1. Перезапуск: sudo systemctl restart $service"
    echo "   2. Проверка логов: journalctl -u $service --no-pager -n 20"
    echo "   3. Если не помогает: sudo systemctl disable $service"
    echo
done

echo "=== БЫСТРЫЕ КОМАНДЫ ==="
if [ -n "$failed_services" ]; then
    echo "Перезапустить все пользовательские:"
    echo "systemctl --user restart $failed_services"
    echo
    echo "Отключить все пользовательские (если перезапуск не помог):"
    echo "systemctl --user disable $failed_services"
    echo
fi

if [ -n "$system_failed" ]; then
    echo "Перезапустить все системные:"
    echo "sudo systemctl restart $system_failed"
    echo
    echo "Отключить все системные (если перезапуск не помог):"
    echo "sudo systemctl disable $system_failed"
    echo
fi

echo "💡 Для подробной диагностики конкретного сервиса:"
echo "   systemctl status SERVICE_NAME"
echo "   journalctl -u SERVICE_NAME -f"
echo
echo "🤖 Для помощи ИИ:"
echo "   Нажмите 'c' чтобы скопировать логи всех проблемных сервисов в буфер"
echo "   Затем можете передать их ИИ для анализа"
echo

read -p "Press Enter to close or 'c' to copy logs to clipboard: " choice

if [ "$choice" = "c" ] || [ "$choice" = "C" ]; then
    echo "Собираю логи для ИИ..."
    
    # Создаем временный файл для логов
    temp_log=$(mktemp)
    
    echo "=== ЛОГИ ПРОБЛЕМНЫХ СЕРВИСОВ ===" > "$temp_log"
    echo "Система: $(uname -a)" >> "$temp_log"
    echo "Дата: $(date)" >> "$temp_log"
    echo >> "$temp_log"
    
    # Пользовательские сервисы
    if [ -n "$failed_services" ]; then
        echo "=== ПОЛЬЗОВАТЕЛЬСКИЕ СЕРВИСЫ ===" >> "$temp_log"
        for service in $failed_services; do
            echo "--- $service ---" >> "$temp_log"
            systemctl --user status "$service" --no-pager -l >> "$temp_log" 2>&1
            echo >> "$temp_log"
            echo "Последние логи:" >> "$temp_log"
            journalctl --user -u "$service" --no-pager -n 15 >> "$temp_log" 2>&1
            echo >> "$temp_log"
        done
    fi
    
    # Системные сервисы
    if [ -n "$system_failed" ]; then
        echo "=== СИСТЕМНЫЕ СЕРВИСЫ ===" >> "$temp_log"
        for service in $system_failed; do
            echo "--- $service ---" >> "$temp_log"
            systemctl status "$service" --no-pager -l >> "$temp_log" 2>&1
            echo >> "$temp_log"
            echo "Последние логи:" >> "$temp_log"
            journalctl -u "$service" --no-pager -n 15 >> "$temp_log" 2>&1
            echo >> "$temp_log"
        done
    fi
    
    # Копируем в буфер обмена
    if command -v wl-copy >/dev/null 2>&1; then
        cat "$temp_log" | wl-copy
        echo "✅ Логи скопированы в буфер через wl-copy"
    elif command -v xclip >/dev/null 2>&1; then
        cat "$temp_log" | xclip -selection clipboard
        echo "✅ Логи скопированы в буфер через xclip"
    else
        echo "❌ Не найдены wl-copy или xclip"
        echo "Установите: sudo pacman -S wl-clipboard  # или xclip"
        echo "Логи сохранены в: $temp_log"
        echo "Можете скопировать их вручную"
    fi
    
    # Очищаем временный файл
    rm -f "$temp_log"
    
    echo "Теперь можете вставить логи в чат с ИИ для получения помощи"
    read -p "Press Enter to close..."
fi