import Foundation

struct WeatherCurrent: Decodable {
    let dt: Double
    let temp: Double
    let humidity: Int
    let wind_speed: Double
    let weather: [Weather]
}
