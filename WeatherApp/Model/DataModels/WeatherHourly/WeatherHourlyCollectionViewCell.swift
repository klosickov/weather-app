import UIKit

class WeatherHourlyCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var popLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var imageCell: UIImageView!
    
    // MARK: - WeatherAppManager
    
    let manager = WeatherAppManager.shared
    
    // MARK: - Cell configuration function
    
    public func configure(with data: WeatherHourly, _ timezone_offset: Int) {
        let hour = manager.dateFormate(.hour, from: data.dt, for: timezone_offset)
        let image = manager.getWeatherIcon(from: data)
        let pop = data.pop != 0 ? round(data.pop * 10) * 10 : 0
        
        if manager.isTheRainExpected(data.weather), pop != 0
        {
            popLabel.text = String(format: "%.0f", pop) + " %"
        } else {
            popLabel.text = ""
        }
        hourLabel.text = hour
        temperatureLabel.text = manager.getCelciusTemp(from: data.temp)
        imageCell.image = image
        
    }
}
