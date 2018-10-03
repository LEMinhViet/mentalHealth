//
//  NotificationViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 03/09/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class NotificationViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var notificationTableView: UITableView!
    
    var notificationDatas: Array<NotiObject> = []
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)

        // Do any additional setup after loading the view.
        
        let groupDefaults = UserDefaults.init(suiteName: "group.crisp.mentalhealth.shinningmind")
        let notificationRawDatas = groupDefaults?.value(forKey: "notificationDatas") as? Data
        
        print ("NOTIFICATION RAW = ", notificationRawDatas)
        
        if notificationRawDatas != nil {
            self.notificationDatas = try! PropertyListDecoder().decode(Array<NotiObject>.self, from: notificationRawDatas!)
            
            print ("NOTIFICATION DATA = ", notificationDatas, notificationDatas.count)
            
            notificationTableView.reloadData()
            
            resetBadge()
        }
    }
    
    func readNoti(notiIndex: Int) {
        notificationDatas[notiIndex].isRead = true
        
        let groupDefaults = UserDefaults.init(suiteName: "group.crisp.mentalhealth.shinningmind")
        groupDefaults?.set(try? PropertyListEncoder().encode(notificationDatas), forKey: "notificationDatas")
    }
    
    func resetBadge() {
        let groupDefaults = UserDefaults.init(suiteName: "group.crisp.mentalhealth.shinningmind")
        groupDefaults?.set(0, forKey: "nbBadge")
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BadgeNotification"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationDatas.count
    }
    
    // The method returning each cell of the list
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationListCell", for: indexPath) as! NotificationListCell
        cell.tag = notificationDatas.count - 1 - indexPath.row
        
        let cellData = self.notificationDatas[notificationDatas.count - 1 - indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy, hh:mm"
        
        cell.titleLabel.text = cellData.title
        
        if cellData.date != nil {
            cell.dateLabel.text = dateFormatter.string(from: cellData.date!)
        }
        else {
            cell.dateLabel.text = ""
        }
        
        if cellData.isRead != nil && cellData.isRead! == false {
            cell.backgroundColor = UIColor.init(red: 0.12, green: 0.48, blue: 0.68, alpha: 0.2)
        }
        else {
            cell.backgroundColor = UIColor.white
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NotificationViewController.onCellTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        
        cell.addGestureRecognizer(tapGesture)
        
        return cell
    }
    
    @objc func onCellTap(_ sender: UITapGestureRecognizer) {
        let noti = self.notificationDatas[sender.view?.tag ?? 0]
        NotificationHandler.receiveNoti(noti)
        
        readNoti(notiIndex: sender.view?.tag ?? 0)
        notificationTableView.reloadData()
    }
}
