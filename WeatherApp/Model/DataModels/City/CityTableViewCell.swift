import UIKit

class CityTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    // MARK: - Cell configuration function
    
    func configure(with model: City) {
        cityLabel.text = model.city
        countryLabel.text = model.country
    }
}
