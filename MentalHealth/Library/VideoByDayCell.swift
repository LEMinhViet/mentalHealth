//
//  VideoByDayCell.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 13/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class VideoByDayCell: UIView {

    @IBOutlet weak var featuredVideo: UIImageView!
    
    @IBAction func onClicked(_ sender: Any) {
        guard let url = URL(string: "https://www.youtube.com/watch?v=wENWyGTvmVM") else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
