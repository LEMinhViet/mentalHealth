//
//  NewsByDayCell.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 12/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class NewsCell: UIView {

    @IBOutlet weak var featuredImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    @IBAction func onClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewsDetailViewController") as! NewsDetailViewController
        vc.setNewsId(value: self.newsId)
        
        if (self.navigationController != nil) {
            self.navigationController.pushViewController(vc, animated: true)
        }
    }
    
    var navigationController: UINavigationController!
    
    public func setNavigation(navigation: UINavigationController) {
        self.navigationController = navigation
    }
    
    var newsId: String = ""
    
    public func setNewsId(newsId: String) {
        self.newsId = newsId
    }
    
    var featuredImageName: String = ""
    
    public func setFeaturedImageName(value: String) {
        self.featuredImageName = value
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
