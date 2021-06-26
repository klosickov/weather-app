import UIKit

class WeatherDailyTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    
    // MARK: - App Manager
    
    let manager = WeatherAppManager.shared
    
    // MARK: - Configure function
    
    func configure(with data: WeatherDaily, _ timezone_offset: Int) {
        dayLabel.text = manager.dateFormate(.dayName, with: data.dt, for: timezone_offset)
        imageIcon.image = manager.getWeatherIcon(from: data)
        maxTempLabel.text = manager.getCelciusTemp(from: data.temp.max)
        minTempLabel.text = manager.getCelciusTemp(from: data.temp.min)
    }    
}
