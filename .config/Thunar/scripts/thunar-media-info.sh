#!/bin/bash
#
# Get media information about audio/video files.
#
# * Put this file into your home binary dir: ~/bin/
# * Make it executable: chmod +x
#
#
# Required Software:
# -------------------------
#   * zenity (for gui mode - default)
#   * ffmpeg or ffprobe
#
#
# Thunar Integration
# ------------------------
#
#   Command:      ~/bin/thunar-media-info.sh -f %f -t %n
#   File Pattern: *
#   Appear On:    Audio Files, Video Files
#
#
# Usage:
# -------------------------
#   thunar-media-info.sh -f <filename> [-c] [-w width(int)] [-h height(int)] [-t window-title]
#
#     required:
#      -f    input filename
#
#     optional:
#      -c    no-gui, show console output (zenity not required)
#            default is to show gui
#
#      -w    (gui) width of window (e.g.: -w 800)
#            default is 800
#
#      -h    (gui) height of window (e.g.: -h 240)
#            default is 240
#
#      -t    (gui) window title
#            default is filename
#

set -euo pipefail  # Строгий режим для bash

usage() {
    cat << EOF
$0 -f <filename> [-c] [-w width(int)] [-h height(int)] [-t window-title]

 required:
   -f    input filename

 optional:
   -c    no-gui, show console output (zenity not required)
         default is to show gui

   -w    (gui) width of window (e.g.: -w 800)
         default is 800

   -h    (gui) height of window (e.g.: -h 240)
         default is 240

   -t    (gui) window title
         default is filename

EOF
    exit 1
}

# Проверка наличия команды
check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error - '$1' not found." >&2
        exit 1
    fi
}

# Проверка существования файла
check_file() {
    if [[ ! -f "$1" ]]; then
        echo "Error - file '$1' does not exist or is not a regular file." >&2
        exit 1
    fi
}

# Проверка, является ли строка числом
is_number() {
    [[ $1 =~ ^[0-9]+$ ]]
}

# Получение медиа информации с помощью ffprobe (более точный)
get_media_info() {
    local file="$1"
    
    # Используем ffprobe если доступен, иначе ffmpeg
    if command -v ffprobe >/dev/null 2>&1; then
        ffprobe -v quiet -print_format json -show_format -show_streams "$file" 2>/dev/null | \
        jq -r '
            "=== FILE INFO ===",
            "Filename: " + .format.filename,
            "Format: " + .format.format_long_name,
            "Duration: " + (.format.duration | tonumber | floor | tostring) + " seconds",
            "Size: " + (.format.size | tonumber / 1024 / 1024 | floor | tostring) + " MB",
            "",
            "=== STREAMS ===",
            (.streams[] | 
                if .codec_type == "video" then
                    "Video: " + .codec_long_name + 
                    " (" + (.width | tostring) + "x" + (.height | tostring) + ")" +
                    " @ " + (.r_frame_rate // "unknown") + " fps"
                elif .codec_type == "audio" then
                    "Audio: " + .codec_long_name + 
                    " (" + (.channels | tostring) + " channels)" +
                    " @ " + (.sample_rate // "unknown") + " Hz"
                else
                    .codec_type + ": " + (.codec_long_name // .codec_name)
                end
            )
        ' 2>/dev/null || {
            # Fallback к простому выводу если jq недоступен
            ffprobe -v error -show_entries format=filename,format_long_name,duration,size \
                    -show_entries stream=codec_type,codec_long_name,width,height,channels,sample_rate,r_frame_rate \
                    -of csv=p=0 "$file" 2>/dev/null | \
            awk -F',' '
                BEGIN { print "=== MEDIA INFO ===" }
                NR==1 { 
                    printf "Filename: %s\n", $1
                    printf "Format: %s\n", $2
                    if ($3) printf "Duration: %.0f seconds\n", $3
                    if ($4) printf "Size: %.1f MB\n", $4/1024/1024
                    print ""
                }
                NR>1 && $1 { 
                    if ($1 == "video") 
                        printf "Video: %s (%sx%s)\n", $2, $3, $4
                    else if ($1 == "audio")
                        printf "Audio: %s (%s channels) @ %s Hz\n", $2, $5, $6
                    else
                        printf "%s: %s\n", $1, $2
                }
            '
        }
    else
        # Fallback к ffmpeg
        ffmpeg -i "$file" 2>&1 | grep -E "(Input|Duration|Stream)" | \
        sed 's/^  *//' | sort -u
    fi
}

# Инициализация переменных
filename=""
console_mode=""
width=""
height=""
title=""

# Парсинг аргументов
while getopts ":f:cw:h:t:" opt; do
    case "${opt}" in
        f)
            filename="${OPTARG}"
            ;;
        c)
            console_mode="yes"
            ;;
        w)
            width="${OPTARG}"
            ;;
        h)
            height="${OPTARG}"
            ;;
        t)
            title="${OPTARG}"
            ;;
        \?)
            echo "Error - unrecognized option: -$OPTARG" >&2
            usage
            ;;
        :)
            echo "Error - option -$OPTARG requires an argument" >&2
            usage
            ;;
    esac
done

shift $((OPTIND-1))

# Проверка обязательных параметров
if [[ -z "$filename" ]]; then
    echo "Error - no file specified" >&2
    usage
fi

# Проверка существования файла
check_file "$filename"

# Проверка зависимостей
if [[ -z "$console_mode" ]]; then
    check_command "zenity"
fi

if command -v ffprobe >/dev/null 2>&1; then
    check_command "ffprobe"
elif command -v ffmpeg >/dev/null 2>&1; then
    check_command "ffmpeg"
else
    echo "Error - neither 'ffprobe' nor 'ffmpeg' found." >&2
    exit 1
fi

########################## console output ###############################
if [[ -n "$console_mode" ]]; then
    get_media_info "$filename"
    exit 0
fi

########################## gui output ###############################

# Валидация и установка размеров окна
if [[ -n "$width" ]] && ! is_number "$width"; then
    echo "Warning - invalid width '$width', using default" >&2
    width=""
fi

if [[ -n "$height" ]] && ! is_number "$height"; then
    echo "Warning - invalid height '$height', using default" >&2
    height=""
fi

WIDTH=${width:-800}
HEIGHT=${height:-400}
TITLE=${title:-"Media Info: $(basename "$filename")"}

# Получение информации и отображение в GUI
media_info=$(get_media_info "$filename")

if [[ -n "$media_info" ]]; then
    echo "$media_info" | zenity \
        --text-info \
        --width="$WIDTH" \
        --height="$HEIGHT" \
        --title="$TITLE" \
        --font="monospace 10" \
        --no-wrap 2>/dev/null || {
        echo "Error displaying GUI dialog" >&2
        exit 1
    }
else
    zenity --error --text "No media information found for: $(basename "$filename")" 2>/dev/null || {
        echo "Error - No media information found" >&2
        exit 1
    }
fi

exit 0