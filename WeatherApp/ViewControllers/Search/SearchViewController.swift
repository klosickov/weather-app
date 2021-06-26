import UIKit

protocol MenuViewControllerDelegate: AnyObject {
    func updateWeatherUI(with city: City)
}

class SearchViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - lets / vars
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    private var isSearchBarEmpty: Bool {
        guard let text = searchController.searchBar.text else { return true }
        return text.isEmpty
    }
    
    private var filteredDataSource = [City]()
    
    weak var delegate: MenuViewControllerDelegate?
    
    public var dataSource = [City]()
    
    // MARK: - Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        title = "Сities"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        // MARK: - TableView Configuration
        dataSource = dataSource.sorted { $0.city < $1.city }
        tableView.register(UINib(nibName: "CityTableViewCell", bundle: nil), forCellReuseIdentifier: "CityCell")
    }
}

// MARK: - UITableView Delegate, DataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredDataSource.count
        }
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath) as? CityTableViewCell else { return UITableViewCell() }
        
        var model: City
        
        if isFiltering {
            model = filteredDataSource[indexPath.row]
        } else {
            model = dataSource[indexPath.row]
        }
        
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var model: City
        
        if isFiltering {
            model = filteredDataSource[indexPath.row]
        } else {
            model = dataSource[indexPath.row]
        }
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.updateWeatherUI(with: model)
        
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension SearchViewController: UISearchResultsUpdating {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("searchText: \(searchText)")
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else { return }
        filterContentForSearchText(searchBarText)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        
        filteredDataSource = dataSource.filter { (model: City) -> Bool in
            return model.city.lowercased().contains(searchText.lowercased()) ||
                model.country.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
}
