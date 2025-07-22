# 🔥 Arch Hyprland Auto-Installer by Sm1tee


## Демонстрация

[![Посмотрите видео обзор](https://img.youtube.com/vi/Rj_KQUqIx7U/maxresdefault.jpg)](https://www.youtube.com/watch?v=Rj_KQUqIx7U "Нажмите для просмотра видео")

*Нажмите на изображение выше, чтобы посмотреть видео обзор проекта*


<div align="center">

![Hyprland](https://img.shields.io/badge/Hyprland-Dynamic%20Tiling-blue?style=for-the-badge&logo=wayland&logoColor=white)
![Arch Linux](https://img.shields.io/badge/Arch%20Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Shell Script](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)

**Автоматический установщик полноценной конфигурации Hyprland на Arch Linux и Arch-based дистрибутивах**

*Красивый, функциональный и полностью настроенный рабочий стол одной командой*

</div>

---

## 📋 Содержание

- [🎯 О проекте](#-о-проекте)
- [🚀 Быстрый старт](#-быстрый-старт)
- [📦 Что можно будет установить в процессе](#-Что-можно-будет-установить-в-процессе)
- [🎨 SDDM Темы](#-sddm-темы)
- [⚙️ Конфигурация](#️-конфигурация)
- [🔧 Горячие клавиши](#-горячие-клавиши)
- [🐛 Решение проблем](#-решение-проблем)

---

## 🎯 О проекте

Этот репозиторий содержит **полностью автоматизированный установщик** современной конфигурации Hyprland для Arch Linux и Arch-based дистрибутивов (Manjaro, EndeavourOS, ArcoLinux и др.). Скрипт проведет вас через весь процесс установки с подробными объяснениями каждого шага.

### 🌟 Почему этот установщик?

- **🔍 Прозрачность** - каждый шаг объясняется простым языком
- **🎛️ Контроль** - вы выбираете, что устанавливать
- **💎 Качество** - тщательно подобранные пакеты и конфигурации

---


## 🚀 Быстрый старт

### Предварительные требования
- Свежая установка Arch Linux или Arch-based дистрибутива
- Подключение к интернету
- Пользователь с правами sudo

### Запуск установки одной командой

```bash
curl -L https://github.com/Sm1tee/dotfiles/archive/refs/heads/master.zip -o dotfiles.zip && unzip -q dotfiles.zip && mv dotfiles-master dotfiles && rm dotfiles.zip && cd dotfiles && chmod +x install-hyprland.sh && ./install-hyprland.sh
```

---

## 📦 Что можно будет установить в процессе:

<details>
<summary><b>🏗️ Основные пакеты Hyprland</b></summary>

- **Hyprland** - динамический тайлинговый композитор
- **Waybar** - настраиваемая панель задач  
- **Hyprpaper** - установка обоев
- **Hyprlock** - блокировщик экрана
- **Hyprshot** - инструмент для скриншотов
- **SDDM** - менеджер дисплея
- **Fish** - современная командная оболочка

</details>

<details>
<summary><b>🎨 Оформление и шрифты</b></summary>

- **Шрифты**: DejaVu, Liberation, Noto, JetBrains Mono, Fira Code, Hack, Nerd Fonts, MS Fonts
- **Иконки**: Kora Icon Theme
- **Курсоры**: Vimix
- **Темы**: nwg-look для настройки GTK тем
- **Обои**: Коллекция пользовательских обоев из папки `обои/`

</details>

<details>
<summary><b>📱 Рабочие приложения</b></summary>

- **Терминалы**: Ghostty, Kitty
- **Браузер**: Vivaldi
- **Офис**: OnlyOffice
- **Медиа**: MPV (видео), Loupe (изображения)
- **Разработка**: VS Code, Obsidian
- **Файлы**: Thunar с плагинами (archive, media-tags, volman)
- **Текст**: Mousepad
- **Системные**: Mission Center, Waypaper, Gnome Calculator
- **Сеть**: Filezilla, Telegram Desktop
- **Архивы**: Xarchiver
- **PDF**: Papers
- **Торренты**: qBittorrent

</details>

<details>
<summary><b>🔧 Системные инструменты</b></summary>

- **AUR помощники**: Yay, Paru
- **Скриншоты**: Grim, Slurp, Satty
- **Буфер обмена**: Cliphist, wl-clipboard
- **Уведомления**: Dunst
- **Запуск приложений**: Walker
- **Аудио**: PipeWire, WirePlumber, Pavucontrol
- **Сеть**: NetworkManager
- **Диски**: udisks2, udiskie, gnome-disk-utility
- **Системная информация**: fastfetch, inxi
- **Командная строка**: starship, zoxide, mcfly, lsd, ncdu

</details>

<details>
<summary><b>🎮 Дополнительные пакеты (опционально)</b></summary>

- **Игры**: Mesa, Vulkan, GameMode, MangoHUD, Bottles, Gamescope
- **Wine**: Полный набор для запуска Windows приложений
- **Кодеки**: GStreamer, FFmpeg, x264, x265 и другие мультимедийные кодеки
- **Печать**: CUPS, драйверы принтеров, Simple Scan

</details>

---

## 🎨 SDDM Темы

Скрипт также предлагает установку красивых тем для экрана входа SDDM из отдельного репозитория:

**🔗 [SDDM Theme Collection](https://github.com/Sm1tee/sddm-theme)**

- 25+ красивых тем для экрана входа
- Поддержка Wayland и виртуальной клавиатуры  
- Кастомные шрифты и иконки
- Анимированные фоны и эффекты
- Автоматизированный скрипт установки

---

### 📁 Структура конфигурации

```
.config/hypr/
├── hyprland.conf      # Главный файл конфигурации
├── autostart.conf     # Автозапуск приложений
├── binds.conf         # Горячие клавиши
├── input.conf         # Настройки ввода
├── look.conf          # Внешний вид и анимации
├── monitor.conf       # Настройки мониторов
├── win-work.conf      # Поведение окон
└── enfi.conf          # Переменные окружения
```

### 🎯 Быстрая настройка после установки:

1. **Смена обоев**: `waypaper` или отредактируйте `hyprpaper.conf`
2. **Темы**: используйте `nwg-look` для GTK тем
3. **Панель**: настройте Waybar в `.config/waybar/`
4. **Горячие клавиши**: отредактируйте `binds.conf`

---

## ⚙️ Конфигурация

### 🖥️ Мониторы

Отредактируйте `.config/hypr/monitor.conf`:

```bash
# Пример для 1080p монитора
monitor=,1920x1080@60,0x0,1

# Для нескольких мониторов
monitor=DP-1,1920x1080@144,0x0,1
monitor=HDMI-A-1,1920x1080@60,1920x0,1
```

Подробная документация по настройке мониторов: [https://wiki.hyprland.org/Configuring/Monitors/](https://wiki.hyprland.org/Configuring/Monitors/)



---

## 🔧 Горячие клавиши

### 🚀 Основные

| Комбинация | Действие |
|------------|----------|
| `Super + Q` | Открыть терминал (Ghostty) |
| `Super + C` | Закрыть окно |
| `Super + Tab` | Запуск приложений (Walker) |
| `Super + F4` | Полноэкранный режим |
| `Super + F2` | Переключить разделение |
| `Super + E` | Файловый менеджер (Thunar) |
| `Super + B` | Браузер (Vivaldi) |
| `Super + T` | Текстовый редактор (Mousepad) |
| `Super + V` | VS Code |
| `Super + O` | Obsidian |
| `Super + W` | OnlyOffice |
| `Super + D` | Telegram |
| `Super + L` | Заблокировать экран |
| `Super + Escape` | Выйти из Hyprland |

### 🖼️ Скриншоты

| Комбинация | Действие |
|------------|----------|
| `Print` | Скриншот области с редактором Satty |
| `Shift + Print` | Скриншот всего экрана с Satty |

### 🖥️ Рабочие пространства

| Комбинация | Действие |
|------------|----------|
| `Super + 1-9,0` | Переключиться на рабочее пространство |
| `Super + Shift + 1-9,0` | Переместить окно на рабочее пространство |
| `Super + S` | Специальное рабочее пространство |
| `Alt + Tab` | Предыдущее рабочее пространство |

### 🎯 Управление окнами

| Комбинация | Действие |
|------------|----------|
| `Super + Стрелки` | Переключение фокуса между окнами |
| `Super + ЛКМ` | Перетаскивание окна |
| `Super + ПКМ` | Изменение размера окна |
| `Super + G` | Группировка окон |
| `Super + P` | Закрепить окно |

---

## 🐛 Решение проблем

<details>
<summary><b>❌ Hyprland не запускается</b></summary>

1. Проверьте логи: `journalctl -u sddm`
2. Убедитесь, что пользователь в группе `input`
3. Перезагрузите систему после установки

</details>

<details>
<summary><b>🔊 Нет звука</b></summary>

1. Проверьте PipeWire: `systemctl --user status pipewire`
2. Запустите: `systemctl --user restart pipewire`
3. Используйте `pavucontrol` для настройки

</details>

<details>
<summary><b>🖼️ Не работают скриншоты</b></summary>

1. Установите: `yay -S satty grim slurp`
2. Проверьте привязки клавиш в `binds.conf`

</details>

<details>
<summary><b>🎨 Темы не применяются</b></summary>

1. Запустите: `nwg-look`
2. Обновите кэш: `sudo fc-cache -f`
3. Перезапустите приложения

</details>

<details>
<summary><b>🤔 Любые другие проблемы</b></summary>

Приложите содержание данной инструкции + текст скрипта автоустановки и описание своей проблемы в диалог с любым чат-ботом (например ChatGPT) и вы получите развернутое решение.

</details>

---

## 🙏 Благодарности

- **Hyprland** - за потрясающий композитор
- **Arch Linux** - за гибкую систему
- **Сообщество** - за поддержку и обратную связь

---

<div align="center">

**⭐ Поставьте звезду, если проект был полезен!**

*Создано с ❤️ для сообщества Arch Linux*

</div>
