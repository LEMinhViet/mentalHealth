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
        diaryData.insert(DiaryData(id: diaryData.count, title: titleField.text, content: contentField.text, createdDate: Date()), at: 0)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(diaryData), forKey: "diaryData")
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var isTitleEdited: Bool = false
    var isContentEdited: Bool = false
    var diaryData: [DiaryData] = []
    
    func setDiaryData(data: [DiaryData]) {
        self.diaryData = data
    }
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)

        // Do any additional setup after loading the view.
        
        isTitleEdited = false
        isContentEdited = false
        
        titleField.layer.shadowColor = UIColor.black.cgColor
        titleField.layer.shadowOpacity = 0.2
        titleField.layer.shadowOffset = CGSize(width: 0, height: 1)
        titleField.clipsToBounds = false
        titleField.textContainerInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        
        contentField.textContainerInset = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
        
        saveButton.layer.cornerRadius = 5
        
        // Dismiss keyboard tap recognizer
        let dismisTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewDiaryViewController.dismissKeyboard))
        
        view.addGestureRecognizer(dismisTap)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardNotification(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
    }
    
    // Calls this function when the tap is recognized.
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // Keyboard handler
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        let bottomMargin: CGFloat = 20.0
        
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.bottomConstraint?.constant = bottomMargin
            } else {
                self.bottomConstraint?.constant = (endFrame?.size.height)! + bottomMargin
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
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
}
