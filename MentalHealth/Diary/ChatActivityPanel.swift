//
//  ChatActivityPanel.swift
//  MentalHealth
//
//  Created by Minh Viet LE on 10/31/18.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class ChatActivityPanel: UIView {

    @IBOutlet weak var icon00: UIImageView!
    @IBOutlet weak var icon01: UIImageView!
    @IBOutlet weak var icon02: UIImageView!
    @IBOutlet weak var icon03: UIImageView!
    @IBOutlet weak var icon04: UIImageView!
    @IBOutlet weak var icon05: UIImageView!
    @IBOutlet weak var icon06: UIImageView!
    @IBOutlet weak var icon07: UIImageView!
    @IBOutlet weak var icon08: UIImageView!
    @IBOutlet weak var icon09: UIImageView!
    
    @IBOutlet weak var text00: UILabel!
    @IBOutlet weak var text01: UILabel!
    @IBOutlet weak var text02: UILabel!
    @IBOutlet weak var text03: UILabel!
    @IBOutlet weak var text04: UILabel!
    @IBOutlet weak var text05: UILabel!
    @IBOutlet weak var text06: UILabel!
    @IBOutlet weak var text07: UILabel!
    @IBOutlet weak var text08: UILabel!
    @IBOutlet weak var text09: UILabel!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func updateItems(items: [SavedActivityData], start: Int, end: Int, target: Any?) {
        var icons: [UIImageView] = [
            icon00, icon01, icon02, icon03, icon04,
            icon05, icon06, icon07, icon08, icon09
        ]
        
        var texts: [UILabel] = [
            text00, text01, text02, text03, text04,
            text05, text06, text07, text08, text09
        ]
        
        for i in 0 ..< icons.count {
            for recognizer in icons[i].gestureRecognizers ?? [] {
                icons[i].removeGestureRecognizer(recognizer)
            }
            
            if i <= end - start {
                icons[i].alpha = 1
                texts[i].alpha = 1
                
                icons[i].image = UIImage(named: items[i + start].image)
                icons[i].highlightedImage = UIImage(named: items[i + start].hImage)
                texts[i].text = items[i + start].text
                icons[i].tag = i + start
                
                let tapGesture = UITapGestureRecognizer(target: target, action: #selector(ChatViewController.onActivitiyTap(_:)))
                tapGesture.numberOfTapsRequired = 1
                tapGesture.numberOfTouchesRequired = 1
                
                icons[i].addGestureRecognizer(tapGesture)
            }
            else if i == end - start + 1 {
                icons[i].alpha = 1
                texts[i].alpha = 1
                
                icons[i].image = UIImage(named: "ic_add")
                icons[i].highlightedImage = UIImage(named: "ic_add")
                texts[i].text = "Khác"
                icons[i].tag = i + start
                
                let tapGesture = UITapGestureRecognizer(target: target, action: #selector(ChatViewController.onAddActivitiyTap(_:)))
                tapGesture.numberOfTapsRequired = 1
                tapGesture.numberOfTouchesRequired = 1
                
                icons[i].addGestureRecognizer(tapGesture)
            }
            else {
                icons[i].alpha = 0
                texts[i].alpha = 0
            }
        }
    }
}
