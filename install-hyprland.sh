#!/bin/bash

# ============================================================================
# 🔥 Автоматический установщик конфигурации Hyprland by Sm1tee
# ============================================================================
# Красивый и функциональный скрипт для автоматической установки
# конфигурации Hyprland на Arch Linux с полной прозрачностью процесса
# ============================================================================

# Цвета для красивого вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Символы для красивого оформления
CHECKMARK="✅"
CROSS="❌"
ARROW="➤"
STAR="⭐"
GEAR="⚙️"
PACKAGE="📦"
FIRE="🔥"
WARNING="⚠️"
QUESTION="❓"

# Массивы для отслеживания выполненных действий
COMPLETED_ACTIONS=()
SKIPPED_ACTIONS=()
FAILED_ACTIONS=()

# Функция для красивого заголовка
print_header() {
    clear
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                                                                              ║${NC}"
    echo -e "${PURPLE}║  ${FIRE} ${WHITE}АВТОМАТИЧЕСКИЙ УСТАНОВЩИК КОНФИГУРАЦИИ HYPRLAND by Sm1Tee ${WHITE} ${FIRE}            ${PURPLE}║${NC}"
    echo -e "${PURPLE}║                                                                              ║${NC}"
    echo -e "${PURPLE}║  ${CYAN}          Функциональный и прозрачный процесс установки${NC}                     ${PURPLE}║${NC}"
    echo -e "${PURPLE}║                                                                              ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Функция для вывода информации о шаге
print_step_info() {
    local step_num="$1"
    local title="$2"
    local description="$3"
    
    echo -e "${BLUE}╭─────────────────────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${BLUE}│ ${WHITE}ШАГ $step_num: $title${NC}"
    echo -e "${BLUE}│${NC}"
    echo -e "${BLUE}│ ${CYAN}$description${NC}"
    echo -e "${BLUE}╰─────────────────────────────────────────────────────────────────────────────╯${NC}"
    echo ""
}



# Функция для вывода команды
print_command() {
    local command="$1"
    echo -e "${GREEN}${GEAR} Команда для выполнения:${NC}"
    echo -e "${WHITE}$command${NC}"
    echo ""
}

# Функция для подтверждения действия
confirm_action() {
    local message="$1"
    echo -e "${YELLOW}${QUESTION} $message${NC}"
    echo -e "${CYAN}Продолжить? (y/N): ${NC}"
    read -r response
    case "$response" in
        [yYдД]* ) return 0;;
        * ) return 1;;
    esac
}

# Функция для выполнения команды с проверкой
execute_command() {
    local command="$1"
    local success_msg="$2"
    local error_msg="$3"
    
    echo -e "${CYAN}${ARROW} Выполняется: $command${NC}"
    
    if eval "$command"; then
        echo -e "${GREEN}${CHECKMARK} $success_msg${NC}"
        COMPLETED_ACTIONS+=("$success_msg")
        return 0
    else
        echo -e "${RED}${CROSS} $error_msg${NC}"
        FAILED_ACTIONS+=("$error_msg")
        return 1
    fi
}

# Функция для добавления пропущенного действия
add_skipped_action() {
    local action="$1"
    SKIPPED_ACTIONS+=("$action")
}

# Функция для паузы
pause_for_user() {
    echo -e "${CYAN}Нажмите Enter для продолжения...${NC}"
    read -r
}

# Проверка прав root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}${CROSS} Не запускайте этот скрипт от имени root!${NC}"
   echo -e "${CYAN}Скрипт сам запросит права sudo когда это необходимо.${NC}"
   exit 1
fi

# Главная функция установки
main() {
    print_header
    
    echo -e "${GREEN}${STAR} Добро пожаловать в автоматический установщик!${NC}"
    echo -e "${CYAN}Этот скрипт поможет вам установить и настроить полноценную среду Hyprland на Arch Linux.${NC}"
    echo -e "${CYAN}Каждый шаг будет объяснен, и вы сможете выбрать, что устанавливать.${NC}"
    echo ""
    
    if ! confirm_action "Начать установку?"; then
        echo -e "${YELLOW}Установка отменена пользователем.${NC}"
        exit 0
    fi

    # ШАГ 1: Включение multilib
    print_step_info "1" "ВКЛЮЧЕНИЕ РЕПОЗИТОРИЯ MULTILIB" \
        "Включение поддержки 32-битных приложений, необходимых для игр и некоторых программ."
    
    print_command "grep -q \"^\\[multilib\\]\" /etc/pacman.conf || sudo sed -i '/#\\[multilib\\]/s/^#//;s/#Include/Include/' /etc/pacman.conf && sudo pacman -Sy"
    
    echo -e "${CYAN}${ARROW} Зачем нужно:${NC}"
    echo -e "  • Современные компьютеры 64-битные, но многие программы еще 32-битные"
    echo -e "  • Поддержка 32-битных приложений и игр (особенно старых)"
    echo -e "  • Необходимо для Steam и большинства игр"
    echo -e "  • Нужно для Wine (запуск Windows-программ)"
    echo -e "  • Драйверы для старых приложений и оборудования"
    echo ""
    
    if confirm_action "Включить репозиторий multilib?"; then
        execute_command "grep -q \"^\\[multilib\\]\" /etc/pacman.conf || (sudo sed -i '/#\\[multilib\\]/s/^#//;s/#Include/Include/' /etc/pacman.conf && sudo pacman -Sy)" \
            "Репозиторий multilib успешно включен!" \
            "Ошибка при включении multilib!"
        pause_for_user
    else
        add_skipped_action "Включение репозитория multilib"
    fi

    # ШАГ 2: Включение параллельных загрузок
    print_step_info "2" "ОПТИМИЗАЦИЯ СКОРОСТИ ЗАГРУЗКИ ПАКЕТОВ" \
        "Включение одновременной загрузки 10 пакетов для ускорения установки."
    
    print_command "sudo sed -i '/^#ParallelDownloads/s/^#//;s/^ParallelDownloads = [0-9]\\+/ParallelDownloads = 10/' /etc/pacman.conf"
    
    echo -e "${CYAN}${ARROW} Зачем нужно:${NC}"
    echo -e "  • По умолчанию Arch загружает пакеты по одному (медленно)"
    echo -e "  • Ускорение установки пакетов в 10 раз"
    echo -e "  • Более эффективное использование интернет-канала"
    echo -e "  • Сокращение времени обновления системы с часов до минут"
    echo -e "  • Особенно заметно при установке больших пакетов"
    echo ""
    
    if confirm_action "Включить параллельные загрузки?"; then
        execute_command "grep -q \"^ParallelDownloads = 10\" /etc/pacman.conf || sudo sed -i '/^#ParallelDownloads/s/^#//;s/^ParallelDownloads = [0-9]\\+/ParallelDownloads = 10/' /etc/pacman.conf" \
            "Параллельные загрузки успешно включены!" \
            "Ошибка при настройке параллельных загрузок!"
        pause_for_user
    else
        add_skipped_action "Включение параллельных загрузок"
    fi

    install_mirrors_and_keys
}

