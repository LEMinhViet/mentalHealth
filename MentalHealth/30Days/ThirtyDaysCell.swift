//
//  ThirtyDaysCell.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 11/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

struct UpdateResult: Codable {
    let user_id: Int?
    let day_id: Int?
    let updated_at: String?
    let created_at: String?
    let id: Int?
    let message: String?
}

class ThirtyDaysCell: UITableViewCell {
    
    enum ThirtyDayEnum: Int {
        case LockedDay = 0
        case PassedDay = 1
        case CurrentDay = 2
    };

    @IBOutlet weak var bgButton: UIButton!
    @IBOutlet weak var dayLabel: UILabel!
    @IBAction func dayClicked(_ sender: Any) {
        if (type == ThirtyDayEnum.LockedDay.rawValue) {
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DayViewController") as! DayViewController
        
        vc.dayId = dayId
        vc.dayName = dayName
        
        if (self.navigationController != nil) {
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        // Update read state
        if (type == ThirtyDayEnum.CurrentDay.rawValue) {
            self.updateReadState(dayId: dayId)
        }
    }
    
    public func updateReadState(dayId: Int) {
        let apiUrl: String = Constants.url + Constants.apiPrefix + "/update_day"
        guard let updateUrl = URL(string: apiUrl) else { return }
        
        let defaults = UserDefaults.standard
        let userId = defaults.integer(forKey: "loggedUserId")
        
        let updateData: [String: Any] = [
            "user_id": userId,
            "day_id": dayId
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: updateData, options: []) else {
            return
        }
        
        var updateUrlRequest = URLRequest(url: updateUrl)
        updateUrlRequest.httpMethod = "POST"
        updateUrlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        updateUrlRequest.httpBody = httpBody
        
        URLSession.shared.dataTask(with: updateUrlRequest) { (data, response, error)
            in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let updateResult = try JSONDecoder().decode(UpdateResult.self, from: data)
                
                //Get back to the main queue
                DispatchQueue.main.async {
                    self.updateContent(dayId: updateResult.day_id!, name: self.dayName, type: ThirtyDayEnum.PassedDay.rawValue)
                }
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
    }
    
    var featuredImageName: String = ""
    
    public func setFeaturedImageName(value: String) {
        self.featuredImageName = value
    }
    
    var dayId: Int = 0;
    
    public func setDayId(dayId: Int) {
        self.dayId = dayId
    }
    
    var dayName: String = ""
    
    public func setDayName(name: String) {
        self.dayName = name
    }
    
    var type: Int = 0;
    var navigationController: UINavigationController!
    
    let images = ["img_ngaylock.png", "img_ngaydadoc.png", "img_ngaychuadoc.png"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bgButton.setImage(UIImage(named: images[type]), for: .normal)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    public func setNavigation(navigation: UINavigationController) {
        self.navigationController = navigation
    }
    
    public func updateContent(dayId: Int, name: String = "", type: Int) {
        self.dayId = dayId
        self.type = type
        
        if (name != "" || self.dayName == "") {
            self.dayName = name
        }
        
        dayLabel.text = self.dayName
        bgButton.setImage(UIImage(named: images[type]), for: .normal)
    }
}
