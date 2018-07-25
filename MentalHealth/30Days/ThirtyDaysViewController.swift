//
//  ThirtyDaysViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 11/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class ThirtyDaysViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var daysTableView: UITableView!
    
    let daysData = [1, 1, 1, 2, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = "30 ngày"
        
        daysTableView.reloadData()
    }
    
    // The method returning size of the list
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysData.count
    }
    
    // The method returning each cell of the list
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "thirtyDaysCell", for: indexPath) as! ThirtyDaysCell
        
        cell.setNavigation(navigation: navigationController!)
        cell.updateContent(index: indexPath.row, type: daysData[indexPath.row])
        
        return cell
    }
}
