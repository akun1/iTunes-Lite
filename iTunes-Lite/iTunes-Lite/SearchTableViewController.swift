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
        loadData()
    }
    
    // MARK: - Setup
    
    private func loadData() {
        iTunesService.shared.search(with: "brad+pitt") { result in
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
        return sections[section]
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
        return cell
    }
}

extension UIImageView {
    func load(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
