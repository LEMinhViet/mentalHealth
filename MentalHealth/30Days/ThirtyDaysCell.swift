//
//  ThirtyDaysCell.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 11/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class ThirtyDaysCell: UITableViewCell {
    
    enum ThirtyDayEnum: Int {
        case LockedDay = 0
        case PassedDay = 1
        case CurrentDay = 2
    };

    @IBOutlet weak var bgButton: UIButton!
    @IBOutlet weak var dayLabel: UILabel!
    @IBAction func dayClicked(_ sender: Any) {
        if (type == ThirtyDayEnum.LockedDay.rawValue) {
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DayViewController") as! DayViewController
        
        vc.dayIndex = index
        
        if (self.navigationController != nil) {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    var index: Int = 0;
    var type: Int = 0;
    var navigationController: UINavigationController!
    
    let images = ["img_ngaylock.png", "img_ngaydadoc.png", "img_ngaychuadoc.png"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bgButton.setImage(UIImage(named: images[type]), for: .normal)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    public func setNavigation(navigation: UINavigationController) {
        self.navigationController = navigation
    }
    
    public func updateContent(index: Int, type: Int) {
        self.index = index
        self.type = type

        dayLabel.text = "Ngày thứ " + String(index + 1)
        bgButton.setImage(UIImage(named: images[type]), for: .normal)
    }
}
