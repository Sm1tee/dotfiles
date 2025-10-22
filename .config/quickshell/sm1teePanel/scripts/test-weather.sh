#!/bin/bash

echo "=== Тест виджета погоды ==="
echo ""

echo "1. Проверка доступности API Open-Meteo..."
if curl -sS --fail --connect-timeout 3 --max-time 6 "https://api.open-meteo.com/v1/forecast?latitude=55.7558&longitude=37.6173&current=temperature_2m&timezone=auto" > /dev/null 2>&1; then
    echo "✓ API Open-Meteo доступен"
else
    echo "✗ API Open-Meteo недоступен"
fi

echo ""
echo "2. Проверка определения местоположения по IP..."
if curl -sS --fail --connect-timeout 3 --max-time 6 "http://ipinfo.io/json" > /dev/null 2>&1; then
    echo "✓ Сервис ipinfo.io доступен"
    LOCATION=$(curl -sS --fail --connect-timeout 3 --max-time 6 "http://ipinfo.io/json" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
    echo "  Ваш город: $LOCATION"
else
    echo "✗ Сервис ipinfo.io недоступен"
fi

echo ""
echo "3. Проверка geocoding API..."
if curl -sS --fail --connect-timeout 3 --max-time 6 "https://geocoding-api.open-meteo.com/v1/search?name=Moscow&count=1" > /dev/null 2>&1; then
    echo "✓ Geocoding API доступен"
else
    echo "✗ Geocoding API недоступен"
fi

echo ""
echo "4. Тест полного запроса погоды для Москвы..."
WEATHER=$(curl -sS --fail --connect-timeout 3 --max-time 6 "https://api.open-meteo.com/v1/forecast?latitude=55.7558&longitude=37.6173&current=temperature_2m,weather_code&timezone=auto" 2>&1)
if [ $? -eq 0 ]; then
    echo "✓ Данные погоды получены"
    TEMP=$(echo "$WEATHER" | grep -o '"temperature_2m":[0-9.-]*' | cut -d':' -f2)
    echo "  Температура в Москве: ${TEMP}°C"
else
    echo "✗ Ошибка получения данных погоды"
fi

echo ""
echo "=== Тест завершен ==="
