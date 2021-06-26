import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var currentWeatherLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var minMaxTemperatureLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var humidityImage: UIImageView!
    @IBOutlet weak var windImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - lets / vars
    
    private let locationManager = CLLocationManager()
    private let manager = WeatherAppManager.shared
    
    private var tableDataSource = [WeatherDaily]()
    private var collectionViewDataSource = [WeatherHourly]()
    private var currentWeatherData: WeatherData?
    
    public var cityData: [City]?
    
    // MARK: - Lifecycle functions
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showSpinner(onView: view, alpha: 1)
        
        collectionView.register(UINib(nibName: "WeatherHourlyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WeatherHourly")
        tableView.register(UINib(nibName: "WeatherDailyTableViewCell", bundle: nil), forCellReuseIdentifier: "WeatherDaily")
        
        // MARK: - Location
        
        locationManager.delegate = self
        locationManager.requestLocation()
        
        // MARK: - JSON Parse
        cityData = WeatherAppManager.shared.decodeJSONCityList()
    }
    
    // MARK: - Configure UI functions
    
    private func configureWeatherCurrent(from data: WeatherData) {
        guard let tempDesc = data.daily.first else { return }
        guard let weather = data.current.weather.first else { return }
        let temperature = manager.getCelciusTemp(from: data.current.temp)
        let tempDescMin = manager.getCelciusTemp(from: tempDesc.temp.min)
        let tempDescMax = manager.getCelciusTemp(from: tempDesc.temp.max)
        let tempMinMaxDesc = "Max. \(tempDescMax), min. \(tempDescMin)"
        let windSpeed = "\(data.current.wind_speed) m/s"
        let humidityInfo = "\(data.current.humidity) %"
        
        currentWeatherLabel.text = weather.description.capitalizingFirstLetter()
        temperatureLabel.text = temperature
        minMaxTemperatureLabel.text = tempMinMaxDesc
        windLabel.text = windSpeed
        windImage.image = UIImage(named: "wind_sign")
        humidityLabel.text = humidityInfo
        humidityImage.image = UIImage(named: "humidity")
        weatherImageView.image = WeatherAppManager.shared.getWeatherIcon(from: data.current)
    }
    
    // MARK: - Update UI
    
    private func showWeatherUI(with coordinates: (latitude: Double, longtitude: Double)) {
        NetworkService.shared.getWeatherForecast(with: (latitude: coordinates.latitude, longtitude: coordinates.longtitude)) { [weak self] data in
            guard let self = self else { return }
            self.tableDataSource = Array(data.daily[1...7])
            self.collectionViewDataSource = Array(data.hourly.prefix(24))
            self.currentWeatherData = data
            DispatchQueue.main.async {
                self.configureWeatherCurrent(from: self.currentWeatherData!)
                self.tableView.reloadData()
                self.collectionView.reloadData()
                
            }
            self.removeSpinner()
        }
    }
    
    // MARK: - Location manager
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            getAddressFrom(latitude: lat, withLongitude: lng)
            showWeatherUI(with: (latitude: lat, longtitude: lng))
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    // MARK: - TableView Functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherDaily", for: indexPath) as? WeatherDailyTableViewCell else { return UITableViewCell() }
        
        guard let timezone_offset = currentWeatherData?.timezone_offset else { return UITableViewCell() }
        
        let model = tableDataSource[indexPath.row]
        cell.configure(with: model, timezone_offset)
        return cell
    }
    
    // MARK: - CollectionView Functions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherHourly", for: indexPath) as? WeatherHourlyCollectionViewCell else { return UICollectionViewCell() }
        
        guard let timezone_offset = currentWeatherData?.timezone_offset else { return UICollectionViewCell() }
        
        let model = collectionViewDataSource[indexPath.item]
        
        cell.configure(with: model, timezone_offset)
        return cell
    }
    
    // MARK: - IBActions
    
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        guard let searchController = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else { return }
        searchController.delegate = self
        searchController.dataSource = self.cityData ?? []
        navigationController?.pushViewController(searchController, animated: true)
    }
}

extension ViewController: CLLocationManagerDelegate {
    private func getAddressFrom(latitude: CLLocationDegrees, withLongitude longitude: CLLocationDegrees) {
        
        let ceo: CLGeocoder = CLGeocoder()
        let loc: CLLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
                                    {(placemarks, error) in
                                        if (error != nil)
                                        {
                                            print("reverse geodcode fail: \(error!.localizedDescription)")
                                        }
                                        let pm = placemarks! as [CLPlacemark]
                                        
                                        if pm.count > 0 {
                                            guard let pm = placemarks?.first else { return }
                                            var addressString : String = "Current location"
                                            if let locality = pm.locality, let country = pm.country {
                                                addressString = "\(locality), \(country)"
                                            }
                                            DispatchQueue.main.async {
                                                self.locationLabel.text = addressString
                                            }
                                        }
                                    })
    }
}

extension ViewController: MenuViewControllerDelegate {
    func updateWeatherUI(with model: City) {
        showSpinner(onView: view, alpha: 1)
        locationLabel.text = "\(model.city), \(model.country)"
        showWeatherUI(with: (latitude: model.lat, longtitude: model.lng))
    }
}
