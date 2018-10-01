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

class NewsViewController: BaseViewController {

    @IBOutlet weak var newsStackView: UIStackView!
    
    var newsIds: [String] = []
    var newsImages: [String] = []
    var newsTitles: [String] = []
    
    var nbLoadingImage: Int = 0
    var nbFirstLoadingImage: Int = 3
    
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
                    
                    self.newsIds = []
                    self.newsImages = []
                    self.newsTitles = []
                    
                    for i in 0 ..< self.newsData.data.count {
                        self.newsIds.append(String(self.newsData.data[i].id))
                        self.newsImages.append(Constants.url + Constants.filePrefix + "/" + self.newsData.data[i].image.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil))
                        self.newsTitles.append(self.newsData.data[i].title)
                    }
                    
                    self.nbLoadingImage = min(self.newsData.data.count, self.nbFirstLoadingImage)
                    self.updateStackView()
                    
                    self.removeSpinner()
                }
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
    }
    
    // The method returning each cell of the list
    public func updateStackView() {
        // Remove old content if needed
        for oldNews in newsStackView.subviews{
            oldNews.removeFromSuperview()
        }
        
        // Displaying values
        for i in 0 ..< newsImages.count {
            let article: NewsCell = Bundle.main.loadNibNamed("NewsCell", owner: self, options: nil)?.first as! NewsCell
            
            let cellWidth = newsStackView.frame.width;
            
            article.translatesAutoresizingMaskIntoConstraints = false
            article.frame.size = CGSize(width: cellWidth, height: article.frame.height)
            
            if let url = URL(string: newsImages[i]) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            article.featuredImage.image = UIImage(data: data)
                            
                            // Fit container to image
                            let image = article.featuredImage.image
                            let ratio = (image?.size.width)! / (image?.size.height)!
                            let newHeight = article.featuredImage.frame.width / ratio
                            
                            article.imageHeightConstraint.constant = newHeight
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            article.featuredImage.image = UIImage(named: "img_roiloancamxuc")
                        }
                    }
                }
            }
            
            article.titleLabel.text = newsTitles[i]
            
            article.setFeaturedImageName(value: newsImages[i])
            article.setNewsId(newsId: newsIds[i])
            article.setNavigation(navigation: navigationController!)

            newsStackView.addArrangedSubview(article);
        }
    }
}
