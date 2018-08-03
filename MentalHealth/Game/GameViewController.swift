//
//  GameViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 08/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    /*
     * Variables for level view
     */
    
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
        
        print ("Level = ", level)
        
        levelView.isHidden = true
        questionView.isHidden = false
    }
    
    var levels = ["Level 1", "Level 2", "Level 3",
                  "Level 4", "Level 5", "Level 6",
                  "Level 7", "Level 8", "Level 9"];
    var currentLevel = 3
    
    /*
     * Variables for question view
     */
    
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var questionBg: UIImageView!
    @IBOutlet weak var backQuestionButton: UIButton!
    @IBOutlet weak var nextQuestionButton: UIButton!
    @IBAction func backQuestionButtonClicked(_ sender: Any) {
        if (currentQuestion == 0) {
            questionView.isHidden = true
            levelView.isHidden = false
        }
        else {
            currentQuestion -= 1
        }
    }
    
    @IBAction func nextQuestionButtonClicked(_ sender: Any) {
        if (currentQuestion == nbQuestions - 1) {
            questionView.isHidden = true
        }
        else {
            currentQuestion += 1
        }
    }
    
    @objc private func onQuestionTap(_ sender: UITapGestureRecognizer) {
        print("YOOO")
        questionView.isHidden = true
        detailView.isHidden = false
    }
    
    var answerPanels: [AnswerPanel] = []
    
    var currentQuestion = 0
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupLevelView()
        setupDetailView()
        setupQuestionView()
        
        levelTableView.reloadData()
    }
    
    // The method returning size of the list
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levels.count
    }
    
    // The method returning each cell of the list
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "levelButton", for: indexPath) as! LevelButton
        
        // Displaying values
        cell.backgroundColor = UIColor.clear
        cell.levelImage.isHighlighted = indexPath.row < currentLevel
        cell.levelText.text = levels[indexPath.row]
        cell.tag = indexPath.row
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(GameViewController.onLevelTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        
        cell.isUserInteractionEnabled = indexPath.row < currentLevel
        cell.addGestureRecognizer(tapGesture)
        
        return cell
    }
    
    private func setupLevelView() {
        let viewFrameW = self.view.bounds.width
        let viewFrameH = self.view.bounds.height
        let popupImageW = popupBg.image?.size.width
        let popupImageH = popupBg.image?.size.height
        
        backButton.frame.origin = CGPoint(
            x: (viewFrameW - backButton.frame.width) / 2,
            y: (viewFrameH + popupImageH! - backButton.frame.height) / 2 - 10
        )
        
        levelTableView.frame = CGRect(
            x: viewFrameW * 0.5 - popupImageW! * 0.45,
            y: viewFrameH * 0.5 - popupImageH! * 0.4,
            width: popupImageW! * 0.9,
            height: popupImageH! * 0.8
        )
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
    
    private func setupQuestionView() {
        let viewFrameW = self.view.bounds.width
        let viewFrameH = self.view.bounds.height
        
        questionBg.frame.origin = CGPoint(
            x: (viewFrameW - questionBg.frame.width) / 2,
            y: (viewFrameH - questionBg.frame.height) / 2 - 160
        )
        
        answerPanels = createAnswers()
        for i in 0 ..< answerPanels.count {
            answerPanels[i].frame.origin = CGPoint(
                x: (viewFrameW - answerPanels[i].frame.width) / 2 - 10,
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
