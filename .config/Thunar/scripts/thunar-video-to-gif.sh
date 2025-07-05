#!/bin/bash
#
# Convert a video file to an animated gif (high quality mode).
#
# * Put this file into your home binary dir: ~/bin/
# * Make it executable: chmod +x
#
#
# Required Software:
# -------------------------
#   * zenity (for gui mode - default)
#   * ffmpeg
#
#
# Thunar Integration
# ------------------------
#
#   Command:      ~/bin/thunar-video-to-gif.sh -f %f -t %n
#   File Pattern: *
#   Appear On:    Video Files
#
#
# Usage:
# -------------------------
#   thunar-video-to-gif.sh -f <filename> [-c] [-w width] [-r fps] [-s start] [-d duration] [-o output]
#
#     required:
#      -f    input filename
#
#     optional:
#      -c    no-gui, show console output (zenity not required)
#            default is to show gui
#      -w    output width in pixels (default: 480)
#      -r    frame rate (default: 15)
#      -s    start time in seconds (default: 0)
#      -d    duration in seconds (default: convert entire video)
#      -o    output filename (default: input_filename.gif)
#

set -euo pipefail

# Default values
DEFAULT_WIDTH=480
DEFAULT_FPS=15
DEFAULT_START=0

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[ИНФО]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[УСПЕХ]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[ПРЕДУПРЕЖДЕНИЕ]${NC} $1"
}

print_error() {
    echo -e "${RED}[ОШИБКА]${NC} $1" >&2
}

# Test if argument is an integer
is_integer() {
    [[ $1 =~ ^[0-9]+$ ]]
}

# Test if argument is a valid float
is_float() {
    [[ $1 =~ ^[0-9]+(\.[0-9]+)?$ ]]
}

# Check if command exists
check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        print_error "Команда '$1' не найдена"
        exit 1
    fi
}

# Check if file exists and is readable
check_file() {
    if [[ ! -f "$1" ]]; then
        print_error "Файл '$1' не существует или не является обычным файлом"
        exit 1
    fi
    if [[ ! -r "$1" ]]; then
        print_error "Файл '$1' недоступен для чтения"
        exit 1
    fi
}

# Get video duration using ffprobe
get_video_duration() {
    local file="$1"
    if command -v ffprobe >/dev/null 2>&1; then
        ffprobe -v quiet -show_entries format=duration -of csv=p=0 "$file" 2>/dev/null | cut -d. -f1
    else
        # Fallback using ffmpeg
        ffmpeg -i "$file" 2>&1 | grep Duration | awk '{print $2}' | tr -d , | awk -F: '{print ($1 * 3600) + ($2 * 60) + $3}' | cut -d. -f1
    fi
}

# Get video resolution
get_video_resolution() {
    local file="$1"
    if command -v ffprobe >/dev/null 2>&1; then
        ffprobe -v quiet -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$file" 2>/dev/null
    else
        ffmpeg -i "$file" 2>&1 | grep -oP 'Stream.*Video.*\K[0-9]+x[0-9]+' | head -1
    fi
}

# Usage function
usage() {
    cat << EOF
$0 -f <имя_файла> [-c] [-w ширина] [-r fps] [-s начало] [-d длительность] [-o выходной_файл]

 обязательные:
   -f    входной файл

 опциональные:
   -c    консольный режим, без GUI (zenity не требуется)
         по умолчанию показывает GUI с выбором разрешения
   -w    ширина на выходе в пикселях (по умолчанию: $DEFAULT_WIDTH)
         в GUI режиме можно выбрать из готовых разрешений:
         • Мобильный (480x270) - для мессенджеров
         • HD (720x405) - оптимальное качество  
         • HD+ (960x540) - высокое качество
         • Full HD (1280x720) - очень высокое качество
         • 2K (1920x1080) - максимальное качество
         • 4K (3840x2160) - исходное качество
   -r    частота кадров (по умолчанию: $DEFAULT_FPS)
   -s    время начала в секундах (по умолчанию: $DEFAULT_START)
   -d    длительность в секундах (по умолчанию: всё видео)
   -o    имя выходного файла (по умолчанию: имя_входного_файла.gif)

EOF
    exit 1
}

