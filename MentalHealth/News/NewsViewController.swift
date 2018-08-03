//
//  NewsViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 12/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class NewsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var newsTableView: UITableView!
    
    let dataByDays: [[String]] = [["img_placeholder_news", "img_placeholder_news"], ["img_placeholder_news"]];
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Tin tức"
        
        newsTableView.reloadData()
    }
    
    // The method returning size of the list
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataByDays.count
    }
    
    // The method returning each cell of the list
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsCell
        
        // Displaying values
        for i in 0 ..< dataByDays[indexPath.row].count {
            let article: NewsByDayCell = Bundle.main.loadNibNamed("NewsByDayCell", owner: self, options: nil)?.first as! NewsByDayCell
            
            let cellWidth = cell.frame.width;
            
            article.frame.size = CGSize(width: cellWidth, height: article.frame.height)
            article.featuredImage.image = UIImage(named: dataByDays[indexPath.row][i])
            article.setNavigation(navigation: navigationController!)

            cell.contentStackView.addArrangedSubview(article);
        }
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
