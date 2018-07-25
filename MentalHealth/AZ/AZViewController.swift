//
//  AZViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 12/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class AZViewController: BaseViewController {
    
    let titles: [String] = ["img_roiloantramcam.png", "img_roiloanluongcuc.png", "img_roiloanloau.png"]
    
    var images: [UIImageView] = []

    @IBOutlet weak var azStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Từ A - Z"
        
        for i in 0 ..< titles.count {
            let imageView = UIImageView(image: UIImage(named: titles[i]))
            images.append(imageView)
            images[i].contentMode = .top
            images[i].tag = i;
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AZViewController.onImageTap(_:)))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            
            images[i].isUserInteractionEnabled = true
            images[i].addGestureRecognizer(tapGesture)
            
            azStackView.addArrangedSubview(images[i])
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func onImageTap(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AZDetailViewController") as UIViewController
        navigationController?.pushViewController(vc, animated: true)
        
        
        print(titles[(sender.view?.tag)!])
    }
}
