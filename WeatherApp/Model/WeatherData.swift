import Foundation
import UIKit

// MARK: - Main structure

struct WeatherData: Decodable {
    let timezone_offset: Int
    let current: WeatherCurrent
    var hourly: [WeatherHourly]
    var daily: [WeatherDaily]
}

// MARK: - Including structs

struct Temperature: Decodable {
    let day: Double
    let min: Double
    let max: Double
    let night: Double
}

struct Weather: Decodable {
    let main: String
    let description: String
    let icon: String
}
