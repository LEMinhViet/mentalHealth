//
//  GameViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 08/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

struct AllLevels: Codable {
    let per_page: Int
    let current_page: Int
    let next_page_url: String?
    let prev_page_url: String?
    let from: Int
    let to: Int
    let data: [LevelData]
    
    init() {
        per_page = 0
        current_page = 0
        next_page_url = nil
        prev_page_url = nil
        from = 0
        to = 0
        data = []
    }
}

struct LevelData: Codable {
    let id: Int
    let name: String
    let created_at: String
    let updated_at: String
}

struct LevelQuestions: Codable {
    let per_page: Int
    let current_page: Int
    let next_page_url: String?
    let prev_page_url: String?
    let from: Int
    let to: Int
    let data: [OneQuestion]
    
    init() {
        per_page = 0
        current_page = 0
        next_page_url = nil
        prev_page_url = nil
        from = 0
        to = 0
        data = []
    }
}

struct OneQuestion: Codable {
    let id: Int
    let level_id: String
    let content: String
    let choose1: String
    let choose2: String
    let choose3: String
    let choose4: String
    let answer: String
    let created_at: String?
    let updated_at: String?
}

class GameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    /*
     * Variables for level view
     */
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var levelView: UIView!
    @IBOutlet weak var popupBg: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var levelTableView: UITableView!
    @IBAction func backButtonClicked(_ sender: Any) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: ViewController.self) {
                self.navigationController!.popToViewController(controller, animated: false)
                break
            }
        }
    }
    
    @objc private func onLevelTap(_ sender: UITapGestureRecognizer) {
        let level: Int = (sender.view?.tag)!
        self.updateLevel(level)
        
        levelView.isHidden = true
    }
    
    var currentLevel = 0
    
    /*
     * Variables for question view
     */
    
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var questionBg: UIImageView!
    @IBOutlet weak var backQuestionButton: UIButton!
    @IBOutlet weak var nextQuestionButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBAction func backQuestionButtonClicked(_ sender: Any) {
        if (currentQuestion == 0) {
            questionView.isHidden = true
            levelView.isHidden = false
        }
        else {
            currentQuestion -= 1
            isAnswered = false
        }
        
        self.updateQuestion()
    }
    
    @IBAction func nextQuestionButtonClicked(_ sender: Any) {
        if (!isAnswered) {
            self.showQuestionResult(nil)
        }
        else {
            if (currentQuestion == nbQuestions - 1) {
                if (currentLevel + 1 < self.levelsData.data.count) {
                    currentLevel += 1
                    
                    let defaults = UserDefaults.standard
                    defaults.set(currentLevel, forKey: "currentQuestionLevel")
                    
                    levelTableView.reloadData()
                }
                
                questionView.isHidden = true
                levelView.isHidden = false
            }
            else {
                currentQuestion += 1
                isAnswered = false
            }
            
            self.updateQuestion()
        }
    }
    
    @objc private func onQuestionTap(_ sender: UITapGestureRecognizer) {
        self.showQuestionResult(sender.view)
    }
    
    func showQuestionResult(_ selected: UIView?) {
        if (!isAnswered) {
            isAnswered = true
            
            let currentQuestionData = self.levelQuestionsData.data[self.currentQuestion]
            for i in 0 ..< answerPanels.count {
                if (String(i + 1) == currentQuestionData.answer) {
                    answerPanels[i].setRightAnswer()
                }
                else if (answerPanels[i] == selected) {
                    answerPanels[i].setWrongAnswer()
                }
            }
        }
        else {
            questionView.isHidden = true
            detailView.isHidden = false
        }
    }
    
    var answerPanels: [AnswerPanel] = []
    
    var currentQuestion = 0
    var isAnswered = false
    var nbQuestions = 5
    
    /*
     * Variables for detail view
     */
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var popupDetailBg: UIImageView!
    @IBOutlet weak var backDetailButton: UIButton!
    @IBOutlet weak var detailText: UILabel!
    @IBAction func backDetailButtonClicked(_ sender: Any) {
        detailView.isHidden = true
        questionView.isHidden = false
    }
    
    /*
     * Variables for question api
     */
    
    let apiUrl = Constants.url + Constants.apiPrefix + "/levels"
    var levelsData = AllLevels()
    
    let questionUrl = Constants.url + Constants.apiPrefix + "/questions"
    var levelQuestionsData = LevelQuestions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        currentLevel = defaults.integer(forKey: "currentQuestionLevel")
        
        // Do any additional setup after loading the view.
        guard let url = URL(string: apiUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, resonse, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let jsonData = try JSONDecoder().decode(AllLevels.self, from: data)
                
                //Get back to the main queue
                DispatchQueue.main.async {
                    self.levelsData = jsonData
                    self.levelTableView.reloadData()
                }
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
        
        self.setupLevelView()
        self.setupDetailView()
        self.setupQuestionView()
    }
    
    // The method returning size of the list
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levelsData.data.count
    }
    
    // The method returning each cell of the list
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "levelButton", for: indexPath) as! LevelButton
        
        // Displaying values
        cell.backgroundColor = UIColor.clear
        cell.levelImage.isHighlighted = indexPath.row <= currentLevel
        cell.levelText.text = levelsData.data[indexPath.row].name
        cell.tag = levelsData.data[indexPath.row].id
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(GameViewController.onLevelTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        
        cell.isUserInteractionEnabled = indexPath.row <= currentLevel
        cell.addGestureRecognizer(tapGesture)
        
        return cell
    }
    
    private func setupLevelView() {
        let viewFrameW = self.view.bounds.width
        let viewFrameH = self.view.bounds.height
        let popupImageW = popupBg.image?.size.width
        let popupImageH = popupBg.image?.size.height
        
        let offsetY: CGFloat = -30.0
        
        popupBg.frame = CGRect(
            x: (viewFrameW - popupImageW!) / 2,
            y: (viewFrameH - popupImageH!) / 2 + offsetY,
            width: popupImageW!,
            height: popupImageH!
        )
        
        backButton.frame.origin = CGPoint(
            x: (viewFrameW - backButton.frame.width) / 2,
            y: (viewFrameH + popupImageH! - backButton.frame.height) / 2 + offsetY - 10
        )
        
        levelTableView.frame = CGRect(
            x: viewFrameW * 0.5 - popupImageW! * 0.45,
            y: viewFrameH * 0.5 - popupImageH! * 0.4 + offsetY + 10,
            width: popupImageW! * 0.9,
            height: popupImageH! * 0.8
        )
    }
    
    func updateLevel(_ level: Int) {
        let levelQuestionUrl = questionUrl + "/" + String(level + 1)
        guard let url = URL(string: levelQuestionUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, resonse, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let jsonData = try JSONDecoder().decode(LevelQuestions.self, from: data)
                
                //Get back to the main queue
                DispatchQueue.main.async {
                    self.levelView.isHidden = true
                    self.levelQuestionsData = jsonData
                    self.currentQuestion = 0
                    self.isAnswered = false
                    self.nbQuestions = self.levelQuestionsData.data.count
                    self.updateQuestion()
                    
                    self.questionView.isHidden = false
                }
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
    }
    
    private func setupDetailView() {
        let viewFrameW = self.view.bounds.width
        let viewFrameH = self.view.bounds.height
        let popupImageW = popupDetailBg.image?.size.width
        let popupImageH = popupDetailBg.image?.size.height
        
        backDetailButton.frame.origin = CGPoint(
            x: (viewFrameW - backDetailButton.frame.width) / 2,
            y: (viewFrameH + popupImageH! - backDetailButton.frame.height) / 2 - 10
        )
        
        detailText.frame = CGRect(
            x: viewFrameW * 0.5 - popupImageW! * 0.4,
            y: viewFrameH * 0.5 - popupImageH! * 0.4,
            width: popupImageW! * 0.8,
            height: popupImageH! * 0.8
        )
        
        detailView.isHidden = true
    }
    
    private func updateDetail() {
        // detailText.text = ""
        detailText.sizeToFit()
    }
    
    private func setupQuestionView() {
        let viewFrameW = self.view.bounds.width
        let viewFrameH = self.view.bounds.height
        
        questionBg.frame.origin = CGPoint(
            x: (viewFrameW - questionBg.frame.width) / 2,
            y: (viewFrameH - questionBg.frame.height) / 2 - 160
        )
        
        questionLabel.frame.size = CGSize(width: 265, height: 130)
        questionLabel.frame.origin = CGPoint(
            x: (viewFrameW - questionLabel.frame.width) / 2,
            y: (viewFrameH - questionLabel.frame.height) / 2 - 130
        )
        
        answerPanels = createAnswers()
        for i in 0 ..< answerPanels.count {
            answerPanels[i].frame.origin = CGPoint(
                x: (viewFrameW - answerPanels[i].frame.width) / 2,
                y: questionBg.frame.origin.y + questionBg.frame.height + 20 +  answerPanels[i].frame.height * CGFloat(i)
            )
            
            let answerGesture = UITapGestureRecognizer(target: self, action: #selector(GameViewController.onQuestionTap(_:)))
            answerGesture.numberOfTapsRequired = 1
            answerGesture.numberOfTouchesRequired = 1
            
            questionView.addSubview(answerPanels[i])
            
            answerPanels[i].isUserInteractionEnabled = true
            answerPanels[i].addGestureRecognizer(answerGesture)
        }
        
        backQuestionButton.frame.origin = CGPoint(
            x: viewFrameW / 2 - backQuestionButton.frame.width - 20,
            y: viewFrameH / 2 + 250
        )
        
        nextQuestionButton.frame.origin = CGPoint(
            x: viewFrameW / 2 + 20,
            y: viewFrameH / 2 + 250
        )
        
        questionView.isHidden = true
    }
    
    private func updateQuestion() {
        let currentQuestionData = self.levelQuestionsData.data[self.currentQuestion]
        
        questionLabel.frame.size = CGSize(width: 265, height: 130)
        questionLabel.text = currentQuestionData.content
        questionLabel.sizeToFit()
        
        answerPanels[0].updateAnswer(currentQuestionData.choose1)
        answerPanels[1].updateAnswer(currentQuestionData.choose2)
        answerPanels[2].updateAnswer(currentQuestionData.choose3)
        answerPanels[3].updateAnswer(currentQuestionData.choose4)
        
        self.updateDetail()
    }
    
    func createAnswers() -> [AnswerPanel] {
        let answer_00: AnswerPanel = Bundle.main.loadNibNamed("AnswerPanel", owner: self, options: nil)?.first as! AnswerPanel
        answer_00.answerBg.image = UIImage(named: "img_a.png")
        
        let answer_01: AnswerPanel = Bundle.main.loadNibNamed("AnswerPanel", owner: self, options: nil)?.first as! AnswerPanel
        answer_01.answerBg.image = UIImage(named: "img_b.png")
        
        let answer_02: AnswerPanel = Bundle.main.loadNibNamed("AnswerPanel", owner: self, options: nil)?.first as! AnswerPanel
        answer_02.answerBg.image = UIImage(named: "img_c.png")
        
        let answer_03: AnswerPanel = Bundle.main.loadNibNamed("AnswerPanel", owner: self, options: nil)?.first as! AnswerPanel
        answer_03.answerBg.image = UIImage(named: "img_d.png")
        
        return [answer_00, answer_01, answer_02, answer_03]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
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
