//
//  BaseViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 08/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    public var menuButton: UIButton?
    
    func viewDidLoad(withMenu: Bool = true) {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isTranslucent = false

        setupNavigationBarItems(withMenu: withMenu)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupNavigationBarItems(withMenu: Bool) {
        if (withMenu) {
            self.menuButton = UIButton(type: .system)
            self.menuButton?.setImage(UIImage(named: "ic_menu.png"), for: .normal)
            self.menuButton?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.menuButton!)
        }
        
        let sosButton = UIButton(type: .system)
        sosButton.setImage(UIImage(named: "ic_sos.png"), for: .normal)
        sosButton.frame = CGRect(x: 0, y: 0, width: 24, height: 30)
        sosButton.addTarget(self, action: #selector(sosPush), for: .touchUpInside)
        
        let homeButton = UIButton(type: .system)
        homeButton.setImage(UIImage(named: "ic_home.png"), for: .normal)
        homeButton.frame = CGRect(x: 0, y: 0, width: 24, height: 30)
        homeButton.addTarget(self, action: #selector(homePush), for: .touchUpInside)
        
        let separator = UIView()
        separator.frame = CGRect(x: 0, y: 10, width: 1, height: 20)
        separator.backgroundColor = UIColor.lightGray
        
        let searchButton = UIButton(type: .system)
        searchButton.setImage(UIImage(named: "ic_search.png"), for: .normal)
        searchButton.frame = CGRect(x: 0, y: 0, width: 24, height: 30)
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(customView: searchButton),
            UIBarButtonItem(customView: separator),
            UIBarButtonItem(customView: homeButton),
            UIBarButtonItem(customView: sosButton)
        ]
                
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "img_back.png"), for: .normal)
        backButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc private func sosPush() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SOSViewController") as UIViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func homePush() {
        self.dismiss(animated: true, completion: {})
        self.navigationController?.popToRootViewController(animated: true)
    }
}
