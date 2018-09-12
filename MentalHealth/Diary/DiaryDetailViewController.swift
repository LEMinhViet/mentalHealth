//
//  DiaryDetailViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 20/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class DiaryDetailViewController: BaseViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    
    var dateText: String = ""
    var titleText: String = ""
    var contentText: String = ""
    var diaryIndex: Int = 0
    var diaryData: [DiaryData] = []
    
    var isRemoved: Bool = false
    
    func setDateText(value: String) {
        dateText = value
    }
    
    func setTitleText(value: String) {
        titleText = value
    }
    
    func setContentText(value: String) {
        contentText = value
    }
    
    func setDiaryIndex(index: Int) {
        self.diaryIndex = index
    }
    
    func setDiaryData(data: [DiaryData]) {
        self.diaryData = data
    }
    
    @IBAction func deleteClicked(_ sender: Any) {
        isRemoved = true
        
        diaryData.remove(at: diaryIndex)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(diaryData), forKey: "diaryData")
        
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)

        // Do any additional setup after loading the view.
        dateLabel.text = dateText
        titleLabel.text = titleText
        contentTextView.text = contentText
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (!isRemoved) {
            contentText = contentTextView.text
            diaryData[diaryIndex].content = contentText

            UserDefaults.standard.set(try? PropertyListEncoder().encode(diaryData), forKey: "diaryData")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
