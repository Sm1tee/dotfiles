#!/bin/bash

# VirusTotal File Checker для Thunar
# Требует API ключ от VirusTotal

# Конфигурация
API_KEY="0328a02f09c533da70756a64c98a76d01514edd6585ee689478afcf6771b0ba1"  # Замените на ваш API ключ
CONFIG_FILE="$HOME/.config/virustotal/api_key"
CACHE_DIR="$HOME/.cache/virustotal"

# Создаем необходимые директории
mkdir -p "$HOME/.config/virustotal"
mkdir -p "$CACHE_DIR"

# Функция для получения API ключа
get_api_key() {
    if [ -f "$CONFIG_FILE" ]; then
        API_KEY=$(cat "$CONFIG_FILE")
    fi
    
    if [ "$API_KEY" = "YOUR_VIRUSTOTAL_API_KEY" ] || [ -z "$API_KEY" ]; then
        API_KEY=$(zenity --entry --title="VirusTotal API Key" --text="Введите ваш API ключ VirusTotal:")
        if [ -n "$API_KEY" ]; then
            echo "$API_KEY" > "$CONFIG_FILE"
            chmod 600 "$CONFIG_FILE"
        else
            zenity --error --text="API ключ не введен. Получите ключ на https://www.virustotal.com/gui/join-us"
            exit 1
        fi
    fi
}

# Функция для вычисления SHA256 хеша
get_file_hash() {
    local file="$1"
    sha256sum "$file" | cut -d' ' -f1
}

# Функция для загрузки файла на VirusTotal
upload_file() {
    local file="$1"
    local hash="$2"
    
    local response=$(curl -s --max-time 300 -X POST \
        -H "x-apikey: $API_KEY" \
        -F "file=@$file" \
        "https://www.virustotal.com/api/v3/files")
    
    # Проверяем успешность curl
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    local analysis_id=$(echo "$response" | jq -r '.data.id // empty' 2>/dev/null)
    if [ -n "$analysis_id" ] && [ "$analysis_id" != "null" ]; then
        echo "$analysis_id" > "$CACHE_DIR/${hash}_analysis_id"
        return 0
    else
        return 1
    fi
}

# Функция для получения результатов анализа
get_analysis_results() {
    local hash="$1"
    
    local response=$(curl -s --max-time 30 -H "x-apikey: $API_KEY" \
        "https://www.virustotal.com/api/v3/files/$hash")
    
    # Проверяем успешность curl
    if [ $? -eq 0 ]; then
        echo "$response"
    else
        echo '{"error": {"code": "NetworkError", "message": "Сетевая ошибка"}}'
    fi
}

