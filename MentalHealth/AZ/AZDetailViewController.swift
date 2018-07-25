//
//  AZDetailViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 14/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class AZDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var azDetailTableView: UITableView!
    
    let titles = ["Rôi loạn trầm cảm là gì?", "Triệu chứng của bệnh", "Phương pháp điều trị", "Trích dẫn"]
    
    var isExtended = [false, false, false, false]
    
    let descriptions = ["Ardeo, mihi credite, Patres conscripti (id quod vosmet de me existimatis et facitis ipsi) incredibili quodam amore patriae, qui me amor et subvenire olim impendentibus periculis maximis cum dimicatione capitis, et rursum, cum omnia tela undique esse intenta in patriam videosrem, subire coegit atque excipere unum pro universis. Hic me meus in rem publicam animus pristinus ac perennis cum C."]
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)
        
        azDetailTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isExtended[section] ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 80
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    // The method returning each cell of the list
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "azDetailHeaderCell", for: indexPath) as! AZDetailHeaderCell
            
            cell.label.text = titles[indexPath.row / 2]
            
            if (isExtended[indexPath.section]) {
                cell.setExtended()
            }
            else {
                cell.setCollapsed()
            }
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "azDetailCell", for: indexPath) as! AZDetailCell
            
            cell.label.text = descriptions[0]
            
            let borderLayer = cell.borderView.layer

            borderLayer.shadowColor = UIColor.black.cgColor
            borderLayer.shadowOpacity = 0.4
            borderLayer.shadowOffset = CGSize.zero
            borderLayer.shadowRadius = 4
            
//            let borderBounds = cell.borderView.bounds
//            let bounds = CGRect(
//                x: borderBounds.origin.x,
//                y: borderBounds.origin.y,
//                width: borderBounds.width,
//                height: cell.label.intrinsicContentSize.height + 40
//            )
        
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            isExtended[indexPath.section] = !isExtended[indexPath.section]
            
            azDetailTableView.reloadSections([indexPath.section], with: .automatic)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
