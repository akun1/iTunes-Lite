//
//  SearchTableViewController.swift
//  iTunes-Lite
//
//  Created by Akash Kundu on 4/9/20.
//  Copyright © 2020 Akash Kundu. All rights reserved.
//

import UIKit

final class SearchTableViewController: UITableViewController {
    
    var resp: [iTunesResult]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        iTunesService.shared.searchItunes(with: "brad+pitt") { [weak self] resp in
            DispatchQueue.main.async {
                self?.resp = resp
                self?.tableView.reloadData()
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resp?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
}
