//
//  AZDetailCell.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 17/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class AZDetailCell: UITableViewCell {
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
