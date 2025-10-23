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
    echo -e "${BLUE}│ ${WHITE}ШАГ $step_num: $title"
    echo -e "${BLUE}│${NC}"

    # Разбиваем описание на строки по 75 символов
    local max_width=75
    local words=($description)
    local line=""

    for word in "${words[@]}"; do
        if [ ${#line} -eq 0 ]; then
            line="$word"
        elif [ $((${#line} + ${#word} + 1)) -le $max_width ]; then
            line="$line $word"
        else
            echo -e "${BLUE}│ ${CYAN}$line${NC}"
            line="$word"
        fi
    done

    # Выводим последнюю строку если есть
    if [ ${#line} -gt 0 ]; then
        echo -e "${BLUE}│ ${CYAN}$line${NC}"
    fi

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
    # Проверка и временная установка русской локали для корректного отображения текста
    if ! locale -a 2>/dev/null | grep -qi "ru_RU"; then
        echo "Russian locale not found. Installing for correct text display..."
        sudo sed -i 's/#ru_RU.UTF-8/ru_RU.UTF-8/' /etc/locale.gen 2>/dev/null
        sudo locale-gen 2>&1
        echo "Locale installed successfully!"
        echo "Please wait while locale is being applied..."
        sleep 2
    fi

    # Устанавливаем русскую локаль для текущей сессии скрипта
    export LANG=ru_RU.UTF-8
    export LC_ALL=ru_RU.UTF-8
    export LC_CTYPE=ru_RU.UTF-8

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
    print_step_info "1" "ВКЛЮЧЕНИЕ MULTILIB" \
        "Включение поддержки 32-битных приложений"

    print_command "grep -q \"^\\[multilib\\]\" /etc/pacman.conf || sudo sed -i '/#\\[multilib\\]/,/^#Include/ { s/^#//; }' /etc/pacman.conf && sudo pacman -Sy"

    echo -e "${CYAN}${ARROW} Зачем нужно:${NC}"
    echo -e "  • Современные компьютеры 64-битные, но многие программы еще 32-битные"
    echo -e "  • Поддержка 32-битных приложений и игр (особенно старых)"
    echo -e "  • Необходимо для Steam и большинства игр"
    echo -e "  • Нужно для Wine (запуск Windows-программ)"
    echo -e "  • Драйверы для старых приложений и оборудования"
    echo ""

    if confirm_action "Включить репозиторий multilib?"; then
        execute_command "grep -q \"^\\[multilib\\]\" /etc/pacman.conf || (sudo sed -i '/#\\[multilib\\]/,/^#Include/ { s/^#//; }' /etc/pacman.conf && sudo pacman -Sy)" \
            "Репозиторий multilib успешно включен!" \
            "Ошибка при включении multilib!"
        pause_for_user
    else
        add_skipped_action "Включение репозитория multilib"
    fi

    # ШАГ 2: Включение параллельных загрузок
    print_step_info "2" "ПАРАЛЛЕЛЬНАЯ ЗАГРУЗКА ПАКЕТОВ" \
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
    print_step_info "3" "НАСТРОЙКА ЗЕРКАЛ" \
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
    print_step_info "4" "ОБНОВЛЕНИЕ КЛЮЧЕЙ" \
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
    # ШАГ 6.1: Установка базовой системы и библиотек
    print_step_info "6.1" "БАЗОВАЯ СИСТЕМА И БИБЛИОТЕКИ" \
        "Установка системных утилит, компиляторов и всех необходимых библиотек для работы Hyprland."

    local base_packages="amd-ucode brightnessctl cairo cmake cpio curl dbus fastfetch glaze inxi libdisplay-info libinput libliftoff libnotify libx11 libxcb libxcomposite libxcursor libxfixes libxkbcommon libxrender linux-headers meson nano net-tools networkmanager ninja pacman-contrib pango pixman polkit re2 rsync sudo tomlplusplus unzip upower wayland-protocols wget qt6-multimedia xcb-proto xcb-util xcb-util-errors xcb-util-keysyms xcb-util-wm go xdg-desktop-portal xdg-user-dirs xdg-utils xorg-xwayland cava zip"

    print_command "yay -S --needed $base_packages"

    echo -e "${CYAN}${ARROW} Что будет установлено:${NC}"
    echo -e "  • ${WHITE}Базовые утилиты${NC} - curl, nano, rsync, sudo, unzip, wget, zip"
    echo -e "  • ${WHITE}Системные компоненты${NC} - fastfetch, inxi, net-tools, networkmanager, pacman-contrib"
    echo -e "  • ${WHITE}Инструменты сборки${NC} - cmake, meson, ninja"
    echo -e "  • ${WHITE}XDG утилиты${NC} - xdg-desktop-portal, xdg-user-dirs, xdg-utils"
    echo -e "  • ${WHITE}Системные сервисы${NC} - brightnessctl, libnotify, polkit, upower"
    echo -e "  • ${WHITE}Wayland библиотеки${NC} - libxcb, wayland-protocols, xcb-proto, xcb-util"
    echo -e "  • ${WHITE}Графические библиотеки${NC} - cairo, libinput, pango, pixman"
    echo -e "  • ${WHITE}X11 совместимость${NC} - libx11, libxcomposite, libxcursor, libxfixes, xorg-xwayland"
    echo -e "  • ${WHITE}Железо и прошивки${NC} - amd-ucode, linux-headers"
    echo ""

    echo -e "${CYAN}${ARROW} Зачем нужно:${NC}"
    echo -e "  • Это фундамент системы - без этого ничего не заработает"
    echo -e "  • Компиляторы нужны для сборки AUR пакетов"
    echo -e "  • Библиотеки Wayland и X11 для работы графических приложений"
    echo -e "  • Системные сервисы для управления питанием и Bluetooth"
    echo ""

    echo -e "${YELLOW}${WARNING} Это базовый набор. Установка обязательна для дальнейшей работы.${NC}"
    echo ""

    if confirm_action "Установить базовую систему и библиотеки?"; then
        execute_command "yay -S --needed $base_packages" \
            "Базовая система и библиотеки успешно установлены!" \
            "Ошибка при установке базовой системы!"
        pause_for_user
    else
        add_skipped_action "Установка базовой системы и библиотек"
    fi

    install_hyprland_core
}

# Функция для установки Hyprland и его экосистемы
install_hyprland_core() {
    # ШАГ 6.2: Установка Hyprland и его экосистемы
    print_step_info "6.2" "HYPRLAND И ЭКОСИСТЕМА" \
        "Установка самого Hyprland, его компонентов, quickshell и инструментов для работы."

    local hyprland_packages="aquamarine cliphist grim hyprland hyprland-qtutils hyprcursor hyprgraphics hyprlang hyprpolkitagent hyprutils hyprwayland-scanner matugen-bin quickshell-git satty slurp wl-clip-persist wl-clipboard xdg-desktop-portal-hyprland"

    print_command "yay -S --needed $hyprland_packages"

    echo -e "${CYAN}${ARROW} Что будет установлено:${NC}"
    echo -e "  • ${WHITE}Hyprland${NC} - сам композитор Wayland"
    echo -e "  • ${WHITE}Core зависимости${NC} - aquamarine, hyprcursor, hyprgraphics, hyprlang, hyprutils, hyprwayland-scanner"
    echo -e "  • ${WHITE}Системная интеграция${NC} - hyprpolkitagent, xdg-desktop-portal-hyprland"
    echo -e "  • ${WHITE}Quickshell${NC} - интерфейс (панель, виджеты, меню, уведомления, блокировка экрана)"
    echo -e "  • ${WHITE}Цветовые схемы${NC} - matugen-bin для генерации тем"
    echo -e "  • ${WHITE}Скриншоты${NC} - grim, satty"
    echo -e "  • ${WHITE}Буфер обмена${NC} - cliphist, wl-clip-persist, wl-clipboard"
    echo ""

    echo -e "${CYAN}${ARROW} Зачем нужно:${NC}"
    echo -e "  • Это сердце системы - сам Hyprland и все его компоненты"
    echo -e "  • Quickshell - полноценный интерфейс для Hyprland"
    echo -e "  • Инструменты для скриншотов и работы с буфером обмена"
    echo -e "  • Автоматическая генерация цветовых схем под обои"
    echo ""

    echo -e "${YELLOW}${WARNING} Это большой набор пакетов. Установка займет некоторое время в зависимости от скорости интернета.${NC}"
    echo ""

    if confirm_action "Установить Hyprland и его экосистему?"; then
        execute_command "yay -S --needed $hyprland_packages" \
            "Hyprland и его экосистема успешно установлены!" \
            "Ошибка при установке Hyprland!"
        pause_for_user
    else
        add_skipped_action "Установка Hyprland и его экосистемы"
    fi

    install_user_environment
}

# Функция для установки пользовательского окружения
install_user_environment() {
    # ШАГ 6.3: Установка пользовательского окружения
    print_step_info "6.3" "ПОЛЬЗОВАТЕЛЬСКОЕ ОКРУЖЕНИЕ" \
        "Установка Qt/GTK тем, терминалов, файлового менеджера, аудиосистемы и визуального оформления."

    local environment_packages="fish gtk2 gtk4-layer-shell gvfs-afc gvfs-mtp gvfs-smb kitty kora-icon-theme kvantum lib32-pipewire nwg-look pavucontrol pipewire pipewire-alsa pipewire-pulse polkit-gnome qt5-quickcontrols2 qt5-wayland qt5ct qt6-base qt6-declarative qt6-svg qt6-wayland qt6ct sddm udisks2 udiskie vimix-cursors winbox wireplumber xdg-desktop-portal-gtk adw-gtk-theme"

    print_command "yay -S --needed $environment_packages"

    echo -e "${CYAN}${ARROW} Что будет установлено:${NC}"
    echo -e "  • ${WHITE}Qt библиотеки${NC} - qt5-quickcontrols2, qt5-wayland, qt5ct, qt6-base, qt6-declarative, qt6-svg, qt6-wayland, qt6ct"
    echo -e "  • ${WHITE}GTK библиотеки${NC} - gtk2, gtk4-layer-shell, xdg-desktop-portal-gtk"
    echo -e "  • ${WHITE}Темы и настройки${NC} - kvantum, nwg-look"
    echo -e "  • ${WHITE}Иконки и курсоры${NC} - kora-icon-theme, vimix-cursors"
    echo -e "  • ${WHITE}Терминал${NC} - kitty"
    echo -e "  • ${WHITE}Оболочка${NC} - fish"
    echo -e "  • ${WHITE}Менеджер входа${NC} - sddm"
    echo -e "  • ${WHITE}Polkit агент${NC} - polkit-gnome"
      echo -e "  • ${WHITE}Монтирование дисков${NC} - gvfs-afc, gvfs-mtp, gvfs-smb, udisks2, udiskie"
    echo -e "  • ${WHITE}Аудиосистема${NC} - lib32-pipewire, pavucontrol, pipewire, pipewire-alsa, pipewire-pulse, wireplumber"
    echo -e "  • ${WHITE}Дополнительно${NC} - winbox"
    echo ""

    echo -e "${CYAN}${ARROW} Зачем нужно:${NC}"
    echo -e "  • Все для комфортной работы - темы, файловый менеджер, аудио"
    echo -e "  • Pipewire - современная аудиосистема (замена pulseaudio)"
    echo -e "  • Thunar - легкий и быстрый файловый менеджер"
    echo -e "  • SDDM - красивый экран входа в систему"
    echo ""

    echo -e "${YELLOW}${WARNING} Это большой набор пакетов. Установка займет некоторое время в зависимости от скорости интернета.${NC}"
    echo ""

    if confirm_action "Установить пользовательское окружение?"; then
        execute_command "yay -S --needed $environment_packages" \
            "Пользовательское окружение успешно установлено!" \
            "Ошибка при установке пользовательского окружения!"
        pause_for_user
    else
        add_skipped_action "Установка пользовательского окружения"
    fi

    install_applications
}

# Функция для установки приложений
install_applications() {
    # ШАГ 7: Установка рабочих приложений
    print_step_info "7" "УСТАНОВКА РАБОЧИХ ПРИЛОЖЕНИЙ" \
        "Установка полезных приложений для повседневной работы в Hyprland."

    local work_packages="brave-bin filezilla ghostty gnome-calculator gnome-disk-utility gnome-font-viewer gvfs loupe lsd mcfly mission-center mpv ncdu obsidian onlyoffice-bin pandoc papers qbittorrent starship telegram-desktop thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman tumbler visual-studio-code-bin xarchiver zed zoxide"

    print_command "yay -S --needed $work_packages"

    echo -e "${CYAN}${ARROW} Подробное описание приложений :${NC}"
    echo -e "  • ${WHITE}ghostty${NC} - современный быстрый терминал"
    echo -e "  • ${WHITE}starship${NC} - красивая настраиваемая командная строка"
    echo -e "  • ${WHITE}zed${NC} - простой текстовый редактор (как Блокнот)"
    echo -e "  • ${WHITE}mpv${NC} - мощный видеоплеер с поддержкой всех форматов"
    echo -e "  • ${WHITE}loupe${NC} - современный просмотрщик изображений"
    echo -e "  • ${WHITE}onlyoffice-bin${NC} - полноценный офисный пакет (Word, Excel, PowerPoint)"
    echo -e "  • ${WHITE}xarchiver${NC} - архиватор с графическим интерфейсом"
    echo -e "  • ${WHITE}papers${NC} - просмотрщик PDF документов"
    echo -e "  • ${WHITE}qbittorrent${NC} - торрент-клиент"
    echo -e "  • ${WHITE}brave${NC} - современный веб-браузер"
    echo -e "  • ${WHITE}obsidian${NC} - продвинутый редактор заметок"
    echo -e "  • ${WHITE}visual-studio-code${NC} - популярный редактор кода"
    echo -e "  • ${WHITE}telegram-desktop${NC} - мессенджер Telegram"
    echo -e "  • ${WHITE}mission-center${NC} - системный монитор (диспетчер задач)"
    echo -e "  • ${WHITE}thunar${NC} - файловый менеджер с плагинами"
    echo -e "  • ${WHITE}gvfs, tumbler${NC} - поддержка миниатюр и монтирования"
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
    print_step_info "8" "МУЛЬТИМЕДИЙНЫЕ КОДЕКИ" \
        "Установка кодеков для воспроизведения видео, аудио и других мультимедийных файлов."

    local codec_packages="a52dec faac faad2 ffmpeg flac gst-libav gst-plugin-pipewire gst-plugins-bad gst-plugins-base gst-plugins-good gst-plugins-ugly gstreamer jasper lame lib32-gst-plugins-good lib32-libva lib32-libvpx libdca libde265 libdv libdvdcss libdvdnav libdvdread libmad libmpeg2 libtheora libvorbis libvpx opencore-amr openjpeg2 speex wavpack x264 x265 xvidcore"

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
    print_step_info "9" "ШРИФТЫ И ОФОРМЛЕНИЕ" \
        "Установка красивых шрифтов, тем оформления, иконок и обоев для создания современного интерфейса."

    local font_packages="awesome-terminal-fonts inter-font nerd-fonts noto-fonts noto-fonts-emoji ttf-dejavu ttf-fira-code ttf-fira-sans ttf-font-awesome ttf-hack ttf-jetbrains-mono ttf-liberation ttf-material-design-icons ttf-ms-fonts ttf-opensans ttf-pt-sans ttf-roboto"

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
        
        echo -e "${CYAN}${ARROW} Установка Material Symbols Rounded...${NC}"
        execute_command "sudo curl -L \"https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf\" -o /usr/share/fonts/MaterialSymbolsRounded.ttf" \
            "Material Symbols Rounded успешно установлен!" \
            "Ошибка при установке Material Symbols Rounded!"
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

    install_bluetooth
}

# Функция для установки и настройки Bluetooth
install_bluetooth() {
    # ШАГ 13: Установка и настройка Bluetooth
    print_step_info "13" "НАСТРОЙКА BLUETOOTH" \
        "Установка пакетов для работы с Bluetooth устройствами."

    local bluetooth_packages="bluez blueman bluez-utils"

    print_command "yay -S --needed $bluetooth_packages"

    echo -e "${CYAN}${ARROW} Что будет установлено:${NC}"
    echo -e "  • ${WHITE}bluez${NC} - основной стек Bluetooth для Linux"
    echo -e "  • ${WHITE}blueman${NC} - графический менеджер Bluetooth"
    echo -e "  • ${WHITE}bluez-utils${NC} - утилиты для работы с Bluetooth"
    echo ""

    echo -e "${CYAN}${ARROW} Зачем нужно:${NC}"
    echo -e "  • Подключение Bluetooth наушников, клавиатур, мышей"
    echo -e "  • Передача файлов по Bluetooth"
    echo -e "  • Управление Bluetooth устройствами через GUI"
    echo ""

    if confirm_action "Установить Bluetooth?"; then
        execute_command "yay -S --needed $bluetooth_packages" \
            "Bluetooth успешно установлен!" \
            "Ошибка при установке Bluetooth!"

        echo -e "${CYAN}${ARROW} Включение службы Bluetooth...${NC}"
        execute_command "sudo systemctl enable bluetooth" \
            "Служба Bluetooth включена!" \
            "Ошибка при включении службы Bluetooth!"

        pause_for_user
    else
        add_skipped_action "Установка и настройка Bluetooth"
    fi

    install_sddm_config
}

# Функция для настройки SDDM
install_sddm_config() {
    # ШАГ 14: Настройка SDDM
    print_step_info "14" "НАСТРОЙКА SDDM" \
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
    echo -e "  • ${WHITE}Игровые утилиты${NC} - MangoHUD, GameMode"
    echo ""

    echo -e "${YELLOW}${WARNING} При согласии ничего не установится - вы попадете в меню установки различных компанентов для игр${NC}"
    echo ""

    if confirm_action "Хотите перейти к установке пакетов для игр?"; then
        install_gaming_packages
    fi

    # Установка пакетов печати
    install_printing_packages

    final_configuration
}

# Функция для установки игровых пакетов
install_gaming_packages() {
    print_step_info "15" "НАСТРОЙКА ДЛЯ ИГР" \
        "Установка пакетов и настроек для комфортной игры на Linux."

    # Игровые пакеты
    print_step_info "15.1" "ИГРОВЫЕ ПАКЕТЫ" \
        "Установка драйверов, библиотек и инструментов для комфортной игры на Linux с AMD видеокартой."

    local gaming_packages="mesa lib32-mesa vkd3d lib32-vkd3d xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau vulkan-mesa-layers ttf-liberation goverlay mangohud gamemode glfw protontricks gamescope dxvk-bin"

    print_command "yay -S --needed $gaming_packages"

    echo -e "${CYAN}${ARROW} Что это даёт для игр (объяснение ):${NC}"
    echo -e "  • ${WHITE}mesa/vulkan-radeon${NC} - современные графические драйверы AMD"
    echo -e "  • ${WHITE}lib32-*${NC} - поддержка 32-битных игр (старые игры)"
    echo -e "  • ${WHITE}mangohud${NC} - отображение FPS и температуры в играх"
    echo -e "  • ${WHITE}gamemode${NC} - автоматическая оптимизация системы для игр"
    echo -e "  • ${WHITE}dxvk${NC} - перевод DirectX в Vulkan для лучшей производительности"
    echo ""

    echo -e "${RED}${WARNING} ВНИМАНИЕ! Эти пакеты ТОЛЬКО для AMD видеокарт!${NC}"
    echo -e "${YELLOW}${WARNING} Для NVIDIA или Intel видеокарт нужны другие драйверы.${NC}"
    echo -e "${YELLOW}${WARNING} Установка этих пакетов на систему с NVIDIA может вызвать конфликты.${NC}"
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
    print_step_info "15.2" "WINE ДЛЯ WINDOWS-ИГР" \
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
    print_step_info "15.3" "УВЕЛИЧЕНИЕ ЛИМИТА ПАМЯТИ ДЛЯ ИГР" \
        "Увеличение vm.max_map_count для современных игр, требующих большого количества памяти."

    echo -e "${CYAN}${ARROW} Что будет настроено:${NC}"
    echo -e "  • ${WHITE}vm.max_map_count = 2147483642${NC} - увеличение лимита mmap для современных игр"
    echo ""

    echo -e "${CYAN}${ARROW} Зачем нужно:${NC}"
    echo -e "  • Необходимо для запуска некоторых современных игр (Star Citizen, Elden Ring и др.)"
    echo -e "  • Требуется для многих игр на Proton/Wine"
    echo -e "  • По умолчанию лимит слишком мал для требовательных игр"
    echo ""

    print_command "echo 'vm.max_map_count = 2147483642' | sudo tee /etc/sysctl.d/99-max-map-count.conf"

    echo -e "${YELLOW}${WARNING} Эта настройка безопасна и не влияет на производительность системы.${NC}"
    echo ""

    if confirm_action "Увеличить лимит памяти для игр?"; then
        echo 'vm.max_map_count = 2147483642' | sudo tee /etc/sysctl.d/99-max-map-count.conf > /dev/null

        execute_command "sudo sysctl --system" \
            "Лимит памяти успешно увеличен!" \
            "Ошибка при применении настройки!"

        echo -e "${CYAN}${ARROW} Проверка настройки vm.max_map_count:${NC}"
        sysctl vm.max_map_count
        pause_for_user
    else
        add_skipped_action "Увеличение лимита памяти для игр"
    fi
}

# Функция для установки пакетов печати
install_printing_packages() {
    print_step_info "16" "НАСТРОЙКА ПЕЧАТИ" \
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
    print_step_info "17" "ФИНАЛЬНАЯ НАСТРОЙКА" \
        "Завершающие настройки и копирование конфигурационных файлов."

    # Настройка Git
    echo -e "${BLUE}╭─────────────────────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${BLUE}│ ${WHITE} 17.1 НАСТРОЙКА GIT${NC}"
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
        echo -e "${BLUE}│ ${WHITE} 17.2 КОПИРОВАНИЕ КОНФИГУРАЦИОННЫХ ФАЙЛОВ${NC}"
        echo -e "${BLUE}╰─────────────────────────────────────────────────────────────────────────────╯${NC}"
        echo ""
        echo -e "${CYAN}${ARROW} Копирование конфигурационных файлов:${NC}"
        echo -e "  • ${WHITE}Что это${NC} - готовые настройки для Hyprland, терминалов"
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
    echo -e "${BLUE}│ ${WHITE} 17.3 ВКЛЮЧЕНИЕ СИСТЕМНЫХ СЛУЖБ${NC}"
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
