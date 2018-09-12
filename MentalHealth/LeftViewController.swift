//
//  LeftViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 25/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

protocol ShowLeftSubPageDelegate: class {
    func hideLeftPage()
}

class LeftViewController: UIViewController {
    
    weak var delegate: ShowLeftSubPageDelegate?
   
    @IBAction func aboutUsClicked(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "InfoViewController") as! InfoViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
        delegate?.hideLeftPage()
    }
    
    @IBAction func helpClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
        delegate?.hideLeftPage()
    }
    
    @IBAction func favoritesClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FavoritesViewController") as! FavoritesViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
        delegate?.hideLeftPage()
    }
    
    @IBAction func notificationClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
        delegate?.hideLeftPage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
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
