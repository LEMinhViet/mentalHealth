//
//  InfoViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 30/08/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class InfoViewController: BaseViewController {

    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    
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
