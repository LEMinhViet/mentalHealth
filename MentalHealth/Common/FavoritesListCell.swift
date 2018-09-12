//
//  FavoritesListCell.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 04/09/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class FavoritesListCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var featuredImageView: UIImageView!
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