# Function to convert resolution preset to width
get_width_from_preset() {
    local preset="$1"
    case "$preset" in
        "Мобильный (480x270)")     echo "480" ;;
        "HD (720x405)")            echo "720" ;;
        "HD+ (960x540)")           echo "960" ;;
        "Full HD (1280x720)")      echo "1280" ;;
        "2K (1920x1080)")          echo "1920" ;;
        "4K (3840x2160)")          echo "3840" ;;
        "Пользовательский")        echo "custom" ;;
        *)                         echo "720" ;;
    esac
}

# GUI function to get user input - improved version with resolution presets
get_gui_parameters() {
    local input_file="$1"
    local video_duration video_resolution
    
    video_duration=$(get_video_duration "$input_file")
    video_resolution=$(get_video_resolution "$input_file")
    
    # Get resolution preset
    local resolution_preset
    resolution_preset=$(zenity --list \
        --title="Выбор разрешения GIF" \
        --text="Видео: $(basename "$input_file")\nДлительность: ${video_duration}с, Исходное разрешение: ${video_resolution}\n\nВыберите разрешение для GIF:" \
        --column="Разрешение" \
        --column="Описание" \
        --column="Примерный размер файла" \
        "Мобильный (480x270)" "Для мессенджеров и соцсетей" "1-5 МБ" \
        "HD (720x405)" "Оптимальное качество" "3-10 МБ" \
        "HD+ (960x540)" "Высокое качество" "5-15 МБ" \
        "Full HD (1280x720)" "Очень высокое качество" "10-30 МБ" \
        "2K (1920x1080)" "Максимальное качество" "20-50 МБ" \
        "4K (3840x2160)" "Исходное качество (только для 4K видео)" "50+ МБ" \
        "Пользовательский" "Ввести свою ширину" "Зависит от размера" \
        --width=600 \
        --height=400 2>/dev/null) || {
        print_error "Операция отменена пользователем"
        exit 1
    }
    
    # Get width from preset
    local width
    width=$(get_width_from_preset "$resolution_preset")
    
    # If custom resolution selected, ask for width
    if [[ "$width" == "custom" ]]; then
        width=$(zenity --entry \
            --title="Пользовательская ширина" \
            --text="Введите ширину в пикселях:" \
            --entry-text="$DEFAULT_WIDTH" \
            --width=400 \
            --height=150 2>/dev/null) || {
            print_error "Операция отменена пользователем"
            exit 1
        }
        
        # Validate custom width
        if ! is_integer "$width" || [[ $width -lt 50 || $width -gt 4000 ]]; then
            zenity --error --text="Ширина должна быть целым числом от 50 до 4000" --width=300
            exit 1
        fi
    fi
    
    # Get FPS
    local fps
    fps=$(zenity --entry \
        --title="Частота кадров" \
        --text="Введите частоту кадров (FPS):" \
        --entry-text="$DEFAULT_FPS" \
        --width=400 \
        --height=150 2>/dev/null) || {
        print_error "Операция отменена пользователем"
        exit 1
    }
    
    # Validate fps
    if ! is_integer "$fps" || [[ $fps -lt 1 || $fps -gt 60 ]]; then
        zenity --error --text="FPS должен быть целым числом от 1 до 60" --width=300
        exit 1
    fi
    
    # Get start time
    local start
    start=$(zenity --entry \
        --title="Время начала" \
        --text="Введите время начала в секундах:" \
        --entry-text="$DEFAULT_START" \
        --width=400 \
        --height=150 2>/dev/null) || {
        print_error "Операция отменена пользователем"
        exit 1
    }
    
    # Validate start time
    if ! is_float "$start" || (( $(echo "$start < 0" | bc -l) )); then
        zenity --error --text="Время начала должно быть положительным числом" --width=300
        exit 1
    fi
    
    # Get duration
    local duration
    duration=$(zenity --entry \
        --title="Длительность" \
        --text="Введите длительность в секундах\n(оставьте пустым для конвертации всего видео):" \
        --entry-text="" \
        --width=400 \
        --height=150 2>/dev/null) || {
        print_error "Операция отменена пользователем"
        exit 1
    }
    
    # Validate duration
    if [[ -n "$duration" ]] && (! is_float "$duration" || (( $(echo "$duration <= 0" | bc -l) ))); then
        zenity --error --text="Длительность должна быть положительным числом" --width=300
        exit 1
    fi
    
    # Get output filename
    local output
    output=$(zenity --entry \
        --title="Имя выходного файла" \
        --text="Введите имя выходного файла:" \
        --entry-text="$(basename "${input_file%.*}").gif" \
        --width=500 \
        --height=150 2>/dev/null) || {
        print_error "Операция отменена пользователем"
        exit 1
    }
    
    # If output doesn't contain path, put it in same directory as input
    if [[ "$output" != /* ]] && [[ "$output" != */* ]]; then
        output="$(dirname "$input_file")/$output"
    fi
    
    echo "$width|$fps|$start|$duration|$output"
}

