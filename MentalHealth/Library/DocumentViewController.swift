//
//  DocumentViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 25/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class DocumentViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var documentTableView: UITableView!
    
    let dataByDays: [[String]] = [["img_placeholder_news.png", "img_placeholder_news.png"], ["img_placeholder_news.png"]];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        documentTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // The method returning size of the list
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataByDays.count
    }
    
    // The method returning each cell of the list
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentCell", for: indexPath) as! DocumentCell
        
        // Displaying values
        for i in 0 ..< dataByDays[indexPath.row].count {
            let document: DocumentByDayCell = Bundle.main.loadNibNamed("DocumentByDayCell", owner: self, options: nil)?.first as! DocumentByDayCell
            
            let cellWidth = cell.frame.width;
            
            document.frame.size = CGSize(width: cellWidth, height: document.frame.height)
            document.featuredImage.image = UIImage(named: dataByDays[indexPath.row][i])
            
            cell.contentStackView.addArrangedSubview(document);
        }
        
        return cell
    }

}
