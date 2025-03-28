import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Effects
import QtMultimedia

import "Components"

Pane { // Главный контейнер, основанный на элементе управления Pane
    id: root // Уникальный идентификатор главного контейнера

    height: config.ScreenHeight || Screen.height // Высота: из конфигурации, или высота экрана
    width: config.ScreenWidth || Screen.width // Ширина: из конфигурации, или ширина экрана
    padding: config.ScreenPadding // Отступы: из конфигурации

    LayoutMirroring.enabled: config.RightToLeftLayout == "true" ? true : Qt.application.layoutDirection === Qt.RightToLeft // Зеркальное отображение макета, если включено в конфигурации или направление текста справа налево
    LayoutMirroring.childrenInherit: true // Дочерние элементы наследуют зеркальное отображение

    palette.window: config.BackgroundColor // Цвет фона окна: из конфигурации
    palette.highlight: config.HighlightBackgroundColor // Цвет фона выделения: из конфигурации
    palette.highlightedText: config.HighlightTextColor // Цвет текста выделения: из конфигурации
    palette.buttonText: config.HoverSystemButtonsIconsColor // Цвет текста кнопок: из конфигурации

    font.family: config.Font // Шрифт: из конфигурации
    font.pointSize: config.FontSize !== "" ? config.FontSize : parseInt(height / 80) || 13 // Размер шрифта: из конфигурации, или вычисленный, или 13

    focus: true // Устанавливаем фокус на этот элемент по умолчанию

    // Свойства для определения расположения фона и формы
    property bool leftleft: config.HaveFormBackground == "true" &&
                            config.PartialBlur == "false" &&
                            config.FormPosition == "left" &&
                            config.BackgroundHorizontalAlignment == "left" // Фон слева, форма слева

    property bool leftcenter: config.HaveFormBackground == "true" &&
                              config.PartialBlur == "false" &&
                              config.FormPosition == "left" &&
                              config.BackgroundHorizontalAlignment == "center" // Фон по центру, форма слева

    property bool rightright: config.HaveFormBackground == "true" &&
                              config.PartialBlur == "false" &&
                              config.FormPosition == "right" &&
                              config.BackgroundHorizontalAlignment == "right" // Фон справа, форма справа

    property bool rightcenter: config.HaveFormBackground == "true" &&
                               config.PartialBlur == "false" &&
                               config.FormPosition == "right" &&
                               config.BackgroundHorizontalAlignment == "center" // Фон по центру, форма справа

    Item { // Контейнер для всех элементов внутри Pane
        id: sizeHelper // Вспомогательный элемент для определения размеров

        height: parent.height // Высота равна высоте родителя
        width: parent.width // Ширина равна ширине родителя
        anchors.fill: parent // Заполняет родительский элемент

        Rectangle { // Слой затемнения
            id: tintLayer // Идентификатор слоя затемнения

            height: parent.height // Высота равна высоте родителя
            width: parent.width // Ширина равна ширине родителя
            anchors.fill: parent // Заполняет родительский элемент
            z: 1 // Порядок отрисовки (поверх других элементов)
            color: config.DimBackgroundColor // Цвет затемнения: из конфигурации
            opacity: config.DimBackground // Прозрачность затемнения: из конфигурации
        }

        Rectangle { // Фон формы
            id: formBackground // Идентификатор фона формы

            anchors.fill: form // Заполняет форму
            anchors.centerIn: form // Центрируется относительно формы
            z: 1 // Порядок отрисовки

            color: config.FormBackgroundColor // Цвет фона формы: из конфигурации
            visible: config.HaveFormBackground == "true" ? true : false // Видимость: если включен фон формы в конфигурации
            opacity: config.PartialBlur == "true" ? 0.3 : 1 // Прозрачность: 0.3 если включено частичное размытие, иначе 1
        }

        LoginForm { // Компонент формы входа
            id: form // Идентификатор формы входа

            height: parent.height // Высота равна высоте родителя
            width: parent.width / 2.5 // Ширина равна 1/2.5 ширины родителя
            anchors.left: config.FormPosition == "left" ? parent.left : undefined // Привязка к левому краю, если форма слева
            anchors.horizontalCenter: config.FormPosition == "center" ? parent.horizontalCenter : undefined // Центрирование по горизонтали, если форма по центру
            anchors.right: config.FormPosition == "right" ? parent.right : undefined // Привязка к правому краю, если форма справа
            z: 1 // Порядок отрисовки
        }

        Loader { // Загрузчик для виртуальной клавиатуры
            id: virtualKeyboard // Идентификатор виртуальной клавиатуры
            source: "Components/VirtualKeyboard.qml" // Путь к файлу компонента виртуальной клавиатуры

            // x * 0.4 = x / 2.5
            width: config.KeyboardSize == "" ? parent.width * 0.4 : parent.width * config.KeyboardSize // Ширина: из конфигурации или 40% от ширины родителя
            anchors.bottom: parent.bottom // Привязка к нижнему краю родителя
            anchors.left: config.VirtualKeyboardPosition == "left" ? parent.left : undefined // Привязка к левому краю, если клавиатура слева
            anchors.horizontalCenter: config.VirtualKeyboardPosition == "center" ? parent.horizontalCenter : undefined // Центрирование, если клавиатура по центру
            anchors.right: config.VirtualKeyboardPosition == "right" ? parent.right : undefined // Привязка к правому краю, если клавиатура справа
            z: 1 // Порядок отрисовки

            state: "hidden" // Начальное состояние - скрыто
            property bool keyboardActive: item ? item.active : false // Свойство, показывающее, активна ли клавиатура

            function switchState() { state = state == "hidden" ? "visible" : "hidden"} // Функция переключения состояния клавиатуры
            states: [ // Определение состояний клавиатуры
                State { // Состояние "видимо"
                    name: "visible" // Имя состояния
                    PropertyChanges { // Изменения свойств в этом состоянии
                        target: virtualKeyboard // Целевой объект - виртуальная клавиатура
                        y: root.height - virtualKeyboard.height // Позиция по Y
                        opacity: 1 // Непрозрачность
                    }
                },
                State { // Состояние "скрыто"
                    name: "hidden" // Имя состояния
                    PropertyChanges { // Изменения свойств
                        target: virtualKeyboard // Целевой объект
                        y: root.height - root.height/4  // Позиция Y: при скрытии клавиатура немного видна
                        opacity: 0 // Прозрачность
                    }
                }
            ]
            transitions: [ // Определение переходов между состояниями
                Transition { // Переход из "скрыто" в "видимо"
                    from: "hidden" // Из какого состояния
                    to: "visible" // В какое состояние
                    SequentialAnimation { // Последовательная анимация
                        ScriptAction { // Выполнение скрипта
                            script: { // Скрипт
                                virtualKeyboard.item.activated = true; // Активация клавиатуры
                                Qt.inputMethod.show(); // Показ системного метода ввода
                            }
                        }
                        ParallelAnimation { // Параллельная анимация
                            NumberAnimation { // Анимация числа (позиции Y)
                                target: virtualKeyboard // Цель
                                property: "y" // Свойство
                                duration: 100 // Длительность
                                easing.type: Easing.OutQuad // Тип сглаживания
                            }
                            OpacityAnimator { // Анимация прозрачности
                                target: virtualKeyboard // Цель
                                duration: 100 // Длительность
                                easing.type: Easing.OutQuad // Тип сглаживания
                            }
                        }
                    }
                },
                Transition { // Переход из "видимо" в "скрыто"
                    from: "visible" // Из какого состояния
                    to: "hidden" // В какое состояние
                    SequentialAnimation { // Последовательная анимация
                        ParallelAnimation { // Параллельная анимация
                            NumberAnimation { // Анимация числа (позиции Y)
                                target: virtualKeyboard // Цель
                                property: "y" // Свойство
                                duration: 100 // Длительность
                                easing.type: Easing.InQuad // Тип сглаживания
                            }
                            OpacityAnimator { // Анимация прозрачности
                                target: virtualKeyboard // Цель
                                duration: 100 // Длительность
                                easing.type: Easing.InQuad // Тип сглаживания
                            }
                        }
                        ScriptAction { // Выполнение скрипта
                            script: { // Скрипт
                                virtualKeyboard.item.activated = false; // Деактивация клавиатуры
                                Qt.inputMethod.hide(); // Скрытие системного метода ввода
                            }
                        }
                    }
                }
            ]
        }

        Image { // Изображение-заполнитель фона
            id: backgroundPlaceholderImage // Идентификатор

            z: 10 // Порядок отрисовки (поверх всего)
            source: config.BackgroundPlaceholder // Источник: из конфигурации
            visible: false // Изначально невидимо
        }

        AnimatedImage { // Анимированное изображение (фон)
            id: backgroundImage // Идентификатор

            MediaPlayer { // Медиаплеер для воспроизведения видео
                id: player // Идентификатор

                videoOutput: videoOutput // Вывод видео
                autoPlay: true // Автоматическое воспроизведение
                playbackRate: config.BackgroundSpeed == "" ? 1.0 : config.BackgroundSpeed // Скорость воспроизведения: из конфигурации или 1.0
                loops: -1 // Бесконечное повторение
                onPlayingChanged: { // При начале воспроизведения
                    console.log("Video started.") // Вывод в консоль
                    backgroundPlaceholderImage.visible = false; // Скрыть изображение-заполнитель
                }
            }

            VideoOutput { // Вывод видео
                id: videoOutput // Идентификатор

                fillMode: config.CropBackground == "true" ? VideoOutput.PreserveAspectCrop : VideoOutput.PreserveAspectFit // Режим заполнения: обрезать или вписать с сохранением пропорций
                anchors.fill: parent // Заполняет родительский элемент
            }

            height: parent.height // Высота равна высоте родителя
            width: config.HaveFormBackground == "true" && config.FormPosition != "center" && config.PartialBlur != "true" ? parent.width - formBackground.width : parent.width // Ширина: если есть фон формы и форма не по центру, и нет частичного размытия, то ширина родителя минус ширина фона формы, иначе ширина родителя.
            anchors.left: leftleft || leftcenter ? formBackground.right : undefined // Привязка к левому краю: если фон и форма слева или фон по центру и форма слева, то привязка к правому краю фона формы
            anchors.right: rightright || rightcenter ? formBackground.left : undefined // Привязка к правому краю: аналогично левому краю

            horizontalAlignment: config.BackgroundHorizontalAlignment == "left" ?
                                 Image.AlignLeft :
                                 config.BackgroundHorizontalAlignment == "right" ?
                                 Image.AlignRight : Image.AlignHCenter // Горизонтальное выравнивание: из конфигурации или по центру

            verticalAlignment: config.BackgroundVerticalAlignment == "top" ?
                               Image.AlignTop :
                               config.BackgroundVerticalAlignment == "bottom" ?
                               Image.AlignBottom : Image.AlignVCenter // Вертикальное выравнивание: из конфигурации или по центру

            speed: config.BackgroundSpeed == "" ? 1.0 : config.BackgroundSpeed // Скорость анимации: из конфигурации или 1.0
            paused: config.PauseBackground == "true" ? 1 : 0 // Пауза: из конфигурации
            fillMode: config.CropBackground == "true" ? Image.PreserveAspectCrop : Image.PreserveAspectFit // Режим заполнения: обрезать или вписать
            asynchronous: true // Асинхронная загрузка
            cache: true // Кэширование
            clip: true // Обрезка
            mipmap: true // Использовать мипмапы

            Component.onCompleted:{ // При завершении загрузки компонента
                var fileType = config.Background.substring(config.Background.lastIndexOf(".") + 1) // Получаем расширение файла фона
                const videoFileTypes = ["avi", "mp4", "mov", "mkv", "m4v", "webm"]; // Список поддерживаемых видеоформатов
                if (videoFileTypes.includes(fileType)) { // Если это видеофайл
                    backgroundPlaceholderImage.visible = true; // Показываем изображение-заполнитель
                    player.source = Qt.resolvedUrl(config.Background) // Устанавливаем источник видео
                    player.play(); // Запускаем воспроизведение
                }
                else{ // Если это не видеофайл (например, изображение)
                    backgroundImage.source = config.background || config.Background // Устанавливаем источник изображения
                }
            }
        }

        MouseArea { // Область для обработки кликов мышью
            anchors.fill: backgroundImage // Заполняет фоновое изображение
            onClicked: parent.forceActiveFocus() // При клике устанавливает фокус на родительский элемент
        }

        ShaderEffectSource { // Источник для шейдерного эффекта (маска размытия)
            id: blurMask // Идентификатор

            height: parent.height // Высота равна высоте родителя
            width: form.width // Ширина равна ширине формы
            anchors.centerIn: form // Центрируется относительно формы

            sourceItem: backgroundImage // Исходный элемент - фоновое изображение
            sourceRect: Qt.rect(x,y,width,height) // Прямоугольная область источника
            visible: config.FullBlur == "true" || config.PartialBlur == "true" ? true : false // Видимость: если включено полное или частичное размытие
        }

        MultiEffect { // Эффект размытия
            id: blur // Идентификатор

            height: parent.height // Высота равна высоте родителя

            // width: config.FullBlur == "true" ? parent.width : form.width // Ширина: если полное размытие - ширина родителя, иначе - ширина формы
            // anchors.centerIn: config.FullBlur == "true" ? parent : form // Центрирование: если полное размытие - относительно родителя, иначе - относительно формы

            // This solves problem when FullBlur and HaveFormBackground is set to true but PartialBlur is false and FormPosition isn't center.
            width: (config.FullBlur == "true" && config.PartialBlur == "false" && config.FormPosition != "center" ) ? parent.width - formBackground.width : config.FullBlur == "true" ? parent.width : form.width  // Исправленная ширина для корректной работы размытия в разных конфигурациях.
            anchors.centerIn: config.FullBlur == "true" ? backgroundImage : form // Центрирование: если полное размытие - относительно фонового изображения, иначе - относительно формы

            source: config.FullBlur == "true" ? backgroundImage : blurMask // Источник: если полное размытие - фоновое изображение, иначе - маска размытия
            blurEnabled: true // Включить размытие
            autoPaddingEnabled: false // Отключить автоматические отступы
            blur: config.Blur == "" ? 2.0 : config.Blur // Степень размытия: из конфигурации или 2.0
            blurMax: config.BlurMax == "" ? 48 : config.BlurMax // Максимальная степень размытия: из конфигурации или 48
            visible: config.FullBlur == "true" || config.PartialBlur == "true" ? true : false // Видимость: если включено полное или частичное размытие
        }
    }
}