import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var lineViews: [UIView]!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var currentWeatherLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var minMaxTemperatureLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var humidityImage: UIImageView!
    @IBOutlet weak var windImage: UIImageView!
    @IBOutlet weak var currentLocation: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - lets / vars
    
    private let screenSize: CGRect = UIScreen.main.bounds
    private let locationManager = CLLocationManager()
    private let manager = WeatherAppManager.shared
    private let reachability = try! Reachability()
    private let refreshControl: UIRefreshControl = {
        let myRefreshControl = UIRefreshControl()
        myRefreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        return myRefreshControl
    }()
    private var tableDataSource = [WeatherDaily]()
    private var collectionViewDataSource = [WeatherHourly]()
    private var currentWeatherData: WeatherData?
    
    public var cityData: [City]?
    public var latitude: CLLocationDegrees?
    public var longitude: CLLocationDegrees?
    
    // MARK: - Lifecycle functions
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        reachability.stopNotifier()
        
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let guide = view.safeAreaLayoutGuide
        let height = guide.layoutFrame.size.height
        
        containerViewHeightConstraint.constant = height
        view.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.refreshControl = refreshControl
        
        // MARK: - CollectionView and TableView register
        collectionView.register(UINib(nibName: "WeatherHourlyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WeatherHourly")
        tableView.register(UINib(nibName: "WeatherDailyTableViewCell", bundle: nil), forCellReuseIdentifier: "WeatherDaily")
        
        // MARK: - Location
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
        
        // MARK: - JSON Parse
        
        showSpinner(onView: view, alpha: 1)
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
        
        lineViews.forEach { $0.alpha = 1 }
        menuButton.alpha = 1
        currentLocation.alpha = 1
        locationLabel.adjustsFontSizeToFitWidth = true
        locationLabel.minimumScaleFactor = 0.5
        
        currentWeatherLabel.text = weather.description.capitalizingFirstLetter()
        temperatureLabel.text = temperature
        minMaxTemperatureLabel.text = tempMinMaxDesc
        windLabel.text = windSpeed
        windImage.image = UIImage(named: "wind_sign")
        humidityLabel.text = humidityInfo
        humidityImage.image = UIImage(named: "humidity")
        weatherImageView.image = WeatherAppManager.shared.getWeatherIcon(from: data.current)
    }
    
    private func getInternetConnectionStatusView() -> InternetConnectionStatusView {
        
        let internetConnectionStatusView = InternetConnectionStatusView.instanceFromNib()
        internetConnectionStatusView.frame = CGRect(x: Consts.ConnectionStatusView.x, y: Consts.ConnectionStatusView.y, width: Consts.ConnectionStatusView.width, height: Consts.ConnectionStatusView.height)
        internetConnectionStatusView.layer.cornerRadius = Consts.ConnectionStatusView.cornerRadius
        
        self.view.addSubview(internetConnectionStatusView)
        
        return internetConnectionStatusView
    }
    
    // MARK: - Show Network Status
    
    private func animateView(_ view: InternetConnectionStatusView, withStatus status: ConnectionStatus ) {
        
        func animate(withCompletionDelay delay: TimeInterval = 0) {
            UIView.animate(withDuration: 1) {
                view.frame = CGRect(x: Consts.ConnectionStatusView.x,
                                    y: Consts.ConnectionStatusView.y1,
                                    width: Consts.ConnectionStatusView.width,
                                    height: Consts.ConnectionStatusView.height)
            } completion: { _ in
                UIView.animate(withDuration: 1, delay: delay) {
                    view.frame = CGRect(x: Consts.ConnectionStatusView.x, y: Consts.ConnectionStatusView.y, width: Consts.ConnectionStatusView.width, height: Consts.ConnectionStatusView.height)
                    
                    _ = Timer.scheduledTimer(withTimeInterval: delay + 1, repeats: false) { (_) in
                        view.removeFromSuperview()
                    }
                }
            }
        }
        
        switch status {
        case .cellular:
            view.backgroundColor = .systemGreen
            view.statusLabel.text = "Cellular Connection"
            view.imageView.image = UIImage(named: ConnectionType.cellular.rawValue)
            animate()
        case .wifi:
            view.backgroundColor = .systemGreen
            view.statusLabel.text = "Wifi Connection"
            view.imageView.image = UIImage(named: ConnectionType.wifi.rawValue)
            animate()
        case .unavailable:
            view.backgroundColor = .systemRed
            view.statusLabel.text = "No Internet Connection"
            view.imageView.image = UIImage(named: ConnectionType.unavailable.rawValue)
            animate(withCompletionDelay: 3)
        }
    }
    
    // MARK: - Update Weather UI
    
    private func showWeatherUI(with coordinates: (latitude: Double, longitude: Double)) {
        NetworkService.shared.getWeatherForecast(with: (latitude: coordinates.latitude, longitude: coordinates.longitude)) { [weak self] data in
            guard let self = self else { return }
            self.tableDataSource = Array(data.daily[1...7])
            self.collectionViewDataSource = Array(data.hourly.prefix(24))
            self.currentWeatherData = data
            DispatchQueue.main.async {
                self.configureWeatherCurrent(from: self.currentWeatherData!)
                self.tableView.reloadData()
                self.collectionView.reloadData()
                self.refreshControl.endRefreshing()
            }
            self.removeSpinner()
        }
    }
    
    // MARK: - Location Manager
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            if let lat = latitude, let lng = longitude {
                getAddressFrom(latitude: lat, withLongitude: lng)
                showWeatherUI(with: (latitude: lat, longitude: lng))
            }
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
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        guard let latitude = self.latitude, let longitude = self.longitude else { return }
        showWeatherUI(with: (latitude: Double(latitude), longitude: Double(longitude)))
    }
    
    @IBAction func getCurrentLocationButton(_ sender: UIButton) {
        showSpinner(onView: view, alpha: 0)
        locationManager.requestLocation()
    }
    
    // MARK: - Reachability
    @IBAction func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
        let internetConnectionStatusView = getInternetConnectionStatusView()
        
        switch reachability.connection {
        case .wifi:
            animateView(internetConnectionStatusView, withStatus: .wifi)
        case .cellular:
            animateView(internetConnectionStatusView, withStatus: .cellular)
        case .unavailable:
            animateView(internetConnectionStatusView, withStatus: .unavailable)
        }
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
                                            self.locationLabel.text = "Current location"
                                            print("Reverse geodcode fail: \(error!.localizedDescription)")
                                            
                                        }
                                        guard let pm = placemarks else {
                                            return
                                        }
                                        
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
    func updateLocationCoordinates(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func updateWeatherUI(with model: City) {
        showSpinner(onView: view, alpha: 1)
        locationLabel.text = "\(model.city), \(model.country)"
        showWeatherUI(with: (latitude: model.lat, longitude: model.lng))
    }
}
