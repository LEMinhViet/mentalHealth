//
//  ActivityViewController.swift
//  MentalHealth
//
//  Created by Minh Viet LE on 10/30/18.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {
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
    @IBOutlet weak var icon10: UIImageView!
    @IBOutlet weak var icon11: UIImageView!
    @IBOutlet weak var icon12: UIImageView!
    @IBOutlet weak var icon13: UIImageView!
    @IBOutlet weak var icon14: UIImageView!
    @IBOutlet weak var icon15: UIImageView!
    @IBOutlet weak var icon16: UIImageView!
    @IBOutlet weak var icon17: UIImageView!
    
    @IBOutlet weak var sIcon: UIImageView!
    @IBOutlet weak var buttonOK: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    public var chatViewController: ChatViewController!
    
    private var icons: [UIImageView] = []
    private var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.icons = [
            icon00, icon01, icon02, icon03, icon04,
            icon05, icon06, icon07, icon08, icon09,
            icon10, icon11, icon12, icon13, icon14,
            icon15, icon16, icon17
        ]

        for i in 0 ..< self.icons.count {
            icons[i].tag = i
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ActivityViewController.onActivitiyTap(_:)))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            
            icons[i].addGestureRecognizer(tapGesture)
        }
        
        icons[selectedIndex].isHighlighted = true
        
        self.buttonOK.isHidden = true
        self.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func onActivitiyTap(_ sender: UITapGestureRecognizer) {
        for i in 0 ..< self.icons.count {
            self.icons[i].isHighlighted = false
        }
        
        let iconView = sender.view as! UIImageView
        iconView.isHighlighted = true
        sIcon.image = iconView.highlightedImage
        
        self.selectedIndex = iconView.tag
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.buttonOK.isHidden = textField.text == ""
    }
    
    @IBAction func onNewActivity(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
        chatViewController.savedActivitiesData.append(SavedActivityData(
            chatViewController.savedActivitiesData.count,
            "ic_act" + String(selectedIndex) + "_0",
            "ic_act" + String(selectedIndex) + "_1",
            self.textField.text!))
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(chatViewController.savedActivitiesData), forKey: "savedActivities")
        
        chatViewController.updateActivityList()

    }
}