# Функция для установки зеркал и ключей
install_mirrors_and_keys() {
    # ШАГ 3: Настройка зеркал
    print_step_info "3" "ОПТИМИЗАЦИЯ ЗЕРКАЛ ARCH LINUX" \
        "Автоматический выбор самых быстрых зеркал для загрузки пакетов."
    
    print_command "sudo pacman -S --needed reflector && sudo reflector --country Russia --protocol https --latest 20 --sort rate --save /etc/pacman.d/mirrorlist"
    
    echo -e "${CYAN}${ARROW} Зачем нужно:${NC}"
    echo -e "  • Arch Linux имеет серверы (зеркала) по всему миру"
    echo -e "  • Выбор самых быстрых серверов в России для вашего интернета"
    echo -e "  • Ускорение загрузки и обновления пакетов в разы"
    echo -e "  • Использование только HTTPS для безопасности"
    echo -e "  • Автоматический выбор 20 самых свежих и быстрых зеркал"
    echo ""
    
    if confirm_action "Оптимизировать зеркала?"; then
        execute_command "sudo pacman -S --needed reflector" \
            "Reflector установлен!" \
            "Ошибка при установке reflector!"
        
        execute_command "sudo reflector --country Russia --protocol https --latest 20 --sort rate --save /etc/pacman.d/mirrorlist" \
            "Зеркала успешно оптимизированы!" \
            "Ошибка при оптимизации зеркал!"
        pause_for_user
    else
        add_skipped_action "Оптимизация зеркал Arch Linux"
    fi

    # ШАГ 4: Обновление ключей Arch
    print_step_info "4" "ОБНОВЛЕНИЕ КЛЮЧЕЙ ARCH LINUX" \
        "Инициализация и обновление ключей безопасности для проверки подлинности пакетов."
    
    echo -e "${CYAN}${ARROW} Команды для выполнения:${NC}"
    echo -e "  1. sudo pacman-key --init"
    echo -e "  2. sudo pacman-key --populate archlinux"
    echo -e "  3. sudo pacman-key --refresh-keys"
    echo -e "  4. sudo pacman -Sy"
    echo ""
    
    echo -e "${CYAN}${ARROW} Зачем нужно:${NC}"
    echo -e "  • Обеспечение безопасности установки пакетов"
    echo -e "  • Проверка цифровых подписей (как печать на документах)"
    echo -e "  • Предотвращение установки поддельных или вредоносных пакетов"
    echo -e "  • Гарантия того, что пакеты действительно от разработчиков Arch"
    echo -e "  • Это может занять несколько минут, но очень важно для безопасности"
    echo ""
    
    echo -e "${YELLOW}${WARNING} Это может быть очень длительным процессом, даже если кажется, что система зависла не прерывайте его. Если не готовы долго ждать - пропустите этот шаг.${NC}"
    echo ""
    
    if confirm_action "Обновить ключи Arch Linux?"; then
        execute_command "sudo pacman-key --init" \
            "Ключи инициализированы!" \
            "Ошибка при инициализации ключей!"
        
        execute_command "sudo pacman-key --populate archlinux" \
            "Ключи Arch Linux загружены!" \
            "Ошибка при загрузке ключей!"
        
        execute_command "sudo pacman-key --refresh-keys" \
            "Ключи обновлены!" \
            "Ошибка при обновлении ключей!"
        
        execute_command "sudo pacman -Sy" \
            "База данных пакетов обновлена!" \
            "Ошибка при обновлении базы данных!"
        pause_for_user
    else
        add_skipped_action "Обновление ключей Arch Linux"
    fi

    install_aur_helpers
}

# Функция для установки AUR-помощников
install_aur_helpers() {
    # ШАГ 5: Установка YAY и PARU
    print_step_info "5" "УСТАНОВКА AUR-ПОМОЩНИКОВ" \
        "Установка yay и paru для работы с пользовательскими репозиториями AUR."
    
    echo -e "${CYAN}${ARROW} Команды для выполнения:${NC}"
    echo -e "  1. sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"
    echo -e "  2. yay -S --needed paru"
    echo ""
    
    echo -e "${CYAN}${ARROW} Зачем нужно:${NC}"
    echo -e "  • AUR (Arch User Repository) - пользовательские пакеты"
    echo -e "  • Доступ к тысячам дополнительных программ, которых нет в основном репозитории"
    echo -e "  • yay и paru - помощники для автоматической сборки и установки из AUR"
    echo -e "  • Автоматическое управление зависимостями"
    echo -e "  • Без них многие популярные программы недоступны"
    echo ""
    
    echo -e "${YELLOW}${WARNING} Для дальнейшей установки некоторых пакетов этот шаг обязателен!${NC}"
    echo ""

    if confirm_action "Установить AUR-помощники?"; then
        execute_command "sudo pacman -S --needed git base-devel" \
            "Git и base-devel установлены!" \
            "Ошибка при установке git и base-devel!"
        
        if [ ! -d "yay" ]; then
            execute_command "git clone https://aur.archlinux.org/yay.git" \
                "Репозиторий yay клонирован!" \
                "Ошибка при клонировании yay!"
        fi
        
        execute_command "cd yay && makepkg -si --noconfirm" \
            "YAY успешно установлен!" \
            "Ошибка при установке yay!"
        
        execute_command "yay -S --needed paru --noconfirm" \
            "PARU успешно установлен!" \
            "Ошибка при установке paru!"
        
        cd ..
        
        # Удаление временной папки yay после установки
        if [ -d "yay" ]; then
            execute_command "rm -rf yay" \
                "Временная папка yay удалена!" \
                "Ошибка при удалении временной папки yay!"
        fi
        
        pause_for_user
    else
        add_skipped_action "Установка AUR-помощников"
    fi

    install_hyprland_packages
}

