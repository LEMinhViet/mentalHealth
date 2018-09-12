//
//  ThirtyDaysViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 11/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

struct AllDays: Codable {
    let per_page: Int
    let current_page: Int
    let next_page_url: String?
    let prev_page_url: String?
    let from: Int
    let to: Int
    let data: [OneDay]
    
    init() {
        per_page = 0
        current_page = 0
        next_page_url = nil
        prev_page_url = nil
        from = 0
        to = 0
        data = []
    }
}

struct OneDay: Codable {
    let id: Int
    let name: String
    let active: String
    let wasRead: Bool
}

class ThirtyDaysViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var daysTableView: UITableView!
    
    let apiUrl = Constants.url + Constants.apiPrefix + "/days"
    var daysData = AllDays();
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)
        
        self.displaySpinner(onView: self.view)
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = "30 ngày"
        
        let defaults = UserDefaults.standard
        let fullUrl = apiUrl + "/" + String(defaults.integer(forKey: "loggedUserId"))
        guard let url = URL(string: fullUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, resonse, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let jsonData = try JSONDecoder().decode(AllDays.self, from: data)
                
                // Get back to the main queue
                DispatchQueue.main.async {
                    self.daysData = jsonData
                    self.daysTableView.reloadData()
                    
                    self.removeSpinner()
                }
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
    }
    
    // The method returning size of the list
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysData.data.count
    }
    
    // The method returning each cell of the list
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "thirtyDaysCell", for: indexPath) as! ThirtyDaysCell
        
        let isActive = daysData.data[indexPath.row].active
        let wasRead = daysData.data[indexPath.row].wasRead
        
        cell.setFeaturedImageName(value: "img_ngaydadoc.png")
        cell.setNavigation(navigation: navigationController!)
        
        if isActive == "1" {
            if wasRead {
                cell.updateContent(dayId: daysData.data[indexPath.row].id, type: 1)
            }
            else {
                cell.updateContent(dayId: daysData.data[indexPath.row].id, type: 2)
            }
            
        }
        else {
            cell.updateContent(dayId: daysData.data[indexPath.row].id, type: 0)
        }
        
        return cell
    }
}