# Функция для форматирования результатов
format_results() {
    local response="$1"
    local filename="$2"
    
    # Проверяем, есть ли данные
    local error=$(echo "$response" | jq -r '.error.message // empty')
    if [ -n "$error" ]; then
        echo "Ошибка: $error"
        return 1
    fi
    
    # Извлекаем основную информацию
    local stats=$(echo "$response" | jq -r '.data.attributes.last_analysis_stats')
    local engines=$(echo "$response" | jq -r '.data.attributes.last_analysis_results')
    
    local malicious=$(echo "$stats" | jq -r '.malicious // 0')
    local suspicious=$(echo "$stats" | jq -r '.suspicious // 0')
    local undetected=$(echo "$stats" | jq -r '.undetected // 0')
    local harmless=$(echo "$stats" | jq -r '.harmless // 0')
    local total=$((malicious + suspicious + undetected + harmless))
    
    # Формируем HTML отчет
    local html_file="$CACHE_DIR/report_$(date +%s).html"
    
    cat > "$html_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>VirusTotal Report - $(basename "$filename")</title>
    <style>
        body { 
            font-family: 'Segoe UI', Arial, sans-serif; 
            background: #1e1e2e; 
            color: #cdd6f4; 
            margin: 20px; 
        }
        .container { 
            max-width: 1000px; 
            margin: 0 auto; 
            background: #313244; 
            border-radius: 10px; 
            padding: 20px; 
        }
        .header { 
            text-align: center; 
            border-bottom: 2px solid #45475a; 
            padding-bottom: 15px; 
            margin-bottom: 20px; 
        }
        .score-circle { 
            display: inline-block; 
            width: 100px; 
            height: 100px; 
            border-radius: 50%; 
            color: white; 
            font-size: 24px; 
            font-weight: bold; 
            line-height: 100px; 
            text-align: center; 
            margin: 10px; 
        }
        .safe { background: #a6e3a1; }
        .warning { background: #f9e2af; color: #1e1e2e; }
        .danger { background: #f38ba8; }
        .results-table { 
            width: 100%; 
            border-collapse: collapse; 
            margin-top: 20px; 
        }
        .results-table th, .results-table td { 
            padding: 10px; 
            text-align: left; 
            border-bottom: 1px solid #45475a; 
        }
        .results-table th { 
            background: #45475a; 
        }
        .detected { color: #f38ba8; font-weight: bold; }
        .clean { color: #a6e3a1; }
        .info { 
            background: #45475a; 
            padding: 15px; 
            border-radius: 5px; 
            margin: 15px 0; 
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>VirusTotal Analysis Report</h1>
            <h2>$(basename "$filename")</h2>
            <p>SHA256: $(get_file_hash "$filename")</p>
            
EOF

    # Добавляем индикатор безопасности
    if [ "$malicious" -eq 0 ] && [ "$suspicious" -eq 0 ]; then
        echo '<div class="score-circle safe">0<br><small>/ '$total'</small></div>' >> "$html_file"
        echo '<h3 style="color: #a6e3a1;">✓ Файл чистый</h3>' >> "$html_file"
    elif [ "$malicious" -gt 0 ]; then
        echo '<div class="score-circle danger">'$malicious'<br><small>/ '$total'</small></div>' >> "$html_file"
        echo '<h3 style="color: #f38ba8;">⚠ Обнаружены угрозы!</h3>' >> "$html_file"
    else
        echo '<div class="score-circle warning">'$suspicious'<br><small>/ '$total'</small></div>' >> "$html_file"
        echo '<h3 style="color: #f9e2af;">⚡ Подозрительный файл</h3>' >> "$html_file"
    fi
    
    cat >> "$html_file" << EOF
        </div>
        
        <div class="info">
            <strong>Статистика:</strong><br>
            Malicious: $malicious | Suspicious: $suspicious | Undetected: $undetected | Harmless: $harmless
        </div>
        
        <h3>Результаты анализа антивирусными движками:</h3>
        <table class="results-table">
            <thead>
                <tr>
                    <th>Антивирус</th>
                    <th>Результат</th>
                    <th>Версия</th>
                    <th>Обновление</th>
                </tr>
            </thead>
            <tbody>
EOF

    # Добавляем результаты каждого антивируса
    echo "$engines" | jq -r 'to_entries[] | "\(.key)|\(.value.category)|\(.value.result // "Clean")|\(.value.version // "N/A")|\(.value.update // "N/A")"' | \
    while IFS='|' read -r engine category result version update; do
        if [ "$category" = "malicious" ] || [ "$category" = "suspicious" ]; then
            echo "<tr><td><strong>$engine</strong></td><td class=\"detected\">$result</td><td>$version</td><td>$update</td></tr>" >> "$html_file"
        else
            echo "<tr><td>$engine</td><td class=\"clean\">Clean</td><td>$version</td><td>$update</td></tr>" >> "$html_file"
        fi
    done
    
    cat >> "$html_file" << EOF
            </tbody>
        </table>
        
        <div class="info">
            <p><strong>Отчет сгенерирован:</strong> $(date)</p>
            <p><strong>Powered by:</strong> VirusTotal API</p>
        </div>
    </div>
</body>
</html>
EOF

    echo "$html_file"
}

# Основная функция
main() {
    if [ $# -eq 0 ]; then
        zenity --error --text="Пожалуйста, выберите файл для проверки"
        exit 1
    fi
    
    local file="$1"
    
    # Проверяем существование файла
    if [ ! -f "$file" ]; then
        zenity --error --text="Файл не найден: $file"
        exit 1
    fi
    
    # Проверяем размер файла (VirusTotal имеет лимит 650MB для бесплатных аккаунтов)
    local file_size=$(stat -c%s "$file")
    if [ "$file_size" -gt 681574400 ]; then  # 650MB в байтах
        zenity --error --text="Файл слишком большой для загрузки на VirusTotal (макс. 650MB)"
        exit 1
    fi
    
    # Получаем API ключ
    get_api_key
    
    # Проверяем наличие необходимых утилит
    if ! command -v jq >/dev/null 2>&1; then
        zenity --error --text="Требуется установить пакет 'jq'\nsudo apt install jq"
        exit 1
    fi
    
    # Показываем прогресс
    (
        echo "10" ; echo "# Вычисляем хеш файла..."
        local hash=$(get_file_hash "$file")
        
        echo "30" ; echo "# Проверяем файл в базе VirusTotal..."
        local response=$(get_analysis_results "$hash")
        
        # Если файл не найден, загружаем его
        if echo "$response" | jq -e '.error.code == "NotFoundError"' >/dev/null 2>&1; then
            echo "50" ; echo "# Загружаем файл на VirusTotal..."
            if upload_file "$file" "$hash"; then
                echo "70" ; echo "# Ожидаем результаты анализа..."
                # Ждем завершения анализа с проверками
                local attempts=0
                while [ $attempts -lt 6 ]; do
                    sleep 10
                    response=$(get_analysis_results "$hash")
                    if ! echo "$response" | jq -e '.error.code == "NotFoundError"' >/dev/null 2>&1; then
                        break
                    fi
                    attempts=$((attempts + 1))
                    echo "$((70 + attempts * 3))" ; echo "# Ожидаем анализ... ($((attempts * 10))с)"
                done
            else
                echo "100" ; echo "# Ошибка загрузки"
                zenity --error --text="Не удалось загрузить файл на VirusTotal"
                exit 1
            fi
        fi
        
        echo "90" ; echo "# Формируем отчет..."
        
        # Проверяем что получили валидные данные
        if echo "$response" | jq -e '.data.attributes.last_analysis_stats' >/dev/null 2>&1; then
            local report_file=$(format_results "$response" "$file")
            echo "100" ; echo "# Готово!"
            
            # Открываем отчет в браузере
            if [ -n "$report_file" ] && [ -f "$report_file" ]; then
                xdg-open "$report_file"
            fi
        else
            echo "100" ; echo "# Ошибка получения данных"
            zenity --error --text="Не удалось получить результаты анализа"
            exit 1
        fi
        
    ) | zenity --progress --title="VirusTotal File Check" --width=400 --auto-close
}

# Запускаем основную функцию
main "$@"