# Функция для установки всех пакетов Hyprland
install_hyprland_packages() {
    # ШАГ 6: Установка ВСЕХ пакетов Hyprland (объединенная установка)
    print_step_info "6" "УСТАНОВКА ВСЕХ ПАКЕТОВ HYPRLAND" \
        "Установка всех необходимых пакетов для полноценной работы Hyprland - базовые системные пакеты, сам Hyprland и все компоненты."
    
    local all_packages="git hyprland ghostty kitty sddm fish reflector nano sudo msedit base-devel curl net-tools wget openssh networkmanager rsync unzip zip inxi fastfetch amd-ucode linux-firmware waybar hyprpaper xdg-desktop-portal-hyprland hyprpolkitagent hyprsysteminfo nwg-look kora-icon-theme pipewire pipewire-pulse pipewire-alsa lib32-pipewire wireplumber hyprshot slurp grim hyprland-qtutils hyprgraphics hyprwayland-scanner aquamarine hyprutils hyprlock qt6-svg qt6-declarative qt5-quickcontrols2 nwg-drawer gnome-calendar thunar pavucontrol ninja gcc cmake meson libxcb xcb-proto xcb-util xcb-util-keysyms libxfixes libx11 libxcomposite libxrender libxcursor pixman wayland-protocols cairo pango libxkbcommon xcb-util-wm xorg-xwayland libinput libliftoff libdisplay-info cpio tomlplusplus hyprlang hyprcursor xcb-util-errors glaze re2 qt5ct qt6ct qt5-wayland qt6-wayland vimix-cursors satty wl-clipboard wl-clip-persist cliphist winbox nwg-displays gtk4-layer-shell polkit-gnome xdg-user-dirs gvfs-mtp gvfs-afc gvfs-smb udisks2 udiskie gtk2 kvantum xdg-desktop-portal-gtk"
    
    print_command "sudo pacman -S --needed $all_packages"
    
    echo -e "${CYAN}${ARROW} Что будет установлено:${NC}"
    echo -e "  • ${WHITE}Базовые инструменты${NC} - git, nano, curl, wget, openssh"
    echo -e "  • ${WHITE}Системные компоненты${NC} - base-devel, networkmanager, fastfetch"
    echo -e "  • ${WHITE}Hyprland и компоненты${NC} - сам hyprland, waybar, hyprpaper, hyprlock"
    echo -e "  • ${WHITE}Аудиосистема${NC} - pipewire, wireplumber (современная замена pulseaudio)"
    echo -e "  • ${WHITE}Графические инструменты${NC} - скриншоты, темы, иконки"
    echo -e "  • ${WHITE}Файловый менеджер${NC} - thunar с плагинами"
    echo -e "  • ${WHITE}Терминалы${NC} - ghostty, kitty"
    echo -e "  • ${WHITE}Системные библиотеки${NC} - Qt, GTK, Wayland протоколы"
    echo ""
    
    echo -e "${YELLOW}${WARNING} Это большой набор пакетов. Установка займет некоторое время в зависимости от скорости интернета.${NC}"
    echo ""
    
    if confirm_action "Установить все пакеты Hyprland?"; then
        execute_command "sudo pacman -S --needed $all_packages" \
            "Все пакеты Hyprland успешно установлены!" \
            "Ошибка при установке пакетов Hyprland!"
        pause_for_user
    else
        add_skipped_action "Установка пакетов Hyprland"
    fi

    install_applications
}

# Функция для установки приложений
install_applications() {
    # ШАГ 7: Установка рабочих приложений
    print_step_info "7" "УСТАНОВКА РАБОЧИХ ПРИЛОЖЕНИЙ" \
        "Установка полезных приложений для повседневной работы в Hyprland."
    
    local work_packages="ghostty starship gvfs tumbler mousepad walker-bin mpv loupe onlyoffice-bin xarchiver papers qbittorrent gnome-disk-utility mission-center filezilla vivaldi obsidian zoxide mcfly visual-studio-code-bin telegram-desktop gnome-font-viewer gnome-calculator thunar-archive-plugin thunar-media-tags-plugin thunar-volman waypaper ncdu lsd pandoc dunst"
    
    print_command "yay -S --needed $work_packages"
    
    echo -e "${CYAN}${ARROW} Подробное описание приложений :${NC}"
    echo -e "  • ${WHITE}ghostty${NC} - современный быстрый терминал"
    echo -e "  • ${WHITE}starship${NC} - красивая настраиваемая командная строка"
    echo -e "  • ${WHITE}mousepad${NC} - простой текстовый редактор (как Блокнот)"
    echo -e "  • ${WHITE}walker-bin${NC} - быстрый запуск приложений (Alt+F2)"
    echo -e "  • ${WHITE}mpv${NC} - мощный видеоплеер с поддержкой всех форматов"
    echo -e "  • ${WHITE}loupe${NC} - современный просмотрщик изображений"
    echo -e "  • ${WHITE}onlyoffice-bin${NC} - полноценный офисный пакет (Word, Excel, PowerPoint)"
    echo -e "  • ${WHITE}xarchiver${NC} - архиватор с графическим интерфейсом"
    echo -e "  • ${WHITE}papers${NC} - просмотрщик PDF документов"
    echo -e "  • ${WHITE}qbittorrent${NC} - торрент-клиент"
    echo -e "  • ${WHITE}vivaldi${NC} - современный веб-браузер"
    echo -e "  • ${WHITE}obsidian${NC} - продвинутый редактор заметок"
    echo -e "  • ${WHITE}visual-studio-code${NC} - популярный редактор кода"
    echo -e "  • ${WHITE}telegram-desktop${NC} - мессенджер Telegram"
    echo -e "  • ${WHITE}mission-center${NC} - системный монитор (диспетчер задач)"
    echo -e "  • ${WHITE}waypaper${NC} - программа для смены обоев рабочего стола"
    echo ""
    
    echo -e "${YELLOW}${WARNING} Это большой набор приложений. Вы можете пропустить этот шаг и установить нужные программы позже.${NC}"
    echo ""
    
    if confirm_action "Установить рабочие приложения?"; then
        execute_command "yay -S --needed $work_packages --noconfirm" \
            "Рабочие приложения успешно установлены!" \
            "Ошибка при установке приложений!"
        pause_for_user
    else
        add_skipped_action "Установка рабочих приложений"
    fi

    install_codecs
}

