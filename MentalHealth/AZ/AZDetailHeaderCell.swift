//
//  AZDetailHeaderCell.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 17/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class AZDetailHeaderCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var arrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setExtended() {
        arrow.isHighlighted = true
        
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

    }
    
    func setCollapsed() {
        arrow.isHighlighted = false
        
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}
