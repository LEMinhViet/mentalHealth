//
//  TutorialViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 03/09/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class TutorialViewController: BaseViewController {

    @IBOutlet weak var slide1stPanel: UIStackView!
    @IBOutlet weak var slide3rdPanel: UIStackView!
    @IBOutlet weak var slide2ndPanel: UIStackView!
    @IBOutlet weak var paginationControl: UIPageControl!
    
    @IBOutlet var leftSwipeRecognizer: UISwipeGestureRecognizer!
    @IBAction func leftSwipe(_ sender: Any) {
        currentPage = min(currentPage + 1, paginationControl.numberOfPages - 1)
        self.setPage()
    }
    
    @IBOutlet var rightSwipeRecognizer: UISwipeGestureRecognizer!
    @IBAction func rightSwipe(_ sender: Any) {
        currentPage = max(currentPage - 1, 0)
        self.setPage()
    }
    
    func setPage() {
        self.paginationControl.currentPage = currentPage
        self.enableSwipe(value: false)
        
        let pages = [slide1stPanel, slide2ndPanel, slide3rdPanel]
        for i in 0 ..< pages.count {
            if i == currentPage {
                if pages[i]?.alpha == 0 {
                    UIView.animate(withDuration: 0.5, animations: {
                        pages[i]?.alpha = 1
                    }, completion: { (done: Bool) in
                        self.enableSwipe(value: true)
                    })
                }
                else {
                    self.enableSwipe(value: true)
                }
            }
            else {
                pages[i]?.alpha = 0.0
            }
        }
    }
    
    func enableSwipe(value: Bool) {
        rightSwipeRecognizer.isEnabled = value
        leftSwipeRecognizer.isEnabled = value
    }
    
    var currentPage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)

        // Do any additional setup after loading the view.
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