# Функция для установки кодеков
install_codecs() {
    # ШАГ 8: Установка кодеков
    print_step_info "8" "УСТАНОВКА МУЛЬТИМЕДИЙНЫХ КОДЕКОВ" \
        "Установка кодеков для воспроизведения видео, аудио и других мультимедийных файлов."
    
    local codec_packages="gst-libav gst-plugins-base gst-plugins-good lib32-gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-plugin-pipewire gstreamer ffmpeg libde265 libdvdcss libdvdread libdvdnav a52dec faac faad2 flac jasper lame libdca libdv libmad libmpeg2 libtheora libvorbis libvpx opencore-amr openjpeg2 speex x264 x265 xvidcore wavpack"
    
    print_command "yay -S --needed $codec_packages"
    
    echo -e "${CYAN}${ARROW} Зачем нужно:${NC}"
    echo -e "  • Воспроизведение всех популярных видеоформатов (MP4, AVI, MKV, и т.д.)"
    echo -e "  • Поддержка DVD и Blu-ray дисков"
    echo -e "  • Кодирование и декодирование аудио (MP3, FLAC, OGG)"
    echo -e "  • Работа с потоковым видео (YouTube, Twitch)"
    echo -e "  • Поддержка профессиональных кодеков (x264, x265)"
    echo ""
    
    if confirm_action "Установить мультимедийные кодеки?"; then
        execute_command "yay -S --needed $codec_packages --noconfirm" \
            "Кодеки успешно установлены!" \
            "Ошибка при установке кодеков!"
        pause_for_user
    else
        add_skipped_action "Установка мультимедийных кодеков"
    fi

    install_fonts_and_themes
}

# Функция для установки шрифтов и тем
install_fonts_and_themes() {
    # ШАГ 9: Установка шрифтов, тем, иконок и обоев
    print_step_info "9" "УСТАНОВКА ШРИФТОВ, ТЕМ, ИКОНОК И ОБОЕВ" \
        "Установка красивых шрифтов, тем оформления, иконок и обоев для создания современного интерфейса."
    
    local font_packages="ttf-dejavu ttf-liberation noto-fonts ttf-font-awesome ttf-material-design-icons ttf-roboto ttf-pt-sans ttf-fira-code ttf-jetbrains-mono ttf-ms-fonts noto-fonts-emoji ttf-hack nerd-fonts ttf-fantasque-nerd otf-font-awesome awesome-terminal-fonts ttf-fira-sans"
    
    print_command "yay -S --needed $font_packages"
    
    echo -e "${CYAN}${ARROW} Подробное объяснение:${NC}"
    echo -e "  • ${WHITE}Системные шрифты${NC} - DejaVu, Liberation, Noto (для интерфейса системы)"
    echo -e "  • ${WHITE}Программистские шрифты${NC} - JetBrains Mono, Fira Code, Hack (для кода)"
    echo -e "  • ${WHITE}Иконочные шрифты${NC} - Font Awesome, Material Design (красивые иконки)"
    echo -e "  • ${WHITE}Nerd Fonts${NC} - шрифты с иконками для терминала (стрелки, символы Git)"
    echo -e "  • ${WHITE}Эмодзи${NC} - поддержка смайликов и эмодзи в системе"
    echo ""
    
    echo -e "${YELLOW}${WARNING} Это большой набор шрифтов. Установка займет время.${NC}"
    echo ""
    
    if confirm_action "Установить шрифты?"; then
        execute_command "yay -S --needed $font_packages --noconfirm" \
            "Шрифты успешно установлены!" \
            "Ошибка при установке шрифтов!"
    else
        add_skipped_action "Установка шрифтов"
    fi

    # Копирование пользовательских файлов
    echo -e "${CYAN}${ARROW} Копирование пользовательских шрифтов, тем и иконок...${NC}"
    
    if [ -d "fonts" ]; then
        echo -e "${BLUE}╭─────────────────────────────────────────────────────────────────────────────╮${NC}"
        echo -e "${BLUE}│ ${WHITE} 9.1 КОПИРОВАНИЕ ПОЛЬЗОВАТЕЛЬСКИХ ШРИФТОВ${NC}"
        echo -e "${BLUE}╰─────────────────────────────────────────────────────────────────────────────╯${NC}"
        echo ""
        echo -e "${CYAN}${ARROW} Зачем нужно копировать пользовательские шрифты:${NC}"
        echo -e "  • ${WHITE}Дополнительные шрифты${NC} - красивые шрифты, которых нет в стандартных пакетах"
        echo -e "  • ${WHITE}Уникальное оформление${NC} - персонализация внешнего вида системы"
        echo -e "  • ${WHITE}Системная доступность${NC} - шрифты станут доступны во всех приложениях"
        echo -e "  • ${WHITE}Автоматическое обнаружение${NC} - система автоматически найдет и подключит шрифты"
        echo ""
        
        print_command "sudo cp -r fonts/* /usr/share/fonts/"
        
        if confirm_action "Скопировать пользовательские шрифты из папки fonts/?"; then
            execute_command "sudo cp -r fonts/* /usr/share/fonts/" \
                "Пользовательские шрифты скопированы!" \
                "Ошибка при копировании шрифтов!"
        else
            add_skipped_action "Копирование пользовательских шрифтов"
        fi
    fi
    
    if [ -d "themes" ]; then
        echo -e "${BLUE}╭─────────────────────────────────────────────────────────────────────────────╮${NC}"
        echo -e "${BLUE}│ ${WHITE} 9.2 КОПИРОВАНИЕ ПОЛЬЗОВАТЕЛЬСКИХ ТЕМ${NC}"
        echo -e "${BLUE}╰─────────────────────────────────────────────────────────────────────────────╯${NC}"
        echo ""
        echo -e "${CYAN}${ARROW} Зачем нужно копировать пользовательские темы:${NC}"
        echo -e "  • ${WHITE}Красивое оформление${NC} - уникальные темы для GTK приложений и окон"
        echo -e "  • ${WHITE}Персонализация интерфейса${NC} - создание собственного стиля рабочего стола"
        echo -e "  • ${WHITE}Совместимость с приложениями${NC} - темы работают в Thunar, настройках и других программах"
        echo -e "  • ${WHITE}Системная интеграция${NC} - темы автоматически появятся в настройках внешнего вида"
        echo ""
        
        print_command "sudo cp -r themes/* /usr/share/themes/"
        
        if confirm_action "Скопировать пользовательские темы из папки themes/?"; then
            execute_command "sudo cp -r themes/* /usr/share/themes/" \
                "Пользовательские темы скопированы!" \
                "Ошибка при копировании тем!"
        else
            add_skipped_action "Копирование пользовательских тем"
        fi
    fi
    
    if [ -d "icons" ]; then
        echo -e "${BLUE}╭─────────────────────────────────────────────────────────────────────────────╮${NC}"
        echo -e "${BLUE}│ ${WHITE} 9.3 КОПИРОВАНИЕ ПОЛЬЗОВАТЕЛЬСКИХ ИКОНОК${NC}"
        echo -e "${BLUE}╰─────────────────────────────────────────────────────────────────────────────╯${NC}"
        echo ""
        echo -e "${CYAN}${ARROW} Зачем нужно копировать пользовательские иконки:${NC}"
        echo -e "  • ${WHITE}Красивые иконки${NC} - набор иконок для файлов и приложений"
        echo -e "  • ${WHITE}Системная интеграция${NC} - иконки появятся в файловом менеджере и меню приложений"
        echo ""
        
        print_command "sudo cp -r icons/* /usr/share/icons/"
        
        if confirm_action "Скопировать пользовательские иконки из папки icons/?"; then
            execute_command "sudo cp -r icons/* /usr/share/icons/" \
                "Пользовательские иконки скопированы!" \
                "Ошибка при копировании иконок!"
        else
            add_skipped_action "Копирование пользовательских иконок"
        fi
    fi
    
    if [ -d "обои" ]; then
        echo -e "${BLUE}╭─────────────────────────────────────────────────────────────────────────────╮${NC}"
        echo -e "${BLUE}│ ${WHITE} 9.4 КОПИРОВАНИЕ ПОЛЬЗОВАТЕЛЬСКИХ ОБОЕВ${NC}"
        echo -e "${BLUE}╰─────────────────────────────────────────────────────────────────────────────╯${NC}"
        echo ""
        echo -e "${CYAN}${ARROW} Зачем нужно копировать пользовательские обои:${NC}"
        echo -e "  • ${WHITE}Красивые обои${NC} - коллекция обоев для рабочего стола"
        echo -e "  • ${WHITE}Персонализация${NC} - создание уникального внешнего вида рабочего стола"
        echo -e "  • ${WHITE}Удобный доступ${NC} - обои будут доступны в папке Изображения"
        echo -e "  • ${WHITE}Интеграция с waypaper${NC} - программа для смены обоев найдет их автоматически"
        echo ""
        
        print_command "mkdir -p ~/Изображения && cp -r обои ~/Изображения/"
        
        if confirm_action "Скопировать пользовательские обои из папки обои/?"; then
            execute_command "mkdir -p ~/Изображения && cp -r обои ~/Изображения/" \
                "Пользовательские обои скопированы!" \
                "Ошибка при копировании обоев!"
        else
            add_skipped_action "Копирование пользовательских обоев"
        fi
    fi
    

    if confirm_action "Обновить кэш шрифтов?"; then
        execute_command "sudo fc-cache -f" \
            "Кэш шрифтов обновлен!" \
            "Ошибка при обновлении кэша шрифтов!"
    else
        add_skipped_action "Обновление кэша шрифтов"
    fi
    
    install_fish_and_settings
}

