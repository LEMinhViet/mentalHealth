//
//  FeaturedSlide.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 08/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class FeaturedSlide: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
        
    @IBAction func onClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewsDetailViewController") as! NewsDetailViewController
        
        if (self.navigationController != nil) {
            self.navigationController.pushViewController(vc, animated: true)
        }
    }
    
    var navigationController: UINavigationController!
    
    public func setNavigation(navigation: UINavigationController) {
        self.navigationController = navigation
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