# Alternative GUI function using forms with custom sizing
get_gui_parameters_alternative() {
    local input_file="$1"
    local video_duration video_resolution
    
    video_duration=$(get_video_duration "$input_file")
    video_resolution=$(get_video_resolution "$input_file")
    
    # Create form with larger window size
    local form_data
    form_data=$(zenity --forms \
        --title="Параметры конвертации в GIF" \
        --text="Видео: $(basename "$input_file")\nДлительность: ${video_duration}с, Разрешение: ${video_resolution}\n" \
        --add-entry="Ширина (пиксели)" \
        --add-entry="Частота кадров (fps)" \
        --add-entry="Время начала (секунды)" \
        --add-entry="Длительность (секунды, пусто = всё видео)" \
        --add-entry="Имя выходного файла (пусто = авто)" \
        --width=600 \
        --height=400 2>/dev/null) || {
        print_error "Операция отменена пользователем"
        exit 1
    }
    
    # Parse form data
    IFS='|' read -r width fps start duration output <<< "$form_data"
    
    # Set defaults if empty
    width=${width:-$DEFAULT_WIDTH}
    fps=${fps:-$DEFAULT_FPS}
    start=${start:-$DEFAULT_START}
    output=${output:-"${input_file%.*}.gif"}
    
    # Validate inputs
    if ! is_integer "$width" || [[ $width -lt 50 || $width -gt 4000 ]]; then
        zenity --error --text="Ширина должна быть целым числом от 50 до 4000" --width=350
        exit 1
    fi
    
    if ! is_integer "$fps" || [[ $fps -lt 1 || $fps -gt 60 ]]; then
        zenity --error --text="FPS должен быть целым числом от 1 до 60" --width=350
        exit 1
    fi
    
    if ! is_float "$start" || (( $(echo "$start < 0" | bc -l) )); then
        zenity --error --text="Время начала должно быть положительным числом" --width=350
        exit 1
    fi
    
    if [[ -n "$duration" ]] && (! is_float "$duration" || (( $(echo "$duration <= 0" | bc -l) ))); then
        zenity --error --text="Длительность должна быть положительным числом" --width=350
        exit 1
    fi
    
    echo "$width|$fps|$start|$duration|$output"
}