# Функция для настройки fish и системных настроек
install_fish_and_settings() {
    # ШАГ 10: Смена оболочки на Fish
    print_step_info "10" "НАСТРОЙКА ОБОЛОЧКИ FISH" \
        "Смена стандартной оболочки bash на более удобную и функциональную Fish."
    
    print_command "chsh -s \$(which fish)"
    
    echo -e "${CYAN}${ARROW} Зачем нужно:${NC}"
    echo -e "  • Fish предоставляет автодополнение из коробки (нажимаете Tab - видите варианты)"
    echo -e "  • Подсветка синтаксиса команд в реальном времени (красные = ошибка, зеленые = ОК)"
    echo -e "  • Более удобная история команд (стрелки вверх/вниз для поиска)"
    echo -e "  • Лучшая интеграция с современными инструментами разработки"
    echo -e "  • Более понятные сообщения об ошибках"
    echo ""
    
    if confirm_action "Сменить оболочку на Fish?"; then
        execute_command "chsh -s \$(which fish)" \
            "Оболочка успешно изменена на Fish!" \
            "Ошибка при смене оболочки!"
        
        echo -e "${CYAN}${ARROW} Отключение приветствия Fish...${NC}"
        execute_command "fish -c 'set -U fish_greeting'" \
            "Приветствие Fish отключено!" \
            "Ошибка при настройке Fish!"
        pause_for_user
    else
        add_skipped_action "Настройка оболочки Fish"
    fi

    # ШАГ 11: Добавление пользователя в группу input
    print_step_info "11" "НАСТРОЙКА ПРАВ ПОЛЬЗОВАТЕЛЯ" \
        "Добавление текущего пользователя в группу input для корректной работы Hyprland."
    
    print_command "sudo usermod -a -G input \"\$(whoami)\""
    
    echo -e "${CYAN}${ARROW} Зачем нужно:${NC}"
    echo -e "  • Linux использует группы для управления правами доступа"
    echo -e "  • Группа 'input' дает доступ к устройствам ввода (клавиатура, мышь, тачпад)"
    echo -e "  • Hyprland нужны эти права для корректной работы с периферией"
    echo -e "  • Без этого могут быть проблемы с управлением курсором или клавиатурой"
    echo -e "  • Это стандартная и безопасная настройка"
    echo ""
    
    if confirm_action "Добавить пользователя в группу input?"; then
        execute_command "sudo usermod -a -G input \"\$(whoami)\"" \
            "Пользователь добавлен в группу input!" \
            "Ошибка при добавлении в группу!"
        pause_for_user
    else
        add_skipped_action "Настройка прав пользователя"
    fi

    # ШАГ 12: Включение оптимизации SSD
    print_step_info "12" "ВКЛЮЧЕНИЕ ОПТИМИЗАЦИИ SSD" \
        "Включение автоматической очистки SSD для продления срока службы и повышения производительности."
    
    print_command "sudo systemctl enable fstrim.timer"
    
    echo -e "${CYAN}${ARROW} Зачем нужно:${NC}"
    echo -e "  • SSD диски работают по-другому, чем обычные жесткие диски"
    echo -e "  • Автоматическая очистка неиспользуемых блоков SSD каждую неделю"
    echo -e "  • Повышение производительности записи (файлы сохраняются быстрее)"
    echo -e "  • Продление срока службы SSD (диск прослужит дольше)"
    echo -e "  • Это безопасно и рекомендуется всеми производителями SSD"
    echo ""
    
    if confirm_action "Включить оптимизацию SSD?"; then
        execute_command "sudo systemctl enable fstrim.timer" \
            "Оптимизация SSD успешно включена!" \
            "Ошибка при включении оптимизации SSD!"
        pause_for_user
    else
        add_skipped_action "Включение оптимизации SSD"
    fi

    install_sddm_config
}

