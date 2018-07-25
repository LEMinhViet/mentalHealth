//
//  ChatViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 22/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class ChatViewController: BaseViewController, UITextViewDelegate {

    @IBOutlet weak var chatPanel: UIView!
    @IBOutlet weak var emotionPanel: UIView!
    @IBOutlet weak var activityPanel: UIView!
    @IBOutlet weak var chatTextField: UITextView!
    
    var isChatEdited: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)
        
        isChatEdited = false

        // Do any additional setup after loading the view.
        chatTextField.layer.cornerRadius = 20
        chatTextField.layer.masksToBounds = true
        
        chatTextField.textContainerInset = UIEdgeInsetsMake(10, 15, 10, 15)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView == chatTextField && !isChatEdited) {
            isChatEdited = true
            chatTextField.text = nil
        }
    }

}
