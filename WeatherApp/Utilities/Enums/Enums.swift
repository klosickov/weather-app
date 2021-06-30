import Foundation

enum DateFormat: String {
    case day = "dd"
    case hour = "HH"
    case dayName = "EEEE"
}

enum ViewType {
    case currentView
    case dailyView
}

enum WeatherStatus: String {
    case thunderstorm = "Thunderstorm"
    case drizzle = "Drizzle"
    case rain = "Rain"
    case snow = "Snow"
    case clear = "Clear"
    case clouds = "Clouds"
    case mist = "Mist"
}

enum ConnectionStatus {
    case wifi
    case cellular
    case unavailable
}

enum ConnectionType: String {
    case wifi = "wifi"
    case cellular = "signal-tower"
    case unavailable = "exclamation"
}
