import Foundation
import UIKit

struct WeatherHourly: Decodable {
    let dt: Double
    let temp: Double
    let weather: [Weather]
    let pop: Double
}
