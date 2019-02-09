//
//  ChatViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 22/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

struct SavedActivityData: Codable {
    var id: Int
    var image: String
    var hImage: String
    var text: String
    
    init(_ id: Int, _ image: String, _ hImage: String, _ text: String) {
        self.id = id
        self.image = image
        self.hImage = hImage
        self.text = text
    }
}

struct PostAnswerData: Codable {
    var message: String
}

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

struct ChatAnswerData: Codable {
    let id: Int
    let user_id: Int
    let monster_id: Int
    let answer_id: Int?
    let answer: String?
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
    
    @IBOutlet weak var greatImageView: UIImageView!
    @IBOutlet weak var goodImageView: UIImageView!
    @IBOutlet weak var normalImageView: UIImageView!
    @IBOutlet weak var badImageView: UIImageView!
    @IBOutlet weak var awfulImageView: UIImageView!
    
    @IBOutlet weak var activityPageView: UIView!
    @IBOutlet weak var activityStackView: UIStackView!
    @IBOutlet weak var activityPageControl: UIPageControl!
    
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var emotionHeightLayoutConstraint: NSLayoutConstraint!
    
    @IBAction func sendChatClicked(_ sender: Any) {
        answer.append(chatTextField.text)
        self.postAnswer(questionId: curQuestion, answerId: nil, answer: answer[curQuestion])
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
        
        chatTextField.textContainerInset = UIEdgeInsets.init(top: 10, left: 15, bottom: 10, right: 15)

        chatPanel.frame.size = CGSize(width: chatPanel.frame.width, height: 0)
        
        NotificationCenter.default.addObserver(self,
           selector: #selector(self.keyboardNotification(notification:)),
           name: UIResponder.keyboardWillChangeFrameNotification,
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
//                    self.showUserInput()
                    self.hideUserInput()
                    self.getAnswers()
                }
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
        
        // Implement Activities and Emoticons events
        if let data = UserDefaults.standard.value(forKey: "savedActivities") as? Data {
            self.savedActivitiesData = try! PropertyListDecoder().decode(Array<SavedActivityData>.self, from: data)
        }
        else {
            self.savedActivitiesData = [
                SavedActivityData(0, "ic_work1", "ic_work2", "Làm việc"),
                SavedActivityData(1, "ic_relax1", "ic_relax2", "Thư giãn"),
                SavedActivityData(2, "ic_friend", "ic_friend2", "Bạn bè"),
                SavedActivityData(3, "ic_love", "ic_love2", "Hẹn hò"),
                SavedActivityData(4, "ic_sport1", "ic_sport2", "Thể thao"),
                SavedActivityData(5, "ic_party1", "ic_party2", "Tiệc tùng"),
                SavedActivityData(6, "ic_film1", "ic_film2", "Xem phim"),
                SavedActivityData(7, "ic_reading1", "ic_reading2", "Đọc sách"),
                SavedActivityData(8, "ic_game1", "ic_game2", "Chơi game")
            ]
            
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.savedActivitiesData), forKey: "savedActivities")
        }
        
        self.updateActivityList()
        
        // Emoticon section
        
        let emotionViews = [greatImageView, goodImageView, normalImageView, badImageView, awfulImageView]
        for i in 0 ..< emotionViews.count {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.onEmotionTap(_:)))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            
            emotionViews[i]?.addGestureRecognizer(tapGesture)
        }
    }
    
    func updateActivityList() {
        let nbItemsEachPage = NB_ITEMS_EACH_LINE * NB_LINES_EACH_PAGE
        
        self.nbPages = Int(ceil(Double(savedActivitiesData.count + 1) / Double(nbItemsEachPage)))
        
        self.activityPanels = []
        for oldSubView in activityPageView.subviews {
            oldSubView.removeFromSuperview()
        }
        
        for i in 0 ..< nbPages {
            let panel: ChatActivityPanel = Bundle.main.loadNibNamed("ChatActivityPanel", owner: self, options: nil)?.first as! ChatActivityPanel
            
            activityPageView.addSubview(panel)
            activityPanels.append(panel)
            
            panel.translatesAutoresizingMaskIntoConstraints = false
            panel.centerXAnchor.constraint(equalTo: self.activityPageView.centerXAnchor).isActive = true
            panel.centerYAnchor.constraint(equalTo: self.activityPageView.centerYAnchor).isActive = true
            
            let startIndex: Int = i * nbItemsEachPage
            let endIndex: Int = min((i + 1) * nbItemsEachPage - 1, savedActivitiesData.count - 1)
            
            panel.updateItems(items: savedActivitiesData, start: startIndex, end: endIndex, target: self)
            panel.alpha = i == 0 ? 1 : 0
        }
        
        self.currentPage = 0
        
        activityPageControl.numberOfPages = nbPages
        activityPageControl.currentPage = self.currentPage
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
    
    @objc func onAddActivitiyTap(_ sender: UITapGestureRecognizer) {
        self.activityTmpAnswer.removeAll()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ActivityViewController") as! ActivityViewController
        
        vc.chatViewController = self
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onActivityDone(_ sender: Any) {
        var tmpAnswer = ""
        for i in 0 ..< self.activityTmpAnswer.count {
            if i > 0 {
                tmpAnswer += ", "
            }
            
            tmpAnswer += self.savedActivitiesData[self.activityTmpAnswer[i]].text
        }
        
        answer.append(tmpAnswer)
        self.postAnswer(questionId: curQuestion, answerId: self.activityTmpAnswer, answer: nil)
        self.nextQuestion()
    }
    
    @objc func onEmotionTap(_ sender: UITapGestureRecognizer) {
        answer.append(EMOTIONS[sender.view?.tag ?? 0])
        self.postAnswer(questionId: curQuestion, answerId: [sender.view?.tag ?? 0], answer: nil)
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
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            
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
    
    // Activity Panel
    private let NB_ITEMS_EACH_LINE: Int = 5
    private let NB_LINES_EACH_PAGE: Int = 2
    public var savedActivitiesData: [SavedActivityData] = []
    private var activityPanels: [ChatActivityPanel] = []
    
    private var nbPages: Int = 1
    
    @IBOutlet var leftSwipeRecognizer: UISwipeGestureRecognizer!
    @IBAction func onLeftSwipe(_ sender: Any) {
        currentPage = min(currentPage + 1, activityPageControl.numberOfPages - 1)
        self.setPage()
    }
    
    
    @IBOutlet var rightSwipeRecognizer: UISwipeGestureRecognizer!
    @IBAction func onRightSwipe(_ sender: Any) {
        currentPage = max(currentPage - 1, 0)
        self.setPage()
    }
    
    func setPage() {
        self.activityPageControl.currentPage = currentPage
        self.enableSwipe(value: false)
                
        for i in 0 ..< self.activityPanels.count {
            if i == currentPage {
                if self.activityPanels[i].alpha == 0 {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.activityPanels[i].alpha = 1
                    }, completion: { (done: Bool) in
                        self.enableSwipe(value: true)
                    })
                }
                else {
                    self.enableSwipe(value: true)
                }
            }
            else {
                self.activityPanels[i].alpha = 0.0
            }
        }
    }
    
    func enableSwipe(value: Bool) {
        rightSwipeRecognizer.isEnabled = value
        leftSwipeRecognizer.isEnabled = value
    }
    
    var currentPage: Int = 0
    
    // Data get/request
    public func getAnswers() {
        let defaults = UserDefaults.standard
        let userId = defaults.integer(forKey: "loggedUserId")
        let apiUrl: String = Constants.url + Constants.apiPrefix + "/monster/answer/" + String(userId)
        
        print ("API URL : ", apiUrl)
        
        guard let url = URL(string: apiUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, resonse, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let jsonData = try JSONDecoder().decode([ChatAnswerData].self, from: data)
                
                // Get back to the main queue
                DispatchQueue.main.async {
                    self.curQuestion = 0
                    self.answer = []
                    
                    print ("DATA : ", jsonData)
                    
                    for i in 0 ..< jsonData.count {
                        if jsonData[i].monster_id == self.curQuestion && self.isToday(dateStr: jsonData[i].created_at) {
                            if self.curQuestion == 0 {
                                self.answer.append(self.EMOTIONS[jsonData[i].answer_id ?? 0])
                            }
                            else if self.curQuestion == 1 {
                                self.answer.append(self.savedActivitiesData[jsonData[i].answer_id ?? 0].text)
                            }
                            else {
                                self.answer.append(jsonData[i].answer ?? "")
                            }
                            
                            self.nextQuestion()
                            
                            if (self.answer.count >= self.question.count) {
                                self.hideUserInput()
                                break
                            }
                        }
                    }
                    
                    print ("ANSWER : ", self.answer)
                    if self.answer.count == 0 {
                        self.showUserInput()
                    }
                }
            } catch let jsonError {
                DispatchQueue.main.async {
                    self.showUserInput()
                }
                
                print(jsonError)
            }
        }.resume()
    }
    
    public func postAnswer(questionId: Int, answerId: [Int]?, answer: String?) {
        let apiUrl: String = Constants.url + Constants.apiPrefix + "/monster/answer"
        guard let updateUrl = URL(string: apiUrl) else { return }
        
        let defaults = UserDefaults.standard
        let userId = defaults.integer(forKey: "loggedUserId")
        
        var updateData: [String: Any] = [
            "user_id": userId,
            "monster_id": questionId
        ]
        
        if answerId != nil {
            updateData["answer_id"] = answerId![0]
        }
        else {
            updateData["answer_id"] = ""
        }
        
        if answer != nil {
            updateData["answer"] = answer
        }
        else {
            updateData["answer"] = ""
        }
        
        print ("UPDATE DATA : ", updateData)
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: updateData, options: []) else {
            return
        }
        
        var updateUrlRequest = URLRequest(url: updateUrl)
        updateUrlRequest.httpMethod = "POST"
        updateUrlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        updateUrlRequest.httpBody = httpBody
        
        URLSession.shared.dataTask(with: updateUrlRequest) { (data, response, error)
            in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
//            do {
//                print("SAVE ANSWER DONE ", String(data: data, encoding: .utf8))

//                let updateResult = try JSONDecoder().decode(PostAnswerData.self, from: data)
                
//
//                //Get back to the main queue
//                DispatchQueue.main.async {
//                    self.updateContent(dayId: updateResult.day_id!, name: self.dayName, type: ThirtyDayEnum.PassedDay.rawValue)
//                }
//            } catch let jsonError {
//                print(jsonError)
//            }
        }.resume()
    }
    
    public func isToday(dateStr: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = dateFormatter.date(from: dateStr) else {
            return false
        }
        
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        let curDate = Date()
        let curYear = calendar.component(.year, from: curDate)
        let curMonth = calendar.component(.month, from: curDate)
        let curDay = calendar.component(.day, from: curDate)
        
        return year == curYear && month == curMonth && day == curDay
    }
}
