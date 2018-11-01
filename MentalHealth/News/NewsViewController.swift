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
    var next_page_url: String?
    let prev_page_url: String?
    let from: Int
    let to: Int
    var data: [OneNews]
    
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

class NewsViewController: BaseViewController, UIScrollViewDelegate {

    @IBOutlet weak var newsStackView: UIStackView!
    
    var newsIds: [String] = []
    var newsImages: [String] = []
    var newsTitles: [String] = []
    
    var nbLoadingImage: Int = 0
    var nbFirstLoadingImage: Int = 3
    
    var loadingMore: Bool = false
    var nextPageUrl: String = ""
    
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
                    
                    if jsonData.next_page_url != nil {
                        self.nextPageUrl = jsonData.next_page_url!
                    }
                                        
                    self.newsIds = []
                    self.newsImages = []
                    self.newsTitles = []
                    
                    for i in 0 ..< self.newsData.data.count {
                        self.newsIds.append(String(self.newsData.data[i].id))
                        // self.newsImages.append(Constants.url + Constants.filePrefix + "/" + self.newsData.data[i].image.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil))
                        self.newsImages.append(Constants.url + Constants.filePrefix + "/" + self.newsData.data[i].image.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)
                        self.newsTitles.append(self.newsData.data[i].title)
                    }
                    
                    self.nbLoadingImage = min(self.newsData.data.count, self.nbFirstLoadingImage)
                    self.updateStackView(needEmpty: true, startIndex: 0)
                    
                    self.removeSpinner()
                }
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
    }
    
    // The method returning each cell of the list
    public func updateStackView(needEmpty: Bool, startIndex: Int) {
        if needEmpty {
            // Remove old content if needed
            for oldNews in newsStackView.subviews{
                oldNews.removeFromSuperview()
            }
        }
        
        // Displaying values
        for i in startIndex ..< newsImages.count {
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
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset;
        let bounds = scrollView.bounds;
        let size = scrollView.contentSize;
        let inset = scrollView.contentInset;
        let y: CGFloat = offset.y + bounds.size.height - inset.bottom;
        let h: CGFloat = size.height;
        
        let reload_distance: CGFloat = 10;
        if(y > h + reload_distance) {
            if !self.loadingMore {
                self.loadingMore = true
                self.loadPage()
            }
        }
    }
    
    func loadPage() {
        if nextPageUrl != "" {
            guard let url = URL(string: nextPageUrl) else { return }
            URLSession.shared.dataTask(with: url) { (data, resonse, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                guard let data = data else { return }
                
                do {
                    let jsonData = try JSONDecoder().decode(AllNews.self, from: data)
                    
                    // Get back to the main queue
                    DispatchQueue.main.async {
                        let lastIndex = self.newsData.data.count
                        self.newsData.data += jsonData.data
                        
                        if jsonData.next_page_url != nil {
                            self.nextPageUrl = jsonData.next_page_url!
                        }
                        else {
                            self.nextPageUrl = ""
                        }
                        
                        for i in 0 ..< jsonData.data.count {
                            self.newsIds.append(String(jsonData.data[i].id))
                            self.newsImages.append(Constants.url + Constants.filePrefix + "/" + jsonData.data[i].image.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)
                            self.newsTitles.append(jsonData.data[i].title)
                        }
                        
                        self.updateStackView(needEmpty: false, startIndex: lastIndex)
                        
                        self.loadingMore = false
                    }
                } catch let jsonError {
                    print(jsonError)
                }
            }.resume()
        }
    }
}
