import Foundation
import UIKit

class WeatherAppManager {
    
    static let shared = WeatherAppManager()
    private init() {}
    
    // MARK: - JSON parse
    
    public func decodeJSONForecast(_ JSONData: Data) -> WeatherData? {
        do {
            let response = try JSONDecoder().decode(WeatherData.self, from: JSONData)
            
            return response
            
        } catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
    
    public func decodeJSONCityList() -> [City]? {
        guard let path = Bundle.main.path(forResource: "cities", ofType: "json") else { return nil }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let response = try JSONDecoder().decode([City].self, from: data)
            return response
        } catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
    
    // MARK: - DateFormatter
    
    public func dateFormate(_ format: DateFormat, with timeResult: Double, for timezone_offset: Int) -> String {
        let date = Date(timeIntervalSince1970: timeResult)
        let dateFormatter = DateFormatter()
        
        switch format {
        case .day:
            dateFormatter.dateFormat = format.rawValue
        case .hour:
            dateFormatter.dateFormat = format.rawValue
        case .dayName:
            dateFormatter.dateFormat = format.rawValue
        }
        
        dateFormatter.timeZone = TimeZone(secondsFromGMT: timezone_offset)
        let localDate = dateFormatter.string(from: date)
        
        return localDate
    }
    
    // MARK: - Celsius to Kelvin conversion
    
    public func getCelciusTemp(from temp: Double) -> String {
        let celciusTemp = String(format: "%.0f", temp-273.15) + "°"
        return celciusTemp
    }
    
    // MARK: - Get weather icon
    
    private func getIconImageName(_ icon: String) -> String {
        switch icon {
        case _ where icon.contains("03"):
            return "03"
        case _ where icon.contains("04"):
            return "04"
        case _ where icon.contains("09"):
            return "09"
        case _ where icon.contains("13"):
            return "13"
        default:
            return icon
        }
    }
    
    public func getWeatherIcon(from data: WeatherCurrent) -> UIImage? {
        guard let currentWeatherData = data.weather.first else { return nil }
        let iconImageName = getIconImageName(currentWeatherData.icon)
        return UIImage(named: iconImageName)
    }
    
    public func getWeatherIcon(from data: WeatherHourly) -> UIImage? {
        guard let hourlyWeatherData = data.weather.first else { return nil }
        let iconImageName = getIconImageName(hourlyWeatherData.icon)
        return UIImage(named: iconImageName)
    }
    
    public func getWeatherIcon(from data: WeatherDaily) -> UIImage? {
        guard let dailyWeatherData = data.weather.first else { return nil }
        let iconImageName = getIconImageName(dailyWeatherData.icon)
        return UIImage(named: iconImageName)
    }
}
