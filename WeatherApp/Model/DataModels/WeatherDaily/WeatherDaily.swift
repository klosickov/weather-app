import Foundation

struct WeatherDaily: Decodable {
    let dt: Double
    let temp: Temperature
    let weather: [Weather]
    let pop: Double
}