# Функция для настройки SDDM
install_sddm_config() {
    # ШАГ 13: Настройка SDDM
    print_step_info "13" "НАСТРОЙКА МЕНЕДЖЕРА ДИСПЛЕЯ SDDM" \
        "Установка красивых тем экрана входа где вы вводите пароль"
    
    echo -e "${CYAN}${ARROW} Что будет установлено:${NC}"
    echo -e "  • 25+ красивых тем для экрана входа на выбор или все сразу"
    echo -e "  • Поддержка Wayland и виртуальной клавиатуры"
    echo -e "  • Кастомные шрифты и иконки"
    echo -e "  • Анимированные фоны и эффекты"
    echo -e "  • Использование отдельного автоматизированного скрипта для этой процедуры"
    echo ""
    
    echo -e "${YELLOW}${WARNING} Для этого будет скачан другой скрипт, который проведет вас через установку темы экрана входа. ${NC}"

    echo -e "${YELLOW}${WARNING} Если вы не хотите кастомизировать свой SDDM просто пропустите этот шаг ${NC}"

    echo -e "${YELLOW}${WARNING} Вы можете ознакомится с демонстрацией тем по адресу - https://github.com/Sm1tee/sddm-theme ${NC}"
    echo ""

    if confirm_action "Установить темы SDDM?"; then
        echo -e "${BLUE}${INFO} Скачивание установщика тем SDDM...${NC}"
        
        # Скачиваем скрипт установки
        local sddm_installer="/tmp/sddm_install_$$.sh"
        if curl -sSL https://raw.githubusercontent.com/Sm1tee/sddm-theme/main/install.sh -o "$sddm_installer"; then
            chmod +x "$sddm_installer"
            echo -e "${BLUE}${INFO} Запуск установщика тем SDDM...${NC}"
            
            # Запускаем скрипт в интерактивном режиме
            if "$sddm_installer"; then
                echo -e "${GREEN}${CHECKMARK} Темы SDDM успешно установлены!${NC}"
            else
                echo -e "${YELLOW}${WARNING} Возникли проблемы при установке тем SDDM${NC}"
                echo -e "${BLUE}${INFO} Продолжаем установку остальных компонентов...${NC}"
            fi
            
            # Удаляем временный файл
            rm -f "$sddm_installer"
        else
            echo -e "${RED}${CROSS} Ошибка скачивания установщика SDDM${NC}"
            echo -e "${BLUE}${INFO} Продолжаем установку остальных компонентов...${NC}"
        fi
        pause_for_user
    else
        add_skipped_action "Установка тем SDDM"
        echo -e "${YELLOW}${WARNING} Установка тем SDDM пропущена${NC}"
    fi

    # Предложение установки игровых пакетов
    echo -e "${BLUE}╭─────────────────────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${BLUE}│ ${WHITE}ДОПОЛНИТЕЛЬНО: ПАКЕТЫ ДЛЯ ИГР${NC}"
    echo -e "${BLUE}│${NC}"
    echo -e "${BLUE}│ ${CYAN}Установка драйверов, библиотек Wine и системных оптимизаций для игр${NC}"
    echo -e "${BLUE}╰─────────────────────────────────────────────────────────────────────────────╯${NC}"
    echo ""
    
    echo -e "${CYAN}${ARROW} Что включает в себя:${NC}"
    echo -e "  • ${WHITE}Игровые драйверы${NC} - Mesa, Vulkan, DXVK для AMD видеокарт"
    echo -e "  • ${WHITE}Wine и библиотеки${NC} - для запуска Windows-игр"
    echo -e "  • ${WHITE}Системные оптимизации${NC} - настройки ядра для лучшей производительности"
    echo -e "  • ${WHITE}Игровые утилиты${NC} - MangoHUD, GameMode, Bottles"
    echo ""
    
    echo -e "${YELLOW}${WARNING} При согласии ничего не установится - вы попадете в меню установки различных компанентов для игр${NC}"
    echo ""
    
    echo -e "${CYAN}${STAR} Хотите перейти к установке пакетов для игр? (y/n): ${NC}"
    read -r gaming_response
    
    if [[ "$gaming_response" =~ ^[yYдД] ]]; then
        install_gaming_packages
    fi

    # Установка пакетов печати
    install_printing_packages

    final_configuration
}

