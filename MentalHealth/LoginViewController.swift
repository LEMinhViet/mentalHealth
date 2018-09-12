//
//  LoginViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 03/08/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

struct LoginResult: Codable {
    let message: String
    let user_id: Int?
}

class LoginViewController: UIViewController {

    @IBOutlet weak var slide1stPanel: UIStackView!
    @IBOutlet weak var slide2ndPanel: UIStackView!
    @IBOutlet weak var slide3rdPanel: UIStackView!
    
    @IBOutlet weak var loginPanel: UIStackView!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var userInput: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var paginationControl: UIPageControl!
    
    @IBOutlet var rightSwipeRecognizer: UISwipeGestureRecognizer!
    @IBAction func rightSwipe(_ sender: Any) {
        currentPage = max(currentPage - 1, 0)
        self.setPage()
    }
    
    @IBOutlet var leftSwipeRecognizer: UISwipeGestureRecognizer!
    @IBAction func leftSwipe(_ sender: Any) {
        currentPage = min(currentPage + 1, paginationControl.numberOfPages - 1)
        self.setPage()
    }
    
    func setPage() {
        self.paginationControl.currentPage = currentPage
        self.enableSwipe(value: false)
        
        let pages = [slide1stPanel, slide2ndPanel, slide3rdPanel, loginPanel]
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
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loginButton.layer.cornerRadius = loginButton.frame.height * 0.5
        
        // Looks for single or multiple taps.
        let dismisTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        
        view.addGestureRecognizer(dismisTap)
    }
    
    // Calls this function when the tap is recognized.
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogin(_ sender: Any) {
        loginButton.isEnabled = false
        
        let apiUrl: String = Constants.url + Constants.apiPrefix + "/login"
        guard let loginUrl = URL(string: apiUrl) else { return }
        
        let defaults = UserDefaults.standard
        var deviceId = defaults.string(forKey: "loggedDeviceId") ?? ""
        
        if deviceId == "" {
            deviceId = (UIDevice.current.identifierForVendor?.uuidString)!
            defaults.set(deviceId, forKey: "loggedDeviceId")
        }
        
        let loginData: [String: Any] = [
            "account": userInput.text ?? "",
            "password": passwordInput.text ?? "",
            "device_id": deviceId
        ]
        
        print ("LOGIN :", loginData)
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: loginData, options: []) else {
            return
        }

        var loginUrlRequest = URLRequest(url: loginUrl)
        loginUrlRequest.httpMethod = "POST"
        loginUrlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        loginUrlRequest.httpBody = httpBody

        URLSession.shared.dataTask(with: loginUrlRequest) { (data, response, error)
            in
            if error != nil {
                print(error!.localizedDescription)
            }

            guard let data = data else { return }
            
            do {
                let loginResult = try JSONDecoder().decode(LoginResult.self, from: data)

                //Get back to the main queue
                DispatchQueue.main.async {
                    if loginResult.message == "success" {
                        self.loginSucceed(userId: loginResult.user_id!)
                    }
                    else {
                        self.loginFailed()
                    }
                    
                    self.loginButton.isEnabled = true
                }
            } catch let jsonError {
                print(jsonError)
                DispatchQueue.main.async {
                    self.loginFailed()
                    
                    self.loginButton.isEnabled = true
                }
            }
        }.resume()
    }
    
    func loginSucceed(userId: Int) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "isUserLoggedIn")
        defaults.set(userId, forKey: "loggedUserId")
        defaults.synchronize()
        
        self.toMenu()
        self.logTime(action: Constants.TO_FOREGROUND)
    }
    
    func loginFailed() {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "isUserLoggedIn")
        defaults.synchronize()
    }
    
    func toMenu() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NavigationController") as UIViewController
        present(vc, animated: false, completion: nil)
    }
    
    func logTime(action: Int) {
        let apiUrl: String = Constants.url + Constants.apiPrefix + "/logtime"
        guard let loginUrl = URL(string: apiUrl) else { return }
        
        let defaults = UserDefaults.standard
        let userId = defaults.integer(forKey: "loggedUserId")
        var deviceId = defaults.string(forKey: "loggedDeviceId") ?? ""
        
        if deviceId == "" {
            deviceId = (UIDevice.current.identifierForVendor?.uuidString)!
            defaults.set(deviceId, forKey: "loggedDeviceId")
        }
        
        let logData: [String: Any] = [
            "user_id": userId,
            "action": action,
            "device_id": deviceId
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: logData, options: []) else {
            return
        }
        
        var logUrlRequest = URLRequest(url: loginUrl)
        logUrlRequest.httpMethod = "POST"
        logUrlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        logUrlRequest.httpBody = httpBody
        
        URLSession.shared.dataTask(with: logUrlRequest) { (data, response, error)
            in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let logResult = try JSONDecoder().decode(LogResult.self, from: data)
                
                //Get back to the main queue
                DispatchQueue.main.async {
                    print("LOG ", action, logResult)
                    if logResult.message == "success" {
                        
                    }
                    else {
                        
                    }
                }
            } catch let jsonError {
                print(jsonError)
                DispatchQueue.main.async {
                    
                }
            }
        }.resume()
    }
}
