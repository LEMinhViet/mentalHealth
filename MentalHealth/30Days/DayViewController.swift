//
//  DayViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 11/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class DayViewController: BaseViewController {

    public var dayIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Ngày thứ " + String(dayIndex + 1)
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
