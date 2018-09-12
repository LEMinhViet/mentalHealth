//
//  AnswerPanel.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 09/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class AnswerPanel: UIView {

    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var answerBg: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    public func updateAnswer(_ chooseText: String) {
        resultImage.alpha = 0
        answerLabel.text = chooseText;
    }
    
    public func setRightAnswer() {
        resultImage.alpha = 1
        resultImage.isHighlighted = false
    }
    
    public func setWrongAnswer() {
        resultImage.alpha = 1
        resultImage.isHighlighted = true
    }
}
