//
//  NewDiaryViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 19/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class NewDiaryViewController: BaseViewController, UITextViewDelegate {

    @IBOutlet weak var titleField: UITextView!
    @IBOutlet weak var contentField: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBAction func onSaveClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    var isTitleEdited: Bool = false
    var isContentEdited: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)

        // Do any additional setup after loading the view.
        
        isTitleEdited = false
        isContentEdited = false
        
        titleField.layer.shadowColor = UIColor.black.cgColor
        titleField.layer.shadowOpacity = 0.2
        titleField.layer.shadowOffset = CGSize(width: 0, height: 1)
        titleField.clipsToBounds = false
        titleField.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)
        
        contentField.textContainerInset = UIEdgeInsetsMake(15, 15, 15, 15)
        
        saveButton.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView == titleField && !isTitleEdited) {
            isTitleEdited = true
            titleField.text = nil
        }
        
        if (textView == contentField && !isContentEdited) {
            isContentEdited = true
            contentField.text = nil
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
