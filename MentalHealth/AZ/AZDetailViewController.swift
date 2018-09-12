//
//  AZDetailViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 14/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class AZDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var azDetailTableView: UITableView!
    
    let titles = ["Khái niệm", "Triệu chứng", "Phân loại", "Trị liệu", "Tự trợ giúp", "Trích nguồn"]
    
    var header = "img_roiloanloau.png"
    var isExtended = [false, false, false, false, false, false]
    var descriptions = ["", "", "", "", "", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)
        headerImageView.image = UIImage(named: self.header)
        azDetailTableView.reloadData()
    }
    
    public func setData(header: String, definition: String, symptom: String, type: String, treatments: String, help: String, quote: String) {
        self.header = header
        self.descriptions = [
            definition,
            symptom,
            type,
            treatments,
            help,
            quote
        ]
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
            
            cell.label.text = titles[indexPath.section]
            
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
            
            cell.label.text = descriptions[indexPath.section].htmlToString
            
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

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
