//
//  DocumentCell.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 25/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class DocumentCell: UITableViewCell {
    
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var dateTitle: UILabel!
    @IBOutlet weak var dayTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
