#!/bin/bash

# Скрипт для разделения видео на 2 части

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

# Диалог для выбора времени разделения
SPLIT_TIME=$(zenity --entry \
    --title="Разделение видео" \
    --text="Введите время разделения (формат: ЧЧ:ММ:СС или СС)\nДлительность видео: $DURATION_FORMATTED" \
    --entry-text="00:00:00")

if [ -z "$SPLIT_TIME" ]; then
    exit 0
fi

# Получение имени файла без расширения и расширения
FILENAME=$(basename "$VIDEO_FILE")
BASENAME="${FILENAME%.*}"
EXTENSION="${FILENAME##*.}"
DIRECTORY=$(dirname "$VIDEO_FILE")

# Создание имен выходных файлов
PART1_FILE="$DIRECTORY/${BASENAME}_part1.$EXTENSION"
PART2_FILE="$DIRECTORY/${BASENAME}_part2.$EXTENSION"

# Проверка на существование выходных файлов
COUNTER=1
while [ -f "$PART1_FILE" ] || [ -f "$PART2_FILE" ]; do
    PART1_FILE="$DIRECTORY/${BASENAME}_part1_${COUNTER}.$EXTENSION"
    PART2_FILE="$DIRECTORY/${BASENAME}_part2_${COUNTER}.$EXTENSION"
    ((COUNTER++))
done

# Показ диалога прогресса и выполнение ffmpeg
(
    echo "10"
    echo "# Создание первой части..."
    
    # Создание первой части (от начала до времени разделения)
    ffmpeg -i "$VIDEO_FILE" -t "$SPLIT_TIME" -c copy "$PART1_FILE" 2>/dev/null
    
    echo "50"
    echo "# Создание второй части..."
    
    # Создание второй части (от времени разделения до конца)
    ffmpeg -i "$VIDEO_FILE" -ss "$SPLIT_TIME" -c copy "$PART2_FILE" 2>/dev/null
    
    echo "100"
    echo "# Разделение завершено"
) | zenity --progress \
    --title="Разделение видео" \
    --text="Разделение видео на 2 части..." \
    --percentage=0 \
    --auto-close

# Проверка успешности выполнения
if [ $? -eq 0 ] && [ -f "$PART1_FILE" ] && [ -f "$PART2_FILE" ]; then
    zenity --info --text="Видео успешно разделено на 2 части:\n$PART1_FILE\n$PART2_FILE"
    
    # Предложение открыть папку с результатом
    if zenity --question --text="Открыть папку с разделенными файлами?"; then
        thunar "$DIRECTORY"
    fi
else
    zenity --error --text="Ошибка при разделении видео"
fi