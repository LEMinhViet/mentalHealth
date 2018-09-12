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
    private var backButton: UIButton?
    
    private var sosButton: UIButton?
    private var homeButton: UIButton?
    private var separator: UIView?
    private var searchButton: UIButton?
    
    private var spinnerView: UIView?
    
    private var withMenu: Bool = true
    private var withItems: Bool = true
    
    func viewDidLoad(withMenu: Bool = true, withItems: Bool = true) {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isTranslucent = false

        self.withMenu = withMenu
        self.withItems = withItems
        
        setupNavigationBarItems(withMenu: withMenu, withItems: withItems)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupNavigationBarItems(withMenu: Bool, withItems: Bool) {
        if (withMenu) {
            menuButton = UIButton(type: .system)
            menuButton?.setImage(UIImage(named: "ic_menu.png"), for: .normal)
            menuButton?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton!)
        }
        
        if (withItems) {
            sosButton = UIButton(type: .system)
            sosButton?.setImage(UIImage(named: "ic_sos.png"), for: .normal)
            sosButton?.frame = CGRect(x: 0, y: 0, width: 24, height: 30)
            sosButton?.addTarget(self, action: #selector(sosPush), for: .touchUpInside)
            
            homeButton = UIButton(type: .system)
            homeButton?.setImage(UIImage(named: "ic_home.png"), for: .normal)
            homeButton?.frame = CGRect(x: 0, y: 0, width: 24, height: 30)
            homeButton?.addTarget(self, action: #selector(homePush), for: .touchUpInside)
            
            separator = UIView()
            separator?.frame = CGRect(x: 0, y: 10, width: 1, height: 20)
            separator?.backgroundColor = UIColor.lightGray
            
            searchButton = UIButton(type: .system)
            searchButton?.setImage(UIImage(named: "ic_search.png"), for: .normal)
            searchButton?.frame = CGRect(x: 0, y: 0, width: 24, height: 30)
            searchButton?.addTarget(self, action: #selector(searchPush), for: .touchUpInside)
            
            self.navigationItem.rightBarButtonItems = [
                UIBarButtonItem(customView: searchButton!),
                UIBarButtonItem(customView: separator!),
                UIBarButtonItem(customView: homeButton!),
                UIBarButtonItem(customView: sosButton!)
            ]
        }
                
        backButton = UIButton(type: .system)
        backButton?.setImage(UIImage(named: "img_back.png"), for: .normal)
        backButton?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(customView: backButton!)
    }

    @objc private func searchPush() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func sosPush() {
        if self is SOSViewController {

        }
        else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SOSViewController") as UIViewController
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func homePush() {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: ViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    func displaySpinner(onView : UIView) {
        enableButtons(false)
        
        if (spinnerView == nil) {
            spinnerView = UIView.init(frame: onView.bounds)
            spinnerView?.backgroundColor = UIColor.init(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
            let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
            ai.startAnimating()
            ai.center = (spinnerView?.center)!
            
            DispatchQueue.main.async {
                if (self.spinnerView != nil) {
                    self.spinnerView?.addSubview(ai)
                    onView.addSubview(self.spinnerView!)
                }
            }
        }
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            self.enableButtons(true)
            
            self.spinnerView?.removeFromSuperview()
            self.spinnerView = nil
        }
    }
    
    func enableButtons(_ value: Bool) {
        if self.withMenu {
            menuButton?.isEnabled = value
        }
        
        if self.withItems {
            sosButton?.isEnabled = value
            homeButton?.isEnabled = value
            searchButton?.isEnabled = value
        }
        
        self.navigationItem.hidesBackButton = !value
    }
}
