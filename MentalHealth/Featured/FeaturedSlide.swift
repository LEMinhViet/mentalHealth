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
    @IBOutlet weak var titleBackground: UIView!
    
    public var newsId: Int = -1
    
    @IBAction func onClicked(_ sender: Any) {
        if newsId != -1 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "NewsDetailViewController") as! NewsDetailViewController
            vc.newsId = String(newsId)
            if (self.navigationController != nil) {
                self.navigationController.pushViewController(vc, animated: true)
            }
        }
    }
    
    var navigationController: UINavigationController!
    
    public func setNavigation(navigation: UINavigationController) {
        self.navigationController = navigation
    }
}
