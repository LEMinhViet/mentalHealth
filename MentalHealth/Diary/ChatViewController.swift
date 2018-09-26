//
//  ChatViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 22/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

struct ChatAllQuestionsData: Codable {
    let per_page: Int
    let current_page: Int
    let next_page_url: String?
    let prev_page_url: String?
    let from: Int
    let to: Int
    let data: [ChatQuestionData]
    
    init() {
        per_page = 0
        current_page = 0
        next_page_url = ""
        prev_page_url = ""
        from = 0
        to = 0
        data = []
    }
}

struct ChatQuestionData: Codable {
    let id: Int
    let question: String
    let created_at: String
    let updated_at: String
}

class ChatViewController: BaseViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    enum ANSWER_TYPE {
        case normal
        case good_bad
        case activity
    }
    
    let ACTIVITIES: [String] = [
        "Làm việc", "Thư giãn", "Bạn bè", "Hẹn hò", "Thể thao",
        "Tiệc tùng", "Xem phim", "Đọc sách", "Chơi game"
    ]
    
    let EMOTIONS: [String] = [
        "Tồi tệ", "Xấu", "Bình thường", "Tốt", "Tuyệt vời"
    ]

    @IBOutlet weak var chatPanel: UIView!
    @IBOutlet weak var emotionPanel: UIView!
    @IBOutlet weak var activityPanel: UIView!
    @IBOutlet weak var chatContentPanel: UITableView!
    @IBOutlet weak var chatTextField: UITextView!
    
    
    @IBOutlet weak var workingImageView: UIImageView!
    @IBOutlet weak var relaxImageView: UIImageView!
    @IBOutlet weak var friendsImageView: UIImageView!
    @IBOutlet weak var loveImageView: UIImageView!
    @IBOutlet weak var sportImageView: UIImageView!
    @IBOutlet weak var partyImageView: UIImageView!
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var readingImageView: UIView!
    @IBOutlet weak var gameImageView: UIImageView!
    
    @IBOutlet weak var greatImageView: UIImageView!
    @IBOutlet weak var goodImageView: UIImageView!
    @IBOutlet weak var normalImageView: UIImageView!
    @IBOutlet weak var badImageView: UIImageView!
    @IBOutlet weak var awfulImageView: UIImageView!
    
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var emotionHeightLayoutConstraint: NSLayoutConstraint!
    
    @IBAction func sendChatClicked(_ sender: Any) {
        answer.append(chatTextField.text)
        self.nextQuestion()
    }
    
    var isChatEdited: Bool = false
    
    var question: [String] = ["Hôm nay bạn cảm thấy thế nào", "Hôm nay bạn đã làm những gì", "Hôm nay có điều gì khiến bạn cảm thấy cuộc sống có ý nghĩa"]
    
    let answerType: [ANSWER_TYPE] = [ANSWER_TYPE.good_bad, ANSWER_TYPE.activity, ANSWER_TYPE.normal]
    var answer: [String] = []
    var activityTmpAnswer: [Int] = []
    
    var curQuestion: Int = 0
    
    let apiUrl: String = Constants.url + Constants.apiPrefix + "/monster"
    var chatAllQuestionsData = ChatAllQuestionsData()
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)
        
        chatPanel.isHidden = true
        emotionPanel.isHidden = true
        activityPanel.isHidden = true
        
        isChatEdited = false

        // Do any additional setup after loading the view.
        chatTextField.layer.cornerRadius = 20
        chatTextField.layer.masksToBounds = true
        
        chatTextField.textContainerInset = UIEdgeInsetsMake(10, 15, 10, 15)

        chatPanel.frame.size = CGSize(width: chatPanel.frame.width, height: 0)
        
        NotificationCenter.default.addObserver(self,
           selector: #selector(self.keyboardNotification(notification:)),
           name: NSNotification.Name.UIKeyboardWillChangeFrame,
           object: nil)
        
        // Do any additional setup after loading the view.
        guard let url = URL(string: apiUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, resonse, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let jsonData = try JSONDecoder().decode(ChatAllQuestionsData.self, from: data)
                
                // Get back to the main queue
                DispatchQueue.main.async {
                    self.chatAllQuestionsData = jsonData
                    self.question = []
                    for i in 0 ..< jsonData.data.count {
                        self.question.append(jsonData.data[i].question)
                    }
                    
                    self.chatContentPanel.reloadData()
                    self.showUserInput()
                }
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
        
        // Implement Activities and Emoticons events
        let activitiesViews = [workingImageView, relaxImageView, friendsImageView, loveImageView, sportImageView, partyImageView, movieImageView, readingImageView, gameImageView]
        for i in 0 ..< activitiesViews.count {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.onActivitiyTap(_:)))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            
            activitiesViews[i]?.addGestureRecognizer(tapGesture)
        }
        
        let emotionViews = [greatImageView, goodImageView, normalImageView, badImageView, awfulImageView]
        for i in 0 ..< emotionViews.count {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.onEmotionTap(_:)))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            
            emotionViews[i]?.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func onActivitiyTap(_ sender: UITapGestureRecognizer) {
        let activityView = sender.view as! UIImageView
        
        if activityView.isHighlighted {
            activityView.isHighlighted = false
            self.activityTmpAnswer = self.activityTmpAnswer.filter {$0 != activityView.tag}
        }
        else {
            activityView.isHighlighted = true
            self.activityTmpAnswer.append(activityView.tag)
        }
    }
    
    @IBAction func onActivityDone(_ sender: Any) {
        var tmpAnswer = ""
        for i in 0 ..< self.activityTmpAnswer.count {
            if i > 0 {
                tmpAnswer += ", "
            }
            
            tmpAnswer += ACTIVITIES[self.activityTmpAnswer[i]]
        }
        
        answer.append(tmpAnswer)
        self.nextQuestion()
    }
    
    @objc func onEmotionTap(_ sender: UITapGestureRecognizer) {
        answer.append(EMOTIONS[sender.view?.tag ?? 0])
        self.nextQuestion()
    }
    
    func showUserInput() {
        chatPanel.isHidden = answerType[curQuestion] != ANSWER_TYPE.normal
        emotionPanel.isHidden = answerType[curQuestion] != ANSWER_TYPE.good_bad
        activityPanel.isHidden = answerType[curQuestion] != ANSWER_TYPE.activity
        
        if chatPanel.isHidden {
            view.endEditing(true)
        }
        
        chatTextField.text = ""
    }
    
    func hideUserInput() {
        chatPanel.isHidden = true
        emotionPanel.isHidden = true
        activityPanel.isHidden = true
    }
    
    func nextQuestion() {
        if self.curQuestion + 1 < question.count {
            self.curQuestion = self.curQuestion + 1
            chatContentPanel.reloadData()
            self.showUserInput()
            
            if (answerType[self.curQuestion] == ANSWER_TYPE.activity) {
                self.activityTmpAnswer = []
            }
        }
        else {
            chatContentPanel.reloadData()
            hideUserInput()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if curQuestion < question.count - 1 {
            return curQuestion * 2 + 1
        }
        else {
            if answer.count == question.count {
                return question.count * 2
            }
            else {
                return curQuestion * 2 + 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row % 2 == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "questionChatCell", for: indexPath) as! QuestionChatCell
            
            cell.chatContent.text = question[indexPath.row / 2]
            
            let layer = cell.chatContent.layer
            let frame = cell.chatContent.frame
            
            let newSize = cell.chatContent.sizeThatFits(CGSize(width: cell.frame.size.width, height: CGFloat.greatestFiniteMagnitude))

            cell.chatContent.frame.size = CGSize(width: newSize.width, height: newSize.height)
            
            layer.masksToBounds = true
            self.roundCorners(cell.chatContent, corners: [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner], radius: frame.height * 0.25)
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "answerChatCell", for: indexPath) as! AnswerChatCell
            
            cell.chatContent.text = answer[indexPath.row / 2]
            
            let layer = cell.chatContent.layer
            let frame = cell.chatContent.frame
            
            let newSize = cell.chatContent.sizeThatFits(CGSize(width: cell.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
            
            cell.chatContent.frame.size = CGSize(width: newSize.width, height: newSize.height)
            
            layer.masksToBounds = true
            self.roundCorners(cell.chatContent, corners: [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner], radius: frame.height * 0.25)
            
            return cell
        }
    }   

    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView == chatTextField && !isChatEdited) {
            isChatEdited = true
            chatTextField.text = nil
        }
    }
    
    // Keyboard handler
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        let bottomMargin: CGFloat = 10.0
        
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = bottomMargin
                self.chatHeightLayoutConstraint?.constant = bottomMargin
                self.activityHeightLayoutConstraint?.constant = bottomMargin
                self.emotionHeightLayoutConstraint?.constant = bottomMargin
            } else {
                self.keyboardHeightLayoutConstraint?.constant = (endFrame?.size.height)! + bottomMargin
                self.chatHeightLayoutConstraint?.constant = (endFrame?.size.height)! + bottomMargin
                self.activityHeightLayoutConstraint?.constant = (endFrame?.size.height)! + bottomMargin
                self.emotionHeightLayoutConstraint?.constant = (endFrame?.size.height)! + bottomMargin
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    func roundCorners(_ view: UIView, corners: CACornerMask, radius: CGFloat) {
        if #available(iOS 11, *) {
            view.layer.cornerRadius = radius
            view.layer.maskedCorners = corners
        } else {
            var cornerMask = UIRectCorner()
            if(corners.contains(.layerMinXMinYCorner)){
                cornerMask.insert(.topLeft)
            }
            if(corners.contains(.layerMaxXMinYCorner)){
                cornerMask.insert(.topRight)
            }
            if(corners.contains(.layerMinXMaxYCorner)){
                cornerMask.insert(.bottomLeft)
            }
            if(corners.contains(.layerMaxXMaxYCorner)){
                cornerMask.insert(.bottomRight)
            }
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: cornerMask, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
        }
    }
}
