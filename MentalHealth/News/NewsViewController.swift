//
//  NewsViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 12/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

struct AllNews: Codable {
    let per_page: Int
    let current_page: Int
    let next_page_url: String?
    let prev_page_url: String?
    let from: Int
    let to: Int
    let data: [OneNews]
    
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

struct OneNews: Codable {
    let id: Int
    let title: String
    let image: String
}

class NewsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var newsTableView: UITableView!
    
    var idByDays: [[String]] = []
    var imagesByDays: [[String]] = []
    var titleByDays: [[String]] = []
    
    var nbLoadingImage: Int = 0
    
    let apiUrl: String = Constants.url + Constants.apiPrefix + "/news"
    var newsData = AllNews()
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)
        
        self.displaySpinner(onView: self.view)

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Tin tức"

        guard let url = URL(string: apiUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, resonse, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let jsonData = try JSONDecoder().decode(AllNews.self, from: data)
                
                // Get back to the main queue
                DispatchQueue.main.async {
                    self.newsData = jsonData
                    
                    self.idByDays = []
                    self.imagesByDays = []
                    self.titleByDays = []
                    
                    self.idByDays.append([])
                    self.imagesByDays.append([])
                    self.titleByDays.append([])
                    
                    for i in 0 ..< self.newsData.data.count {
                        self.idByDays[0].append(String(self.newsData.data[i].id))
                        self.imagesByDays[0].append(Constants.url + Constants.filePrefix + "/" + self.newsData.data[i].image.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil))
                        self.titleByDays[0].append(self.newsData.data[i].title)
                    }
                    
                    self.nbLoadingImage = self.newsData.data.count
                    self.newsTableView.reloadData()
                }
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
    }
    
    // The method returning size of the list
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagesByDays.count
    }
    
    // The method returning each cell of the list
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsCell
        
        // Remove old content if needed
        for oldNews in cell.contentStackView.subviews{
            oldNews.removeFromSuperview()
        }
        
        // Displaying values
        for i in 0 ..< imagesByDays[indexPath.row].count {
            let article: NewsByDayCell = Bundle.main.loadNibNamed("NewsByDayCell", owner: self, options: nil)?.first as! NewsByDayCell
            
            let cellWidth = cell.frame.width;
            
            article.frame.size = CGSize(width: cellWidth, height: article.frame.height)
            
            if let url = URL(string: imagesByDays[indexPath.row][i]) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            article.featuredImage.image = UIImage(data: data)
                            
                            // Fit container to image
                            let image = article.featuredImage.image
                            let ratio = (image?.size.width)! / (image?.size.height)!
                            let newHeight = article.featuredImage.frame.width / ratio
                            
                            article.imageHeightConstraint.constant = newHeight
                            
                            self.nbLoadingImage -= 1
                            if (self.nbLoadingImage == 0) {
                                self.newsTableView.beginUpdates()
                                self.newsTableView.endUpdates()
                                
                                self.removeSpinner()
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            article.featuredImage.image = UIImage(named: "img_roiloancamxuc")
                            
                            self.nbLoadingImage -= 1
                            if (self.nbLoadingImage == 0) {
                                self.newsTableView.beginUpdates()
                                self.newsTableView.endUpdates()
                                
                                self.removeSpinner()
                            }
                        }
                    }
                }
            }
            
            article.titleLabel.text = titleByDays[indexPath.row][i]
            
            article.setFeaturedImageName(value: imagesByDays[indexPath.row][i])
            article.setNewsId(newsId: idByDays[indexPath.row][i])
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
