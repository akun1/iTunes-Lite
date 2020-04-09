//
//  SearchTableViewController.swift
//  iTunes-Lite
//
//  Created by Akash Kundu on 4/9/20.
//  Copyright © 2020 Akash Kundu. All rights reserved.
//

import UIKit

final class SearchTableViewController: UITableViewController {
    
    // MARK - Properties
    
    var sections = [String]()
    var results = [[iTunesServiceAPIResult]]()
    
    // MARK - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "iTunes Lite"
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search iTunes Lite"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func search(with query: String) {
        let cleanQuery = query.replacingOccurrences(of: " ", with: "+")
        
        iTunesService.shared.search(with: cleanQuery) { result in
            DispatchQueue.main.async { [weak self] in
                self?.sections = Array(result.keys)
                self?.results = Array(result.values)
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - TableView Callbacks

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].replacingOccurrences(of: "-", with: " ").capitalized
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// Force unwrapping so I can be alerted of any crashes that happen ASAP because if any happen in a simple app like this inside the cellForRowAt func, then there is likely something wrong with my tableview setup.
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchResultTableViewCell
        let result = results[indexPath.section][indexPath.row]
        cell.titleLabel.text = result.name
        cell.genreLabel.text = result.genre
        cell.itunesLinkLabel.text = result.url
        cell.resultImageView.load(urlString: result.artwork)
        
        let favoriteAction = {
            if let favoritesData = UserDefaults.standard.object(forKey: "Favorites") as? Data {
                let decoder = JSONDecoder()
                
                if let loadedFavorites = try? decoder.decode([iTunesServiceAPIResult].self, from: favoritesData) {
                    let encoder = JSONEncoder()
                    var updatedFavorites = loadedFavorites
                    updatedFavorites.append(result)
                    
                    if let encoded = try? encoder.encode(updatedFavorites) {
                        UserDefaults.standard.set(encoded, forKey: "Favorites")
                    }
                }
            }
        }
        
        let unfavoriteAction = {
            if let favoritesData = UserDefaults.standard.object(forKey: "Favorites") as? Data {
                let decoder = JSONDecoder()
                
                if let loadedFavorites = try? decoder.decode([iTunesServiceAPIResult].self, from: favoritesData) {
                    let encoder = JSONEncoder()
                    var updatedFavorites = loadedFavorites.filter({ $0.id == result.id })
                    
                    if let encoded = try? encoder.encode(updatedFavorites) {
                        UserDefaults.standard.set(encoded, forKey: "Favorites")
                    }
                }
            }
        }
        
        cell.favoriteAction = favoriteAction
        cell.unfavoriteAction = favoriteAction
        
        return cell
    }
}

extension SearchTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else {
            return
        }
        
        search(with: query)
    }
}
