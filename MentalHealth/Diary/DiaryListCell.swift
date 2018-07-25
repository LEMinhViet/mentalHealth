//
//  DiaryListCell.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 21/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class DiaryListCell: UITableViewCell {

    @IBOutlet weak var shadowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
