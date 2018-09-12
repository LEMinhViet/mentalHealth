//
//  NotificationListCell.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 03/09/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class NotificationListCell: UITableViewCell {
    
    @IBOutlet weak var appImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
