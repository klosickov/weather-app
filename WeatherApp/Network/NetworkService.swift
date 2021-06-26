import Foundation

class NetworkService {
    
    static let shared = NetworkService()
    private init() {}
    
    // MARK: - lets / vars
    
    private let apiKey = "bcaab0786c807752b0ca08b44de188ec"
    private let url_base = "https://api.openweathermap.org/data/2.5"
    
    private var url_latitude = ""
    private var url_longtitude = ""
    private var url_get_one_call = ""
    
    // MARK: - API functions
    
    private func buildURLString() -> String {
        url_get_one_call = "/onecall?lat=" + url_latitude + "&lon=" + url_longtitude + "&appid=" + apiKey
        return url_base + url_get_one_call
    }
    
    // GET request
    public func getWeatherForecast(with coordinates: (latitude: Double, longtitude: Double), completionWeatherData: @escaping (WeatherData) -> Void) {
        
        url_latitude = "\(coordinates.latitude)"
        url_longtitude = "\(coordinates.longtitude)"
        
        guard let url = URL(string: buildURLString()) else {
            print("Error building URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Error: HTTP Response Code Error")
                return
            }
            
            guard let data = data else {
                print("Error: No Response")
                return
            }
            
            if let weatherData = WeatherAppManager.shared.decodeJSONForecast(data) {
                completionWeatherData(weatherData)
            }
        }.resume()
    }
}
