//
//  ChatViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 22/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class ChatViewController: BaseViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    enum ANSWER_TYPE {
        case normal
        case good_bad
        case activity
    }
    
    let ACTIVITIES: [String] = [
        "Làm việc", "Thư giãn", "Bạn bè", "Hẹn hò", "Thể thao",
        "tiệc tùng", "xem phim", "đọc sách", "chơi game"
    ]
    
    let EMOTIONS: [String] = [
        "Tồi tệ", "Xấu", "Bình thường", "Tốt", "Tuyệt vời"
    ]

    @IBOutlet weak var chatPanel: UIView!
    @IBOutlet weak var emotionPanel: UIView!
    @IBOutlet weak var activityPanel: UIView!
    @IBOutlet weak var chatContentPanel: UITableView!
    @IBOutlet weak var chatTextField: UITextView!
    
    @IBAction func sendChatClicked(_ sender: Any) {
        answer.append(chatTextField.text)
        self.nextQuestion()
    }
    
    @IBAction func onEmoClicked(_ sender: UITapGestureRecognizer) {
        answer.append(EMOTIONS[(sender.view?.tag)!])
        self.nextQuestion()
    }
    
    @IBOutlet var onEmoClicked: UITapGestureRecognizer!
    var isChatEdited: Bool = false
    
    let question: [String] = ["Hôm nay bạn cảm thấy thế nào", "Hôm nay bạn đã làm những gì", "Hôm nay có điều gì khiến bạn cảm thấy cuộc sống có ý nghĩa"]
    
    let answerType: [ANSWER_TYPE] = [ANSWER_TYPE.normal, ANSWER_TYPE.activity, ANSWER_TYPE.normal]
    var answer: [String] = []
    
    var curQuestion: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)
        
        isChatEdited = false

        // Do any additional setup after loading the view.
        chatTextField.layer.cornerRadius = 20
        chatTextField.layer.masksToBounds = true
        
        chatTextField.textContainerInset = UIEdgeInsetsMake(10, 15, 10, 15)

        chatPanel.frame.size = CGSize(width: chatPanel.frame.width, height: 0)
        
        self.showUserInput()
    }
    
    func showUserInput() {
        chatPanel.isHidden = answerType[curQuestion] != ANSWER_TYPE.normal
        emotionPanel.isHidden = answerType[curQuestion] != ANSWER_TYPE.good_bad
        activityPanel.isHidden = answerType[curQuestion] != ANSWER_TYPE.activity
        
        chatTextField.text = ""
    }
    
    func nextQuestion() {
        self.curQuestion = min(self.curQuestion + 1, question.count - 1)
        chatContentPanel.reloadData()
        self.showUserInput()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return curQuestion < question.count ? curQuestion * 2 + 1 : curQuestion * 2 - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row % 2 == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "questionChatCell", for: indexPath) as! QuestionChatCell
            
            cell.chatContent.text = question[indexPath.row / 2]
            
            let layer = cell.chatContent.layer
            let frame = cell.chatContent.frame
            
            layer.masksToBounds = true
            layer.cornerRadius = frame.height * 0.25
            layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner]
            
            let newSize = cell.chatContent.sizeThatFits(CGSize(width: cell.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
            
            cell.chatContent.frame.size = CGSize(width: newSize.width, height: newSize.height)
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "answerChatCell", for: indexPath) as! AnswerChatCell
            
            cell.chatContent.text = answer[indexPath.row / 2]
            
            let layer = cell.chatContent.layer
            let frame = cell.chatContent.frame
            
            layer.masksToBounds = true
            layer.cornerRadius = frame.height * 0.25
            layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]
            
            let newSize = cell.chatContent.sizeThatFits(CGSize(width: cell.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
            
            cell.chatContent.frame.size = CGSize(width: newSize.width, height: newSize.height)
            
            return cell
        }
    }   

    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView == chatTextField && !isChatEdited) {
            isChatEdited = true
            chatTextField.text = nil
        }
    }
}
