import UIKit

class WeatherHourlyCollectionViewCell: UICollectionViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet weak var hourLabelCell: UILabel!
    
    @IBOutlet weak var temperatureLabelCell: UILabel!
    
    @IBOutlet weak var imageCell: UIImageView!
    
    // MARK: - WeatherAppManager
    
    let manager = WeatherAppManager.shared
    
    // MARK: - Identifier
    
    static let identifier = "WeatherHourlyCollectionViewCell"
    
    // MARK: - XIB configuration functions
        
    public func configure(with data: WeatherHourly, _ timezone_offset: Int) {
        let hour = manager.dateFormate(.hour, with: data.dt, for: timezone_offset)
        let image = manager.getWeatherIcon(from: data)
        
        hourLabelCell.text = hour
        temperatureLabelCell.text = manager.getCelciusTemp(from: data.temp)
        imageCell.image = image
    }
}