# Console function to get user input
get_console_parameters() {
    local input_file="$1"
    local video_duration video_resolution width fps start duration output
    
    video_duration=$(get_video_duration "$input_file")
    video_resolution=$(get_video_resolution "$input_file")
    
    print_info "Видео: $(basename "$input_file")"
    print_info "Длительность: ${video_duration}с, Исходное разрешение: ${video_resolution}"
    echo
    
    # Get resolution preset
    echo "Выберите разрешение для GIF:"
    echo "1) Мобильный (480x270) - 1-5 МБ"
    echo "2) HD (720x405) - 3-10 МБ [Рекомендуется]"
    echo "3) HD+ (960x540) - 5-15 МБ"
    echo "4) Full HD (1280x720) - 10-30 МБ"
    echo "5) 2K (1920x1080) - 20-50 МБ"
    echo "6) 4K (3840x2160) - 50+ МБ"
    echo "7) Пользовательский размер"
    echo
    
    while true; do
        read -rp "Введите номер варианта [2]: " choice
        choice=${choice:-2}
        
        case "$choice" in
            1) width=480; break ;;
            2) width=720; break ;;
            3) width=960; break ;;
            4) width=1280; break ;;
            5) width=1920; break ;;
            6) width=3840; break ;;
            7) 
                while true; do
                    read -rp "Введите ширину в пикселях [$DEFAULT_WIDTH]: " width
                    width=${width:-$DEFAULT_WIDTH}
                    if is_integer "$width" && [[ $width -ge 50 && $width -le 4000 ]]; then
                        break 2
                    else
                        print_error "Ширина должна быть целым числом от 50 до 4000"
                    fi
                done
                ;;
            *) print_error "Введите число от 1 до 7" ;;
        esac
    done
    
    print_info "Выбранное разрешение: ${width}px (высота будет рассчитана автоматически)"
    
    # Get fps
    while true; do
        read -rp "Введите частоту кадров [$DEFAULT_FPS]: " fps
        fps=${fps:-$DEFAULT_FPS}
        if is_integer "$fps" && [[ $fps -ge 1 && $fps -le 60 ]]; then
            break
        else
            print_error "FPS должен быть целым числом от 1 до 60"
        fi
    done
    
    # Get start time
    while true; do
        read -rp "Введите время начала в секундах [$DEFAULT_START]: " start
        start=${start:-$DEFAULT_START}
        if is_float "$start" && (( $(echo "$start >= 0" | bc -l) )); then
            break
        else
            print_error "Время начала должно быть положительным числом"
        fi
    done
    
    # Get duration
    while true; do
        read -rp "Введите длительность в секундах (пусто = всё видео): " duration
        if [[ -z "$duration" ]] || (is_float "$duration" && (( $(echo "$duration > 0" | bc -l) ))); then
            break
        else
            print_error "Длительность должна быть положительным числом"
        fi
    done
    
    # Get output filename
    read -rp "Введите имя выходного файла [${input_file%.*}.gif]: " output
    output=${output:-"${input_file%.*}.gif"}
    
    echo "$width|$fps|$start|$duration|$output"
}

# Convert video to GIF
convert_to_gif() {
    local input_file="$1"
    local width="$2"
    local fps="$3"
    local start="$4"
    local duration="$5"
    local output_file="$6"
    local console_mode="$7"
    
    local palette_file
    palette_file=$(mktemp --suffix=.png)
    local ff_filters="fps=$fps,scale=$width:-1:flags=lanczos"
    local ff_input_options="-ss $start"
    
    # Add duration if specified
    if [[ -n "$duration" ]]; then
        ff_input_options="$ff_input_options -t $duration"
    fi
    
    # Cleanup function
    cleanup() {
        [[ -f "$palette_file" ]] && rm -f "$palette_file"
    }
    trap cleanup EXIT
    
    print_info "Начинается конвертация..."
    print_info "Входной файл: $(basename "$input_file")"
    print_info "Выходной файл: $(basename "$output_file")"
    print_info "Параметры: ${width}пкс, ${fps}fps, начало=${start}с"
    [[ -n "$duration" ]] && print_info "Длительность: ${duration}с"
    
    if [[ "$console_mode" == "yes" ]]; then
        # Console mode
        print_info "Шаг 1/2: Генерация палитры..."
        if ! ffmpeg -v warning $ff_input_options -i "$input_file" -vf "$ff_filters,palettegen" -y "$palette_file" 2>&1; then
            print_error "Не удалось сгенерировать палитру"
            exit 1
        fi
        
        print_info "Шаг 2/2: Конвертация в GIF..."
        if ! ffmpeg -v warning $ff_input_options -i "$input_file" -i "$palette_file" -lavfi "$ff_filters [x]; [x][1:v] paletteuse" -y "$output_file" 2>&1; then
            print_error "Не удалось конвертировать в GIF"
            exit 1
        fi
    else
        # GUI mode with progress
        {
            echo "10" ; echo "# Генерация палитры..."
            if ! ffmpeg -v quiet $ff_input_options -i "$input_file" -vf "$ff_filters,palettegen" -y "$palette_file" 2>/dev/null; then
                echo "100" ; echo "# Ошибка генерации палитры"
                exit 1
            fi
            
            echo "50" ; echo "# Конвертация в GIF..."
            if ! ffmpeg -v quiet $ff_input_options -i "$input_file" -i "$palette_file" -lavfi "$ff_filters [x]; [x][1:v] paletteuse" -y "$output_file" 2>/dev/null; then
                echo "100" ; echo "# Ошибка конвертации в GIF"
                exit 1
            fi
            
            echo "100" ; echo "# Конвертация завершена!"
        } | zenity --progress --title="Конвертация видео в GIF" --percentage=0 --auto-close --width=400 2>/dev/null || {
            print_error "Конвертация не удалась или была отменена"
            exit 1
        }
    fi
    
    if [[ -f "$output_file" ]]; then
        local output_size
        output_size=$(du -h "$output_file" | cut -f1)
        print_success "Конвертация завершена успешно!"
        print_success "Выходной файл: $output_file (${output_size})"
        
        if [[ "$console_mode" != "yes" ]]; then
            zenity --info --text="GIF создан успешно!\n\nФайл: $(basename "$output_file")\nРазмер: $output_size" --width=350 2>/dev/null
        fi
    else
        print_error "Выходной файл не был создан"
        exit 1
    fi
}

