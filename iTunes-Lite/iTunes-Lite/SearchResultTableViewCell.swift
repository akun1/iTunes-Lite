//
//  SearchResultTableViewCell.swift
//  iTunes-Lite
//
//  Created by Akash Kundu on 4/9/20.
//  Copyright © 2020 Akash Kundu. All rights reserved.
//

import UIKit

final class SearchResultTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var itunesLinkLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    // MARK: - Properties
    
    var favoriteAction: (() -> Void)?
    var unfavoriteAction: (() -> Void)?
    
    // MARK: - Life Cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        selectionStyle = .none
        resultImageView.layer.cornerRadius = 6
    }
    
    // MARK: - Actions
    
    @IBAction func favoriteButtonTapped() {
        if favoriteButton.isSelected {
            unfavorite()
        } else {
            favorite()
        }
    }
    
    // MARK: - Helpers
    
    func unfavorite() {
        unfavoriteAction?()
        favoriteButton.isSelected = false
    }
    
    func favorite() {
        favoriteAction?()
        favoriteButton.isSelected = true
    }
}