# Функция для установки игровых пакетов
install_gaming_packages() {
    print_step_info "14" "НАСТРОЙКА ДЛЯ ИГР" \
        "Установка пакетов и настроек для комфортной игры на Linux."
    
    # Игровые пакеты
    print_step_info "14.1" "УСТАНОВКА ОСНОВНЫХ ИГРОВЫХ ПАКЕТОВ" \
        "Установка драйверов, библиотек и инструментов для комфортной игры на Linux с AMD видеокартой."
    
    local gaming_packages="mesa lib32-mesa vkd3d lib32-vkd3d xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau vulkan-mesa-layers ttf-liberation goverlay mangohud gamemode glfw protontricks gamescope dxvk-bin bottles"
    
    print_command "yay -S --needed $gaming_packages"
    
    echo -e "${CYAN}${ARROW} Что это даёт для игр (объяснение ):${NC}"
    echo -e "  • ${WHITE}mesa/vulkan-radeon${NC} - современные графические драйверы AMD"
    echo -e "  • ${WHITE}lib32-*${NC} - поддержка 32-битных игр (старые игры)"
    echo -e "  • ${WHITE}mangohud${NC} - отображение FPS и температуры в играх"
    echo -e "  • ${WHITE}gamemode${NC} - автоматическая оптимизация системы для игр"
    echo -e "  • ${WHITE}bottles${NC} - удобное управление Wine-префиксами"
    echo -e "  • ${WHITE}dxvk${NC} - перевод DirectX в Vulkan для лучшей производительности"
    echo ""
    
    echo -e "${YELLOW}${WARNING} Эти пакеты оптимизированы для AMD видеокарт. Для NVIDIA нужны другие драйверы.${NC}"
    echo ""
    
    if confirm_action "Установить игровые пакеты?"; then
        execute_command "yay -S --needed $gaming_packages --noconfirm" \
            "Игровые пакеты установлены!" \
            "Ошибка при установке игровых пакетов!"
        pause_for_user
    else
        add_skipped_action "Установка игровых пакетов"
    fi

    # Wine пакеты
    print_step_info "14.2" "УСТАНОВКА WINE ДЛЯ WINDOWS-ИГР" \
        "Wine позволяет запускать Windows-приложения и игры на Linux. Это большой набор пакетов для полной совместимости."
    
    local wine_packages="wine giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses ocl-icd lib32-ocl-icd libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader lib32-opencl-icd-loader wine-gecko wine-mono winetricks vulkan-tools zenity fontconfig lib32-fontconfig wqy-zenhei"
    
    print_command "yay -S --needed $wine_packages"
    
    echo -e "${CYAN}${ARROW} Что это даёт (объяснение ):${NC}"
    echo -e "  • ${WHITE}wine${NC} - основная программа для запуска Windows-приложений"
    echo -e "  • ${WHITE}winetricks${NC} - удобный инструмент для настройки Wine"
    echo -e "  • ${WHITE}lib32-*${NC} - 32-битные библиотеки для старых игр"
    echo -e "  • ${WHITE}vulkan/opengl${NC} - графические драйверы для игр"
    echo -e "  • ${WHITE}audio библиотеки${NC} - поддержка звука в играх"
    echo ""
    
    echo -e "${YELLOW}${WARNING} Это большой набор пакетов. Установка займёт временя.${NC}"
    echo ""
    
    if confirm_action "Установить пакеты Wine для Windows-игр?"; then
        execute_command "yay -S --needed $wine_packages --noconfirm" \
            "Пакеты Wine установлены!" \
            "Ошибка при установке Wine!"
        pause_for_user
    else
        add_skipped_action "Установка пакетов Wine"
    fi

    # Системные оптимизации
    print_step_info "14.3" "СИСТЕМНЫЕ ОПТИМИЗАЦИИ ДЛЯ ИГР" \
        "Настройка ядра Linux для максимальной производительности в играх. Эти настройки улучшат FPS и уменьшат задержки."
    
    echo -e "${CYAN}${ARROW} Что будет настроено (объяснение ):${NC}"
    echo -e "  • ${WHITE}vm.max_map_count${NC} - увеличение лимита памяти для современных игр"
    echo -e "  • ${WHITE}vm.swappiness${NC} - уменьшение использования файла подкачки"
    echo -e "  • ${WHITE}kernel.sched_*${NC} - оптимизация планировщика процессов"
    echo -e "  • ${WHITE}net.*${NC} - оптимизация сети для онлайн-игр"
    echo ""
    
    print_command "sudo tee /etc/sysctl.d/99-custom-optimizations.conf"
    
    echo -e "${YELLOW}${WARNING} Эти настройки изменят поведение системы. Они безопасны, но влияют на всю систему.${NC}"
    echo ""
    
    if confirm_action "Применить системные оптимизации для игр?"; then
        cat << 'EOF' | sudo tee /etc/sysctl.d/99-custom-optimizations.conf > /dev/null
# --- Комплексные оптимизации системы ---

# 1. Управление памятью и дисковым кэшем
# Увеличивает лимит mmap для современных игр
vm.max_map_count = 2147483642
# Снижает "желание" системы использовать swap-файл
vm.swappiness = 10
# Предотвращает фризы при уплотнении памяти
vm.compaction_unevictable_allowed = 0
# Уменьшает дисковый кэш для предотвращения "замираний" системы
vm.dirty_ratio = 10
vm.dirty_background_ratio = 5
# Заставляет систему быстрее сбрасывать кэш на диск
vm.dirty_expire_centisecs = 1500
vm.dirty_writeback_centisecs = 500

# 2. Настройки планировщика ядра для максимальной отзывчивости
# Отключает автогруппировку, чтобы игра получала максимум ресурсов
kernel.sched_autogroup_enabled = 0
# Предотвращает заикания при создании игрой дочерних процессов
kernel.sched_child_runs_first = 0
# Увеличивает временной срез для процессов, снижая накладные расходы
kernel.sched_latency_ns = 5000000
# Снижает "миграцию" процессов между ядрами CPU для лучшего использования кэша
kernel.sched_migration_cost_ns = 500000

# 3. Оптимизация сети для онлайн-игр и быстрых соединений
# Современный алгоритм управления очередью для борьбы с "bufferbloat"
net.core.default_qdisc = fq_codel
# Алгоритм контроля перегрузок от Google для максимальной скорости
net.ipv4.tcp_congestion_control = bbr
# Увеличение TCP-буферов для быстрых интернет-соединений
net.core.rmem_max = 4194304
net.core.wmem_max = 4194304
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 16384 4194304
# Увеличивает очередь для входящих пакетов, предотвращая их потерю
net.core.netdev_max_backlog = 16384
# Ускоряет закрытие неактивных соединений
net.ipv4.tcp_fin_timeout = 15
# Включает ускоренное открытие TCP-соединений
net.ipv4.tcp_fastopen = 3
# Включает определение оптимального размера пакета
net.ipv4.tcp_mtu_probing = 1
EOF
        
        execute_command "sudo sysctl --system" \
            "Системные оптимизации применены!" \
            "Ошибка при применении оптимизаций!"
        
        echo -e "${CYAN}${ARROW} Проверка настройки vm.max_map_count:${NC}"
        sysctl vm.max_map_count
        pause_for_user
    else
        add_skipped_action "Применение системных оптимизаций для игр"
    fi
}

# Функция для установки пакетов печати
install_printing_packages() {
    print_step_info "15" "НАСТРОЙКА ПЕЧАТИ" \
        "Установка пакетов для работы с принтерами и сканерами."
    
    local printing_packages="cups cups-filters cups-pdf libcups libcupsfilters splix python-pycups lib32-libcups simple-scan hplip hplip-plugin print-manager"
    
    print_command "yay -S --needed $printing_packages"
    
    echo -e "${CYAN}${ARROW} Что это даёт (объяснение ):${NC}"
    echo -e "  • ${WHITE}cups${NC} - основная система печати для Linux"
    echo -e "  • ${WHITE}hplip${NC} - драйверы для принтеров HP"
    echo -e "  • ${WHITE}simple-scan${NC} - простое приложение для сканирования"
    echo -e "  • ${WHITE}print-manager${NC} - графический интерфейс управления принтерами"
    echo ""
    
    if confirm_action "Установить пакеты для печати?"; then
        execute_command "yay -S --needed $printing_packages" \
            "Пакеты печати установлены!" \
            "Ошибка при установке пакетов печати!"
        
        execute_command "sudo systemctl enable cups" \
            "Служба печати включена!" \
            "Ошибка при включении службы печати!"
        pause_for_user
    else
        add_skipped_action "Установка пакетов печати"
    fi
}

