import UIKit
import Foundation

class InternetConnectionStatusView: UIView {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: - XIB configuration function
    
    class func instanceFromNib() -> InternetConnectionStatusView {
        if let statusView = UINib(nibName: "InternetConnectionStatusView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? InternetConnectionStatusView {
            return statusView
        } else {
            return InternetConnectionStatusView()
        }
    }
}
