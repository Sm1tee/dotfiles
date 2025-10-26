# 🎨 sm1teePanel

> Современная, настраиваемая оболочка рабочего стола для Wayland-композиторов, построенная на Quickshell

<div align="center">

![Wayland](https://img.shields.io/badge/Wayland-Compatible-blue?style=for-the-badge)
![QML](https://img.shields.io/badge/QML-Qt6-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-Check_Source-orange?style=for-the-badge)

</div>

---

## 📋 Содержание

- [О проекте](#-о-проекте)
- [Возможности](#-возможности)
- [Архитектура](#-архитектура)
- [Установка](#-установка)
- [Конфигурация](#-конфигурация)
- [Модули](#-модули)
- [Плагины](#-плагины)
- [Темы](#-темы)
- [IPC API](#-ipc-api)
- [Разработка](#-разработка)

---

## 🌟 О проекте

**sm1teePanel** — это полнофункциональная оболочка рабочего стола для Wayland, вдохновленная Material Design 3. Проект построен на базе [Quickshell](https://quickshell.outfoxxed.me/) и предоставляет богатый набор виджетов, модулей и настроек для создания современного и продуктивного рабочего окружения.

### Поддерживаемые композиторы

- ✅ **Hyprland** — полная поддержка
- ✅ **Niri** — полная поддержка
- ⚠️ Другие Wayland-композиторы — базовая поддержка

---

## ✨ Возможности

### 🎯 Основные функции

- **🎨 Динамическая тематизация** — автоматическая генерация цветовых схем из обоев с помощью `matugen`
- **🌓 Светлая/Темная темы** — переключение режимов с плавными переходами
- **📦 Система плагинов** — расширяемая архитектура для пользовательских виджетов
- **🔧 Гибкая настройка** — детальная конфигурация всех компонентов
- **🎭 Множество тем** — встроенные темы + поддержка Catppuccin
- **🖥️ Мультимониторность** — полная поддержка нескольких экранов
- **⚡ Производительность** — оптимизированная отрисовка и ленивая загрузка

### 🧩 Компоненты интерфейса

#### DankBar (Верхняя панель)
- Настраиваемые виджеты (левая/центральная/правая секции)
- Автоскрытие и позиционирование (верх/низ/лево/право)
- Переключатель рабочих столов
- Индикаторы системных ресурсов (CPU, RAM, GPU, температура)
- Медиаплеер с обложками альбомов
- Погода с автоопределением местоположения
- Системный трей
- Часы с настраиваемым форматом

#### Dock (Панель приложений)
- Закрепленные и запущенные приложения
- Группировка по приложениям
- Автоскрытие
- Настраиваемое позиционирование

#### Модальные окна
- **Spotlight** — быстрый поиск и запуск приложений
- **Control Center** — управление системой (звук, яркость, сеть, Bluetooth)
- **Notification Center** — центр уведомлений с группировкой
- **Power Menu** — меню выключения/перезагрузки
- **Process List** — диспетчер задач с мониторингом системы
- **App Drawer** — полный список приложений
- **Clipboard History** — история буфера обмена
- **Settings** — панель настроек

#### Дополнительные модули
- **Lock Screen** — экран блокировки с виртуальной клавиатурой
- **Notepad** — встроенный блокнот с поддержкой Markdown
- **OSD** — экранные индикаторы (громкость, яркость, микрофон)
- **Toast** — всплывающие уведомления
- **DankDash** — информационная панель (обзор, медиа, погода)

---

## 🏗️ Архитектура

### Структура проекта

```
sm1teePanel/
├── Common/              # Общие утилиты и синглтоны
│   ├── Theme.qml       # Система тем и цветов
│   ├── SettingsData.qml # Управление настройками
│   ├── SessionData.qml  # Данные сессии
│   └── ...
├── Modules/            # Основные модули UI
│   ├── DankBar/       # Верхняя панель
│   ├── Dock/          # Панель приложений
│   ├── Lock/          # Экран блокировки
│   ├── Notepad/       # Блокнот
│   ├── Notifications/ # Уведомления
│   ├── OSD/           # Экранные индикаторы
│   └── ...
├── Modals/            # Модальные окна
│   ├── Spotlight/     # Поиск приложений
│   ├── Settings/      # Настройки
│   ├── Clipboard/     # История буфера
│   └── ...
├── Services/          # Бэкенд-сервисы
│   ├── AudioService.qml
│   ├── NetworkService.qml
│   ├── NotificationService.qml
│   ├── PluginService.qml
│   └── ...
├── Widgets/           # Переиспользуемые компоненты
│   ├── DankButton.qml
│   ├── DankSlider.qml
│   ├── DankPopout.qml
│   └── ...
├── Shaders/           # GLSL шейдеры для эффектов
├── matugen/           # Шаблоны для matugen
└── scripts/           # Вспомогательные скрипты
```

### Ключевые сервисы

| Сервис | Описание |
|--------|----------|
| `CompositorService` | Определение и взаимодействие с композитором |
| `NotificationService` | Управление уведомлениями с группировкой |
| `AudioService` | Управление звуком (PipeWire/PulseAudio) |
| `NetworkService` | Управление сетевыми подключениями |
| `BluetoothService` | Управление Bluetooth-устройствами |
| `BatteryService` | Мониторинг батареи и питания |
| `WeatherService` | Получение данных о погоде |
| `PluginService` | Загрузка и управление плагинами |
| `SessionService` | Управление сессией (logout, suspend, etc.) |
| `IdleService` | Отслеживание активности и блокировка |

---

## 📦 Установка

### Зависимости

#### Обязательные
- **Quickshell** (последняя версия)
- **Qt 6** (QtQuick, QtCore)
- **Wayland**
- Композитор: **Hyprland** или **Niri**

#### Рекомендуемые
- `matugen` — для динамической тематизации
- `NetworkManager` — для управления сетью
- `BlueZ` — для Bluetooth
- `PipeWire` / `PulseAudio` — для звука
- `UPower` — для информации о батарее

### Установка из исходников

```bash
# Клонирование репозитория
git clone https://github.com/yourusername/sm1teePanel.git
cd sm1teePanel

# Создание директории конфигурации
mkdir -p ~/.config/quickshell

# Копирование файлов
cp -r . ~/.config/quickshell/sm1teePanel

# Запуск
quickshell -c ~/.config/quickshell/sm1teePanel/shell.qml
```

### Автозапуск

#### Для Hyprland
Добавьте в `~/.config/hypr/hyprland.conf`:
```conf
exec-once = quickshell -c ~/.config/quickshell/sm1teePanel/shell.qml
```

#### Для Niri
Добавьте в `~/.config/niri/config.kdl`:
```kdl
spawn-at-startup "quickshell" "-c" "~/.config/quickshell/sm1teePanel/shell.qml"
```

---

## ⚙️ Конфигурация

### Файлы настроек

Настройки хранятся в:
```
~/.config/sm1teePanel/
├── settings.json          # Основные настройки
├── session.json           # Данные сессии
├── plugin_settings.json   # Настройки плагинов
└── plugins/              # Пользовательские плагины
```

### Основные настройки

```json
{
  "currentThemeName": "blue",
  "dankBarPosition": 0,
  "dankBarAutoHide": false,
  "showDock": true,
  "dockPosition": 1,
  "use24HourClock": true,
  "weatherEnabled": true,
  "animationSpeed": 2,
  "cornerRadius": 12,
  "fontScale": 1.0
}
```

### Настройка виджетов панели

Виджеты можно настроить через UI или напрямую в `settings.json`:

```json
{
  "dankBarLeftWidgets": [
    "launcherButton",
    "workspaceSwitcher",
    "focusedWindow"
  ],
  "dankBarCenterWidgets": [
    "clock",
    "music",
    "weather"
  ],
  "dankBarRightWidgets": [
    "systemTray",
    "cpuUsage",
    "memUsage",
    "battery",
    "controlCenterButton"
  ]
}
```

---

## 🧩 Модули

### DankBar

Настраиваемая панель с поддержкой виджетов.

**Доступные виджеты:**
- `launcherButton` — кнопка запуска приложений
- `workspaceSwitcher` — переключатель рабочих столов
- `focusedWindow` — название активного окна
- `clock` — часы и дата
- `music` — медиаплеер
- `weather` — погода
- `systemTray` — системный трей
- `clipboard` — история буфера обмена
- `cpuUsage` — использование CPU
- `memUsage` — использование RAM
- `cpuTemp` — температура CPU
- `gpuUsage` — использование GPU
- `notificationButton` — центр уведомлений
- `battery` — индикатор батареи
- `controlCenterButton` — центр управления

### Dock

Панель запущенных и закрепленных приложений.

**Возможности:**
- Группировка окон по приложениям
- Drag & Drop для изменения порядка
- Контекстное меню для управления
- Индикаторы активности

### Lock Screen

Экран блокировки с виртуальной клавиатурой.

**Возможности:**
- Ввод пароля
- Отображение времени и даты
- Меню питания
- Автоблокировка при бездействии

### Notepad

Встроенный блокнот с поддержкой вкладок.

**Возможности:**
- Множественные вкладки
- Поддержка Markdown
- Автосохранение
- Настраиваемый шрифт и размер
- Нумерация строк

---

## 🔌 Плагины

### Создание плагина

Структура плагина:
```
~/.config/sm1teePanel/plugins/my-plugin/
├── plugin.json          # Манифест
├── MyPlugin.qml         # Основной компонент
└── Settings.qml         # Настройки (опционально)
```

#### plugin.json
```json
{
  "id": "my-plugin",
  "name": "My Plugin",
  "version": "1.0.0",
  "author": "Your Name",
  "description": "Plugin description",
  "component": "./MyPlugin.qml",
  "settings": "./Settings.qml",
  "type": "widget",
  "icon": "extension",
  "permissions": ["network", "filesystem"]
}
```

#### MyPlugin.qml
```qml
import QtQuick
import qs.Modules.Plugins

PluginComponent {
    id: root
    
    // Доступ к сервисам
    property var pluginService
    property string pluginId
    
    // UI компонент
    BasePill {
        text: "My Plugin"
        icon: "extension"
        
        onClicked: {
            // Действие при клике
        }
    }
    
    // Сохранение данных
    Component.onCompleted: {
        const data = pluginService.loadPluginData(pluginId, "myKey", "default")
    }
}
```

### Типы плагинов

- **widget** — виджет для DankBar
- **daemon** — фоновый сервис без UI

### API плагинов

```javascript
// Сохранение данных
pluginService.savePluginData(pluginId, "key", value)

// Загрузка данных
pluginService.loadPluginData(pluginId, "key", defaultValue)

// Создание варианта
pluginService.createPluginVariant(pluginId, "Variant Name", config)
```

---

## 🎨 Темы

### Встроенные темы

**Generic:**
- Blue, Deep Blue, Purple, Green, Orange, Red, Cyan, Pink, Amber, Coral

**Catppuccin:**
- Rosewater, Flamingo, Pink, Mauve, Red, Maroon, Peach, Yellow
- Green, Teal, Sky, Sapphire, Blue, Lavender

### Динамическая тема

Автоматическая генерация цветовой схемы из обоев:

```javascript
// Переключение на динамическую тему
Theme.switchTheme("dynamic")

// Выбор схемы matugen
SettingsData.matugenScheme = "scheme-tonal-spot"
// Варианты: scheme-tonal-spot, scheme-content, scheme-expressive,
//           scheme-monochrome, scheme-neutral
```

### Пользовательская тема

Создайте JSON-файл с цветами:

```json
{
  "name": "My Theme",
  "dark": {
    "primary": "#42a5f5",
    "primaryText": "#ffffff",
    "surface": "#1a1c1e",
    "surfaceText": "#e3e8ef",
    "background": "#121212"
  },
  "light": {
    "primary": "#1976d2",
    "primaryText": "#ffffff",
    "surface": "#ffffff",
    "surfaceText": "#1a1c1e",
    "background": "#f5f5f5"
  }
}
```

Загрузите через настройки или:
```javascript
Theme.loadCustomThemeFromFile("/path/to/theme.json")
Theme.switchTheme("custom")
```

### Тематизация системы

sm1teePanel может автоматически применять темы к:
- KDE приложениям (через KColorScheme)
- Терминалам (Ghostty)
- Композитору (Niri)

---

## 🔧 IPC API

sm1teePanel предоставляет IPC API для управления через командную строку.

### Использование

```bash
# Общий формат
quickshell -c ~/.config/quickshell/sm1teePanel/shell.qml --ipc <target> <command> [args]
```

### Доступные команды

#### Power Menu
```bash
quickshell --ipc powermenu open
quickshell --ipc powermenu close
quickshell --ipc powermenu toggle
```

#### Control Center
```bash
quickshell --ipc control-center open
quickshell --ipc control-center close
quickshell --ipc control-center toggle
```

#### Dash
```bash
quickshell --ipc dash open [tab]
quickshell --ipc dash close
quickshell --ipc dash toggle [tab]
# tab: media, weather, или пусто для обзора
```

#### Notepad
```bash
quickshell --ipc notepad open
quickshell --ipc notepad close
quickshell --ipc notepad toggle
```

#### Spotlight
```bash
quickshell --ipc spotlight open
quickshell --ipc spotlight close
quickshell --ipc spotlight toggle
```

#### App Drawer
```bash
quickshell --ipc appdrawer open
quickshell --ipc appdrawer close
quickshell --ipc appdrawer toggle
```

#### Process List
```bash
quickshell --ipc processlist open
quickshell --ipc processlist close
quickshell --ipc processlist toggle
```

#### Idle Inhibit
```bash
quickshell --ipc inhibit toggle
quickshell --ipc inhibit enable
quickshell --ipc inhibit disable
quickshell --ipc inhibit status
quickshell --ipc inhibit reason "Watching video"
```

### Примеры интеграции

#### Hyprland binds
```conf
bind = SUPER, SPACE, exec, quickshell --ipc spotlight toggle
bind = SUPER, N, exec, quickshell --ipc notepad toggle
bind = SUPER, A, exec, quickshell --ipc appdrawer toggle
bind = SUPER SHIFT, P, exec, quickshell --ipc powermenu toggle
```

#### Niri binds
```kdl
binds {
    Mod+Space { spawn "quickshell" "--ipc" "spotlight" "toggle"; }
    Mod+N { spawn "quickshell" "--ipc" "notepad" "toggle"; }
    Mod+A { spawn "quickshell" "--ipc" "appdrawer" "toggle"; }
}
```

---

## 🛠️ Разработка

### Требования для разработки

- Qt Creator (рекомендуется)
- QML Language Server
- Знание QML/JavaScript
- Понимание Wayland протоколов

### Структура кода

- **QML** — UI и логика
- **JavaScript** — утилиты и обработка данных
- **GLSL** — шейдеры для визуальных эффектов

### Соглашения о коде

- Используйте `pragma ComponentBehavior: Bound`
- Именуйте компоненты в PascalCase
- Свойства в camelCase
- Константы в UPPER_SNAKE_CASE
- Комментарии на русском или английском

### Отладка

```bash
# Запуск с отладочным выводом
QT_LOGGING_RULES="quickshell.*=true" quickshell -c shell.qml

# Проверка IPC
quickshell --ipc <target> <command>

# Мониторинг производительности
QSG_RENDER_TIMING=1 quickshell -c shell.qml
```

### Тестирование плагинов

```bash
# Сканирование плагинов
PluginService.scanPlugins()

# Загрузка плагина
PluginService.loadPlugin("plugin-id")

# Выгрузка плагина
PluginService.unloadPlugin("plugin-id")
```

---

## 📝 Лицензия

Проверьте исходный код для информации о лицензии.

---

## 🤝 Вклад в проект

Вклад приветствуется! Пожалуйста:

1. Форкните репозиторий
2. Создайте ветку для фичи (`git checkout -b feature/amazing-feature`)
3. Закоммитьте изменения (`git commit -m 'Add amazing feature'`)
4. Запушьте в ветку (`git push origin feature/amazing-feature`)
5. Откройте Pull Request

---

## 📞 Поддержка

- **Issues:** [GitHub Issues](https://github.com/yourusername/sm1teePanel/issues)
- **Документация:** [Wiki](https://github.com/yourusername/sm1teePanel/wiki)
- **Quickshell:** [quickshell.outfoxxed.me](https://quickshell.outfoxxed.me/)

---

## 🙏 Благодарности

- **Quickshell** — за отличный фреймворк
- **Material Design 3** — за дизайн-систему
- **Catppuccin** — за прекрасные цветовые палитры
- **matugen** — за динамическую тематизацию
- Сообществу Wayland и разработчикам композиторов

---

<div align="center">

**Сделано с ❤️ для Wayland**

</div>
