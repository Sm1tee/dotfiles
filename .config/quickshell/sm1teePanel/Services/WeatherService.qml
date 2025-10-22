pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common

Singleton {
    id: root

    property int refCount: 0

    property var weather: ({
                               "available": false,
                               "loading": true,
                               "temp": 0,
                               "tempF": 0,
                               "feelsLike": 0,
                               "feelsLikeF": 0,
                               "city": "",
                               "country": "",
                               "wCode": 0,
                               "humidity": 0,
                               "wind": "",
                               "sunrise": "06:00",
                               "sunset": "18:00",
                               "uv": 0,
                               "pressure": 0,
                               "precipitationProbability": 0,
                               "isDay": true,
                               "forecast": []
                           })

    property var location: null
    property int updateInterval: 900000 // 15 minutes
    property int retryAttempts: 0
    property int maxRetryAttempts: 3
    property int retryDelay: 30000
    property int lastFetchTime: 0
    property int minFetchInterval: 30000
    property int persistentRetryCount: 0

    readonly property var lowPriorityCmd: ["nice", "-n", "19", "ionice", "-c3"]
    readonly property var curlBaseCmd: ["curl", "-sS", "--fail", "--connect-timeout", "3", "--max-time", "6", "--limit-rate", "100k", "--compressed"]

    property var weatherIcons: ({
                                    "0": "clear_day",
                                    "1": "clear_day",
                                    "2": "partly_cloudy_day",
                                    "3": "cloud",
                                    "45": "foggy",
                                    "48": "foggy",
                                    "51": "rainy",
                                    "53": "rainy",
                                    "55": "rainy",
                                    "56": "rainy",
                                    "57": "rainy",
                                    "61": "rainy",
                                    "63": "rainy",
                                    "65": "rainy",
                                    "66": "rainy",
                                    "67": "rainy",
                                    "71": "cloudy_snowing",
                                    "73": "cloudy_snowing",
                                    "75": "snowing_heavy",
                                    "77": "cloudy_snowing",
                                    "80": "rainy",
                                    "81": "rainy",
                                    "82": "rainy",
                                    "85": "cloudy_snowing",
                                    "86": "snowing_heavy",
                                    "95": "thunderstorm",
                                    "96": "thunderstorm",
                                    "99": "thunderstorm"
                                })
    
    property var nightWeatherIcons: ({
                                        "0": "clear_night",
                                        "1": "clear_night",
                                        "2": "partly_cloudy_night",
                                        "3": "cloud",
                                        "45": "foggy",
                                        "48": "foggy",
                                        "51": "rainy",
                                        "53": "rainy",
                                        "55": "rainy",
                                        "56": "rainy",
                                        "57": "rainy",
                                        "61": "rainy",
                                        "63": "rainy",
                                        "65": "rainy",
                                        "66": "rainy",
                                        "67": "rainy",
                                        "71": "cloudy_snowing",
                                        "73": "cloudy_snowing",
                                        "75": "snowing_heavy",
                                        "77": "cloudy_snowing",
                                        "80": "rainy",
                                        "81": "rainy",
                                        "82": "rainy",
                                        "85": "cloudy_snowing",
                                        "86": "snowing_heavy",
                                        "95": "thunderstorm",
                                        "96": "thunderstorm",
                                        "99": "thunderstorm"
                                    })

    function getWeatherIcon(code, isDay) {
        if (typeof isDay === "undefined") {
            isDay = weather.isDay
        }
        const iconMap = isDay ? weatherIcons : nightWeatherIcons
        return iconMap[String(code)] || "cloud"
    }
    
    function getWeatherCondition(code) {
        const conditions = {
            "0": "Ясно",
            "1": "Ясно", 
            "2": "Переменная облачность",
            "3": "Пасмурно",
            "45": "Туман",
            "48": "Туман",
            "51": "Морось",
            "53": "Морось", 
            "55": "Морось",
            "56": "Ледяная морось",
            "57": "Ледяная морось",
            "61": "Небольшой дождь",
            "63": "Дождь",
            "65": "Сильный дождь", 
            "66": "Небольшой дождь",
            "67": "Сильный дождь",
            "71": "Небольшой снег",
            "73": "Снег",
            "75": "Сильный снег",
            "77": "Снег",
            "80": "Небольшой дождь",
            "81": "Дождь",
            "82": "Сильный дождь",
            "85": "Снегопад",
            "86": "Сильный снегопад",
            "95": "Гроза",
            "96": "Гроза с градом",
            "99": "Гроза с градом"
        }
        return conditions[String(code)] || "Неизвестно"
    }
    
    function formatTime(isoString) {
        if (!isoString) return "--"
        
        try {
            const date = new Date(isoString)
            if (isNaN(date.getTime())) return "--"
            
            const hours = date.getHours()
            const minutes = date.getMinutes()
            
            if (SettingsData.use24HourClock) {
                return String(hours).padStart(2, '0') + ":" + String(minutes).padStart(2, '0')
            } else {
                const period = hours >= 12 ? "PM" : "AM"
                const displayHours = hours % 12 || 12
                return displayHours + ":" + String(minutes).padStart(2, '0') + " " + period
            }
        } catch (e) {
            return "--"
        }
    }
    
    function formatForecastDay(isoString, index) {
        if (!isoString) return "--"
        
        try {
            const date = new Date(isoString)
            if (isNaN(date.getTime())) return "--"
            
            if (index === 0) return "Сегодня"
            if (index === 1) return "Завтра"
            
            const dayNames = ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"]
            return dayNames[date.getDay()]
        } catch (e) {
            return "--"
        }
    }

    function getWeatherApiUrl() {
        if (!location) {
            return null
        }
        
        const params = [
            "latitude=" + location.latitude,
            "longitude=" + location.longitude,
            "current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,surface_pressure,wind_speed_10m",
            "daily=sunrise,sunset,temperature_2m_max,temperature_2m_min,weather_code,precipitation_probability_max",
            "timezone=auto",
            "forecast_days=7"
        ]
        
        if (SettingsData.useFahrenheit) {
            params.push("temperature_unit=fahrenheit")
        }
        
        return "https://api.open-meteo.com/v1/forecast?" + params.join('&')
    }
    
    function getGeocodingUrl(query) {
        return "https://geocoding-api.open-meteo.com/v1/search?name=" + encodeURIComponent(query) + "&count=1&language=en&format=json"
    }

    function addRef() {
        refCount++

        if (refCount === 1) {
            if (!SettingsData.weatherEnabled) {
                return
            }
            
            initTimer.start()
            
            if (!location) {
                updateLocation()
            } else {
                fetchWeather()
            }
        }
    }

    function removeRef() {
        refCount = Math.max(0, refCount - 1)
    }

    function updateLocation(force) {
        force = force || false
        
        if (SettingsData.useAutoLocation) {
            getLocationFromIP()
        } else {
            const coords = SettingsData.weatherCoordinates
            const savedLocation = SettingsData.weatherLocation
            
            if (coords && savedLocation) {
                const parts = coords.split(",")
                if (parts.length === 2) {
                    const lat = parseFloat(parts[0])
                    const lon = parseFloat(parts[1])
                    if (!isNaN(lat) && !isNaN(lon)) {
                        root.location = {
                            city: savedLocation,
                            country: "",
                            latitude: lat,
                            longitude: lon
                        }
                        fetchWeather(force)
                        return
                    }
                }
            }
            
            const cityName = SettingsData.weatherLocation
            if (cityName) {
                getLocationFromCity(cityName)
            } else {
                root.location = {
                    city: "Москва",
                    country: "RU",
                    latitude: 55.7558,
                    longitude: 37.6173
                }
                fetchWeather(force)
            }
        }
    }
    
    function getLocationFromCoords(lat, lon) {
        const url = "https://nominatim.openstreetmap.org/reverse?lat=" + lat + "&lon=" + lon + "&format=json&addressdetails=1&accept-language=en"
        reverseGeocodeFetcher.command = lowPriorityCmd.concat(curlBaseCmd).concat(["-H", "User-Agent: sm1teePanel Weather Widget", url])
        reverseGeocodeFetcher.running = true
    }
    
    function getLocationFromCity(city) {
        cityGeocodeFetcher.command = lowPriorityCmd.concat(curlBaseCmd).concat([getGeocodingUrl(city)])
        cityGeocodeFetcher.running = true
    }
    
    function getLocationFromIP() {
        ipLocationFetcher.running = true
    }

    function fetchWeather(force) {
        force = force || false
        
        if (!force && (root.refCount === 0 || !SettingsData.weatherEnabled)) {
            return
        }
        
        if (!SettingsData.weatherEnabled && !force) {
            return
        }

        if (!location) {
            updateLocation()
            return
        }

        if (weatherFetcher.running) {
            return
        }

        const now = Date.now()
        if (!force && now - root.lastFetchTime < root.minFetchInterval) {
            return
        }

        const apiUrl = getWeatherApiUrl()
        if (!apiUrl) {
            console.warn("WeatherService: Failed to generate API URL")
            return
        }

        root.lastFetchTime = now
        root.weather.loading = true
        const weatherCmd = lowPriorityCmd.concat(["curl", "-sS", "--fail", "--connect-timeout", "3", "--max-time", "6", "--limit-rate", "150k", "--compressed"])
        weatherFetcher.command = weatherCmd.concat([apiUrl])
        weatherFetcher.running = true
    }

    function forceRefresh() {
        root.lastFetchTime = 0
        root.retryAttempts = 0
        root.persistentRetryCount = 0
        
        // Убрано принудительное включение weatherEnabled
        
        if (!location) {
            updateLocation(true)
        } else {
            fetchWeather(true)
        }
    }
    
    function nextInterval() {
        const jitter = Math.floor(Math.random() * 15000) - 7500
        return Math.max(60000, root.updateInterval + jitter)
    }

    function handleWeatherSuccess() {
        root.retryAttempts = 0
        root.persistentRetryCount = 0
        if (persistentRetryTimer.running) {
            persistentRetryTimer.stop()
        }
        if (updateTimer.interval !== root.updateInterval) {
            updateTimer.interval = root.updateInterval
        }
    }

    function handleWeatherFailure() {
        root.retryAttempts++
        if (root.retryAttempts < root.maxRetryAttempts) {
            retryTimer.start()
        } else {
            root.retryAttempts = 0
            if (!root.weather.available) {
                root.weather.loading = false
            }
            const backoffDelay = Math.min(60000 * Math.pow(2, persistentRetryCount), 300000)
            persistentRetryCount++
            persistentRetryTimer.interval = backoffDelay
            persistentRetryTimer.start()
        }
    }

    Process {
        id: ipLocationFetcher
        command: lowPriorityCmd.concat(curlBaseCmd).concat(["http://ipinfo.io/json"])
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                const raw = text.trim()
                if (!raw || raw.length === 0) {
                    root.handleWeatherFailure()
                    return
                }

                try {
                    const data = JSON.parse(raw)
                    const coords = data.loc
                    const city = data.city
                    
                    if (!coords || !city) {
                        throw new Error("Missing location data")
                    }
                    
                    const coordsParts = coords.split(",")
                    if (coordsParts.length !== 2) {
                        throw new Error("Invalid coordinates format")
                    }
                    
                    const lat = parseFloat(coordsParts[0])
                    const lon = parseFloat(coordsParts[1])
                    
                    if (isNaN(lat) || isNaN(lon)) {
                        throw new Error("Invalid coordinate values")
                    }
                    
                    root.location = {
                        city: city,
                        country: data.country || "",
                        latitude: lat,
                        longitude: lon
                    }
                    fetchWeather()
                } catch (e) {
                    console.warn("WeatherService: IP location error:", e.message)
                    root.handleWeatherFailure()
                }
            }
        }
        
        onExited: exitCode => {
            if (exitCode !== 0) {
                root.handleWeatherFailure()
            }
        }
    }
    
    Process {
        id: reverseGeocodeFetcher
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                const raw = text.trim()
                if (!raw || raw[0] !== "{") {
                    root.handleWeatherFailure()
                    return
                }

                try {
                    const data = JSON.parse(raw)
                    const address = data.address || {}
                    
                    root.location = {
                        city: address.hamlet || address.city || address.town || address.village || "Unknown",
                        country: address.country || "Unknown",
                        latitude: parseFloat(data.lat),
                        longitude: parseFloat(data.lon)
                    }
                    
                    fetchWeather()
                } catch (e) {
                    root.handleWeatherFailure()
                }
            }
        }
        
        onExited: exitCode => {
            if (exitCode !== 0) {
                root.handleWeatherFailure()
            }
        }
    }
    
    Process {
        id: cityGeocodeFetcher
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                const raw = text.trim()
                if (!raw || raw.length === 0) {
                    root.handleWeatherFailure()
                    return
                }

                try {
                    const data = JSON.parse(raw)
                    const results = data.results
                    
                    if (!results || results.length === 0) {
                        throw new Error("No results found")
                    }
                    
                    const result = results[0]
                    
                    root.location = {
                        city: result.name,
                        country: result.country || "",
                        latitude: result.latitude,
                        longitude: result.longitude
                    }
                    
                    fetchWeather()
                } catch (e) {
                    console.warn("WeatherService: City geocoding error:", e.message)
                    root.handleWeatherFailure()
                }
            }
        }
        
        onExited: exitCode => {
            if (exitCode !== 0) {
                root.handleWeatherFailure()
            }
        }
    }

    Process {
        id: weatherFetcher
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const raw = text.trim()
                if (!raw || raw.length === 0) {
                    root.handleWeatherFailure()
                    return
                }

                try {
                    const data = JSON.parse(raw)
                    
                    if (!data.current || !data.daily) {
                        throw new Error("Required weather data fields missing")
                    }

                    const current = data.current
                    const daily = data.daily
                    const currentUnits = data.current_units || {}
                    
                    const tempC = current.temperature_2m || 0
                    const tempF = SettingsData.useFahrenheit ? tempC : (tempC * 9/5 + 32)
                    const feelsLikeC = current.apparent_temperature || tempC
                    const feelsLikeF = SettingsData.useFahrenheit ? feelsLikeC : (feelsLikeC * 9/5 + 32)
                    
                    const forecast = []
                    if (daily.time && daily.time.length > 0) {
                        for (let i = 0; i < Math.min(daily.time.length, 7); i++) {
                            const tempMinC = daily.temperature_2m_min?.[i] || 0
                            const tempMaxC = daily.temperature_2m_max?.[i] || 0
                            const tempMinF = SettingsData.useFahrenheit ? tempMinC : (tempMinC * 9/5 + 32)
                            const tempMaxF = SettingsData.useFahrenheit ? tempMaxC : (tempMaxC * 9/5 + 32)
                            
                            forecast.push({
                                "day": formatForecastDay(daily.time[i], i),
                                "wCode": daily.weather_code?.[i] || 0,
                                "tempMin": Math.round(tempMinC),
                                "tempMax": Math.round(tempMaxC),
                                "tempMinF": Math.round(tempMinF),
                                "tempMaxF": Math.round(tempMaxF),
                                "precipitationProbability": Math.round(daily.precipitation_probability_max?.[i] || 0),
                                "sunrise": daily.sunrise?.[i] ? formatTime(daily.sunrise[i]) : "",
                                "sunset": daily.sunset?.[i] ? formatTime(daily.sunset[i]) : ""
                            })
                        }
                    }
                    
                    const windUnit = currentUnits.wind_speed_10m || 'm/s'
                    const windUnitTranslated = windUnit === 'km/h' ? 'км/ч' : windUnit === 'm/s' ? 'м/с' : windUnit
                    
                    root.weather = {
                        "available": true,
                        "loading": false,
                        "temp": Math.round(tempC),
                        "tempF": Math.round(tempF),
                        "feelsLike": Math.round(feelsLikeC),
                        "feelsLikeF": Math.round(feelsLikeF),
                        "city": root.location?.city || "Unknown",
                        "country": root.location?.country || "Unknown",
                        "wCode": current.weather_code || 0,
                        "humidity": Math.round(current.relative_humidity_2m || 0),
                        "wind": Math.round(current.wind_speed_10m || 0) + " " + windUnitTranslated,
                        "sunrise": formatTime(daily.sunrise?.[0]) || "06:00",
                        "sunset": formatTime(daily.sunset?.[0]) || "18:00",
                        "uv": 0,
                        "pressure": Math.round(current.surface_pressure || 0),
                        "precipitationProbability": Math.round(current.precipitation || 0),
                        "isDay": Boolean(current.is_day),
                        "forecast": forecast
                    }

                    const displayTemp = SettingsData.useFahrenheit ? root.weather.tempF : root.weather.temp
                    const unit = SettingsData.useFahrenheit ? "°F" : "°C"

                    root.handleWeatherSuccess()
                } catch (e) {
                    root.handleWeatherFailure()
                }
            }
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.handleWeatherFailure()
            }
        }
    }

    Timer {
        id: updateTimer
        interval: nextInterval()
        running: root.refCount > 0 && SettingsData.weatherEnabled
        repeat: true
        triggeredOnStart: false
        onTriggered: {
            root.fetchWeather()
            interval = nextInterval()
        }
        
        onRunningChanged: {
            if (running) {
                Qt.callLater(root.fetchWeather)
            }
        }
    }

    Timer {
        id: retryTimer
        interval: root.retryDelay
        running: false
        repeat: false
        onTriggered: {
            root.fetchWeather()
        }
    }

    Timer {
        id: persistentRetryTimer
        interval: 60000
        running: false
        repeat: false
        onTriggered: {
            if (!root.weather.available) {
                root.weather.loading = true
            }
            root.fetchWeather()
        }
    }

    Timer {
        id: initTimer
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            if (root.refCount > 0 && !root.weather.available && SettingsData.weatherEnabled) {
                root.forceRefresh()
            }
        }
    }

    Component.onCompleted: {
        SettingsData.weatherCoordinatesChanged.connect(() => {
                                                           root.location = null
                                                           root.weather = {
                                                               "available": false,
                                                               "loading": true,
                                                               "temp": 0,
                                                               "tempF": 0,
                                                               "feelsLike": 0,
                                                               "feelsLikeF": 0,
                                                               "city": "",
                                                               "country": "",
                                                               "wCode": 0,
                                                               "humidity": 0,
                                                               "wind": "",
                                                               "sunrise": "06:00",
                                                               "sunset": "18:00",
                                                               "uv": 0,
                                                               "pressure": 0,
                                                               "precipitationProbability": 0,
                                                               "isDay": true,
                                                               "forecast": []
                                                           }
                                                           root.lastFetchTime = 0
                                                           root.forceRefresh()
                                                       })

        SettingsData.weatherLocationChanged.connect(() => {
                                                        root.location = null
                                                        root.lastFetchTime = 0
                                                        root.forceRefresh()
                                                    })

        SettingsData.useAutoLocationChanged.connect(() => {
                                                        root.location = null
                                                        root.weather = {
                                                            "available": false,
                                                            "loading": true,
                                                            "temp": 0,
                                                            "tempF": 0,
                                                            "feelsLike": 0,
                                                            "feelsLikeF": 0,
                                                            "city": "",
                                                            "country": "",
                                                            "wCode": 0,
                                                            "humidity": 0,
                                                            "wind": "",
                                                            "sunrise": "06:00",
                                                            "sunset": "18:00",
                                                            "uv": 0,
                                                            "pressure": 0,
                                                            "precipitationProbability": 0,
                                                            "isDay": true,
                                                            "forecast": []
                                                        }
                                                        root.lastFetchTime = 0
                                                        root.forceRefresh()
                                                    })
                                                    
        SettingsData.useFahrenheitChanged.connect(() => {
                                                       root.lastFetchTime = 0
                                                       root.forceRefresh()
                                                   })

        SettingsData.weatherEnabledChanged.connect(() => {
                                                       if (SettingsData.weatherEnabled && root.refCount > 0 && !root.weather.available) {
                                                           root.forceRefresh()
                                                       } else if (!SettingsData.weatherEnabled) {
                                                           updateTimer.stop()
                                                           retryTimer.stop()
                                                           persistentRetryTimer.stop()
                                                           if (weatherFetcher.running) {
                                                               weatherFetcher.running = false
                                                           }
                                                       }
                                                   })
    }
}
