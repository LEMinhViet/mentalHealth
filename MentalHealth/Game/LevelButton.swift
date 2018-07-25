//
//  LevelButton.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 09/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class LevelButton: UITableViewCell {

    @IBOutlet weak var levelImage: UIImageView!
    @IBOutlet weak var levelText: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
