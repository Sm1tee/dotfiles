#!/bin/bash

# Скрипт для обрезки видео через ffmpeg с GUI выбором времени

# Исправление темы для GTK4 приложений
export GSK_RENDERER=gl
export GTK_THEME=Adwaita:dark
export ADW_DISABLE_PORTAL=1
export GTK_ENABLE_ANIMATIONS=0

VIDEO_FILE="$1"

# Проверка существования файла
if [ ! -f "$VIDEO_FILE" ]; then
    zenity --error --text="Файл не найден: $VIDEO_FILE"
    exit 1
fi

# Получение длительности видео
DURATION=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 "$VIDEO_FILE" 2>/dev/null)
if [ -z "$DURATION" ]; then
    zenity --error --text="Не удалось получить информацию о видео"
    exit 1
fi

# Преобразование длительности в формат ЧЧ:ММ:СС
DURATION_FORMATTED=$(printf "%02d:%02d:%02d" $((${DURATION%.*}/3600)) $((${DURATION%.*}%3600/60)) $((${DURATION%.*}%60)))

# Диалог для выбора начального времени
START_TIME=$(zenity --entry \
    --title="Обрезка видео" \
    --text="Введите время начала (формат: ЧЧ:ММ:СС или СС)\nДлительность видео: $DURATION_FORMATTED" \
    --entry-text="00:00:00")

if [ -z "$START_TIME" ]; then
    exit 0
fi

# Диалог для выбора конечного времени
END_TIME=$(zenity --entry \
    --title="Обрезка видео" \
    --text="Введите время окончания (формат: ЧЧ:ММ:СС или СС)\nДлительность видео: $DURATION_FORMATTED" \
    --entry-text="$DURATION_FORMATTED")

if [ -z "$END_TIME" ]; then
    exit 0
fi

# Получение имени файла без расширения и расширения
FILENAME=$(basename "$VIDEO_FILE")
BASENAME="${FILENAME%.*}"
EXTENSION="${FILENAME##*.}"
DIRECTORY=$(dirname "$VIDEO_FILE")

# Создание имени выходного файла
OUTPUT_FILE="$DIRECTORY/${BASENAME}_trimmed.$EXTENSION"

# Проверка на существование выходного файла
COUNTER=1
while [ -f "$OUTPUT_FILE" ]; do
    OUTPUT_FILE="$DIRECTORY/${BASENAME}_trimmed_${COUNTER}.$EXTENSION"
    ((COUNTER++))
done

# Показ диалога прогресса и выполнение ffmpeg
(
    echo "10"
    echo "# Начало обрезки видео..."
    
    # Выполнение ffmpeg с обрезкой
    ffmpeg -i "$VIDEO_FILE" -ss "$START_TIME" -to "$END_TIME" -c copy "$OUTPUT_FILE" 2>&1 | while read line; do
        echo "50"
        echo "# Обрезка видео: $line"
    done
    
    echo "100"
    echo "# Обрезка завершена"
) | zenity --progress \
    --title="Обрезка видео" \
    --text="Обрезка видео..." \
    --percentage=0 \
    --auto-close

# Проверка успешности выполнения
if [ $? -eq 0 ] && [ -f "$OUTPUT_FILE" ]; then
    zenity --info --text="Видео успешно обрезано и сохранено как:\n$OUTPUT_FILE"
    
    # Предложение открыть папку с результатом
    if zenity --question --text="Открыть папку с обрезанным видео?"; then
        thunar "$DIRECTORY"
    fi
else
    zenity --error --text="Ошибка при обрезке видео"
fi