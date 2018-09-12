//
//  NotificationViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 03/09/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class NotificationViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    var notificationData: [String] = ["Notification 01", "Notification 02", "Notification 03"]
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationData.count
    }
    
    // The method returning each cell of the list
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationListCell", for: indexPath) as! NotificationListCell
        
        let cellData = self.notificationData[indexPath.row]
        
        cell.titleLabel.text = cellData
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NotificationViewController.onCellTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        
        cell.addGestureRecognizer(tapGesture)
        
        return cell
    }
    
    @objc func onCellTap(_ sender: UITapGestureRecognizer) {
    
    }
}
