//
//  VideoCell.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 13/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class VideoCell: UITableViewCell {

    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var dayTitle: UILabel!
    @IBOutlet weak var dateTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        dayTitle.isHidden = true
        dateTitle.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
