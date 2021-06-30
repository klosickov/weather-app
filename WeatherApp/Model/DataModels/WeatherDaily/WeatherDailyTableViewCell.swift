import UIKit

class WeatherDailyTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var popLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    
    // MARK: - WeatherAppManager
    
    let manager = WeatherAppManager.shared
    
    // MARK: - Cell configuration function
    
    func configure(with data: WeatherDaily, _ timezone_offset: Int) {
        let pop = data.pop != 0 ? round(data.pop * 10) * 10 : 0
        if manager.isTheRainExpected(data.weather), pop != 0
        {
            popLabel.text = String(format: "%.0f", pop) + " %"
        } else {
            popLabel.text = ""
        }
        dayLabel.text = manager.dateFormate(.dayName, from: data.dt, for: timezone_offset)
        imageIcon.image = manager.getWeatherIcon(from: data)
        maxTempLabel.text = manager.getCelciusTemp(from: data.temp.max)
        minTempLabel.text = manager.getCelciusTemp(from: data.temp.min)
    }    
}
