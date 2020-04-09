//
//  SearchTableViewController.swift
//  iTunes-Lite
//
//  Created by Akash Kundu on 4/9/20.
//  Copyright © 2020 Akash Kundu. All rights reserved.
//

import UIKit

final class SearchTableViewController: UITableViewController {
    
    var sections = [String]()
    var results = [[iTunesServiceAPIResult]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        iTunesService.shared.search(with: "brad+pitt") { result in
            DispatchQueue.main.async { [weak self] in
                self?.sections = Array(result.keys)
                self?.results = Array(result.values)
                self?.tableView.reloadData()
            }
        }
    }

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
}