# Финальная конфигурация
final_configuration() {
    print_step_info "16" "ФИНАЛЬНАЯ НАСТРОЙКА" \
        "Завершающие настройки и копирование конфигурационных файлов."
    
    # Настройка Git
    echo -e "${BLUE}╭─────────────────────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${BLUE}│ ${WHITE} 16.1 НАСТРОЙКА GIT${NC}"
    echo -e "${BLUE}╰─────────────────────────────────────────────────────────────────────────────╯${NC}"
    echo ""
    echo -e "${CYAN}${ARROW} Настройка Git (сохранение паролей):${NC}"
    echo -e "  • ${WHITE}Что это${NC} - автоматическое сохранение паролей для GitHub/GitLab"
    echo -e "  • ${WHITE}Зачем нужно${NC} - чтобы не вводить пароль каждый раз при git push/pull"
    echo -e "  • ${WHITE}Команда${NC} - git config --global credential.helper store"
    echo ""
    
    if confirm_action "Включить сохранение паролей Git?"; then
        execute_command "git config --global credential.helper store" \
            "Сохранение паролей Git включено!" \
            "Ошибка при настройке Git!"
    else
        add_skipped_action "Настройка сохранения паролей Git"
    fi

    # Копирование конфигурационных файлов
    if [ -d ".config" ]; then
        echo -e "${BLUE}╭─────────────────────────────────────────────────────────────────────────────╮${NC}"
        echo -e "${BLUE}│ ${WHITE} 16.2 КОПИРОВАНИЕ КОНФИГУРАЦИОННЫХ ФАЙЛОВ${NC}"
        echo -e "${BLUE}╰─────────────────────────────────────────────────────────────────────────────╯${NC}"
        echo ""
        echo -e "${CYAN}${ARROW} Копирование конфигурационных файлов:${NC}"
        echo -e "  • ${WHITE}Что это${NC} - готовые настройки для Hyprland, waybar, терминалов"
        echo -e "  • ${WHITE}Зачем нужно${NC} - чтобы система сразу работала красиво и удобно"
        echo -e "  • ${WHITE}Откуда${NC} - из папки .config в текущей директории"
        echo -e "  • ${WHITE}Куда${NC} - в ~/.config (домашняя папка пользователя)"
        echo ""
        
        if confirm_action "Скопировать конфигурационные файлы из .config/?"; then
            execute_command "cp -r .config/* ~/.config/" \
                "Конфигурационные файлы скопированы!" \
                "Ошибка при копировании конфигов!"
        else
            add_skipped_action "Копирование конфигурационных файлов"
        fi
    fi

    # Включение служб
    echo -e "${BLUE}╭─────────────────────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${BLUE}│ ${WHITE} 16.3 ВКЛЮЧЕНИЕ СИСТЕМНЫХ СЛУЖБ${NC}"
    echo -e "${BLUE}╰─────────────────────────────────────────────────────────────────────────────╯${NC}"
    echo ""
    echo -e "${CYAN}${ARROW} Включение необходимых системных служб...${NC}"
    echo ""
    
    # SDDM - менеджер дисплея
    echo -e "${CYAN}${ARROW} Служба SDDM (менеджер дисплея):${NC}"
    echo -e "  • ${WHITE}Что это${NC} - экран входа в систему"
    echo -e "  • ${WHITE}Зачем нужно${NC} - для входа в Hyprland после перезагрузки"
    echo -e "  • ${WHITE}Команда${NC} - sudo systemctl enable sddm"
    echo ""
    
    if confirm_action "Включить службу SDDM (экран входа)?"; then
        execute_command "sudo systemctl enable sddm" \
            "Служба SDDM включена!" \
            "Ошибка при включении SDDM!"
    else
        add_skipped_action "Включение службы SDDM"
    fi
    
    # NetworkManager - управление сетью
    echo -e "${CYAN}${ARROW} Служба NetworkManager (управление сетью):${NC}"
    echo -e "  • ${WHITE}Что это${NC} - система управления сетевыми соединениями"
    echo -e "  • ${WHITE}Зачем нужно${NC} - для автоматического подключения к Wi-Fi и Ethernet"
    echo -e "  • ${WHITE}Команда${NC} - sudo systemctl enable NetworkManager"
    echo ""
    
    if confirm_action "Включить службу NetworkManager (управление сетью)?"; then
        execute_command "sudo systemctl enable NetworkManager" \
            "Служба NetworkManager включена!" \
            "Ошибка при включении NetworkManager!"
    else
        add_skipped_action "Включение службы NetworkManager"
    fi

    # Финальное сообщение
    print_header
    echo -e "${GREEN}${FIRE} УСТАНОВКА ЗАВЕРШЕНА! ${FIRE}${NC}"
    echo ""
    show_final_report
    echo ""
}

# Функция для показа итогового отчета
show_final_report() {
    echo -e "${CYAN}╭─────────────────────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│ ${WHITE}ИТОГОВЫЙ ОТЧЕТ УСТАНОВКИ${NC}"
    echo -e "${CYAN}╰─────────────────────────────────────────────────────────────────────────────╯${NC}"
    echo ""
    
    # Показываем выполненные действия
    if [ ${#COMPLETED_ACTIONS[@]} -gt 0 ]; then
        echo -e "${GREEN}${CHECKMARK} УСПЕШНО ВЫПОЛНЕНО (${#COMPLETED_ACTIONS[@]}):${NC}"
        for action in "${COMPLETED_ACTIONS[@]}"; do
            echo -e "  ${GREEN}•${NC} $action"
        done
        echo ""
    fi
    
    # Показываем пропущенные действия
    if [ ${#SKIPPED_ACTIONS[@]} -gt 0 ]; then
        echo -e "${YELLOW}${WARNING} ПРОПУЩЕНО (${#SKIPPED_ACTIONS[@]}):${NC}"
        for action in "${SKIPPED_ACTIONS[@]}"; do
            echo -e "  ${YELLOW}•${NC} $action"
        done
        echo ""
    fi
    
    # Показываем неудачные действия
    if [ ${#FAILED_ACTIONS[@]} -gt 0 ]; then
        echo -e "${RED}${CROSS} ОШИБКИ (${#FAILED_ACTIONS[@]}):${NC}"
        for action in "${FAILED_ACTIONS[@]}"; do
            echo -e "  ${RED}•${NC} $action"
        done
        echo ""
    fi
    
    # Рекомендации
    echo -e "${CYAN}╭─────────────────────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│ ${YELLOW}${WARNING} РЕКОМЕНДАЦИИ:${NC}"
    echo -e "${CYAN}│${NC}"
    echo -e "${CYAN}│ ${WHITE}1. Перезагрузите систему для применения всех изменений${NC}"
    echo -e "${CYAN}│ ${WHITE}2. Выберите Hyprland в менеджере входа${NC}"
    echo -e "${CYAN}│ ${WHITE}3. Проверьте работу всех компонентов${NC}"
    if [ ${#FAILED_ACTIONS[@]} -gt 0 ]; then
        echo -e "${CYAN}│ ${WHITE}4. Исправьте ошибки из списка выше при необходимости${NC}"
    fi
    echo -e "${CYAN}╰─────────────────────────────────────────────────────────────────────────────╯${NC}"
}

# Запуск основной функции
main "$@"