# Main script
main() {
    local filename="" console_mode="" width="" fps="" start="" duration="" output=""
    
    # Parse command line arguments
    while getopts ":f:cw:r:s:d:o:" opt; do
        case "${opt}" in
            f) filename="${OPTARG}" ;;
            c) console_mode="yes" ;;
            w) width="${OPTARG}" ;;
            r) fps="${OPTARG}" ;;
            s) start="${OPTARG}" ;;
            d) duration="${OPTARG}" ;;
            o) output="${OPTARG}" ;;
            \?) print_error "Неизвестная опция: -$OPTARG"; usage ;;
            :) print_error "Опция -$OPTARG требует аргумент"; usage ;;
        esac
    done
    
    shift $((OPTIND-1))
    
    # Check required parameters
    if [[ -z "$filename" ]]; then
        print_error "Файл не указан"
        usage
    fi
    
    # Check file existence
    check_file "$filename"
    
    # Check dependencies
    check_command "ffmpeg"
    check_command "bc"  # For floating point comparisons
    
    if [[ "$console_mode" != "yes" ]]; then
        check_command "zenity"
    fi
    
    # Get parameters from user if not provided via command line
    if [[ -z "$width" ]]; then
        local params
        if [[ "$console_mode" == "yes" ]]; then
            params=$(get_console_parameters "$filename")
        else
            # Method 1: Using separate dialogs for each parameter (wider input fields)
            print_info "Используется улучшенный GUI с широкими полями ввода..."
            params=$(get_gui_parameters "$filename")
        fi
        
        IFS='|' read -r width fps start duration output <<< "$params"
        
        # Debug output
        print_info "Получены параметры: width=$width, fps=$fps, start=$start, duration=$duration, output=$output"
    else
        # Use command line parameters with defaults
        width=${width:-$DEFAULT_WIDTH}
        fps=${fps:-$DEFAULT_FPS}
        start=${start:-$DEFAULT_START}
        output=${output:-"${filename%.*}.gif"}
        
        # Debug output
        print_info "Используются параметры командной строки: width=$width, fps=$fps, start=$start, duration=$duration, output=$output"
    fi
    
    # Validate that all required parameters are set
    if [[ -z "$width" || -z "$fps" || -z "$start" || -z "$output" ]]; then
        print_error "Не все параметры заданы: width='$width', fps='$fps', start='$start', output='$output'"
        exit 1
    fi
    
    # Convert video to GIF
    convert_to_gif "$filename" "$width" "$fps" "$start" "$duration" "$output" "$console_mode"
}

# Run main function
main "$@"