import UIKit

class CityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    func configure(with model: City) {
        cityLabel.text = model.city
        countryLabel.text = model.country
    }
}
