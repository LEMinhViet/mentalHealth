//
//  NewsDetailViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 03/08/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit
import WebKit

struct NewsDetailData: Codable {
    let id: Int
    let title: String
    let image: String?
    let description: String?
    let content: String?
    let noti_at: String?
    let order: Int
    let created_at: String?
    let updated_at: String?
    let total_views: Int?
}

class NewsDetailViewController: BaseViewController, WKNavigationDelegate {

    @IBOutlet weak var likeImageView: UIImageView!
    @IBAction func likeClicked(_ sender: Any) {
        likeImageView.isHighlighted = !likeImageView.isHighlighted
        
        var favoritesData: [FavoritesData]
        if let data = UserDefaults.standard.value(forKey: "favoritesData") as? Data {
            favoritesData = try! PropertyListDecoder().decode(Array<FavoritesData>.self, from: data)
        }
        else {
            favoritesData = []
        }
        
        let index = favoritesData.index(where: { $0.id == self.newsId })
        if (likeImageView.isHighlighted) {
            if (index == nil) {
                favoritesData.append(FavoritesData(
                    id: self.newsId,
                    title: self.newsTitle,
                    featuredImage: self.featuredImage,
                    content: self.newsContent))
            }
        }
        else {
            if (index != nil) {
                favoritesData.remove(at: index!)
            }
        }
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(favoritesData), forKey: "favoritesData")
    }
    
    @IBAction func shareClicked(_ sender: Any) {
        
    }
    
    var newsId: String = ""
    var newsTitle: String = ""
    var featuredImage: String = ""
    var newsContent: String = ""
    
    func setNewsId(value: String) {
        newsId = value
    }
    
    func setNewsTitle(value: String) {
        newsTitle = value
    }
    
    func setFeaturedImage(value: String) {
        featuredImage = value
    }
    
    func setNewsContent(value: String) {
        newsContent = value
    }
    
    let apiUrl = Constants.url + Constants.apiPrefix + "/news"
    
    private var baseHTML: String = "<html><head><meta name=\"viewport\" content=\"initial-scale=1.0\" /></head><body>{body}</body></html>"
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var featuredImageView: UIImageView!
    @IBOutlet weak var contentWebView: WKWebView!
    
    @IBOutlet weak var featuredImageHeightConstraint: NSLayoutConstraint!
    
    private var isFeaturedLoaded: Bool = false
    private var isBodyLoaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false, withItems: false)
        
        self.displaySpinner(onView: self.view)
        self.isFeaturedLoaded = false
        self.isBodyLoaded = false

        // Do any additional setup after loading the view.
        if let data = UserDefaults.standard.value(forKey: "favoritesData") as? Data {
            let favoritesData = try! PropertyListDecoder().decode(Array<FavoritesData>.self, from: data)
            
            let index = favoritesData.index(where: { $0.id == self.newsId })
            self.likeImageView.isHighlighted = index != nil
        }
        
        if newsId != "" {
            let newsUrl = apiUrl + "/" + newsId
            guard let url = URL(string: newsUrl) else { return }
            URLSession.shared.dataTask(with: url) { (data, resonse, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                guard let data = data else { return }
                
                do {
                    let jsonData = try JSONDecoder().decode(NewsDetailData.self, from: data)
                    
                    // Get back to the main queue
                    DispatchQueue.main.async {
                        self.titleLabel.text = jsonData.title
                        self.setNewsTitle(value: jsonData.title)
                        
                        if jsonData.image != nil {
                            let urlImage = Constants.url + Constants.filePrefix + "/" + (jsonData.image!).replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
                            self.setFeaturedImage(value: urlImage)
                            
                            if let url = URL(string: urlImage) {
                                DispatchQueue.global().async {
                                    if let data = try? Data(contentsOf: url) {
                                        DispatchQueue.main.async {
                                            self.featuredImageView.image = UIImage(data: data)
                                            
                                            // Fit container to image
                                            let image = self.featuredImageView.image
                                            let ratio = (image?.size.width)! / (image?.size.height)!
                                            let newHeight = self.featuredImageView.frame.width / ratio
                                            
                                            self.featuredImageHeightConstraint.constant = newHeight
                                            
                                            self.isFeaturedLoaded = true
                                            if self.isFeaturedLoaded && self.isBodyLoaded {
                                                self.removeSpinner()
                                            }
                                        }
                                    }
                                    else {
                                        DispatchQueue.main.async {
                                            self.isFeaturedLoaded = true
                                            if self.isFeaturedLoaded && self.isBodyLoaded {
                                                self.removeSpinner()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else {
                            self.featuredImageView.image = UIImage(named: "img_roiloancamxuc")
                        }
                        
                        let contentText = self.baseHTML.replacingOccurrences(of: "{body}", with: jsonData.content ?? "")
                        
                        self.contentWebView.navigationDelegate = self
                        self.contentWebView.loadHTMLString("\(contentText)", baseURL: Bundle.main.bundleURL)
                    }
                } catch let jsonError {
                    print(jsonError)
                }
            }.resume()
        }
        else {
            self.removeSpinner()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                self.contentWebView.frame.size = self.contentWebView.scrollView.contentSize
                
                self.mainScrollView.contentSize = CGSize(
                    width: self.mainScrollView.frame.width,
                    height: self.contentWebView.frame.origin.y + self.contentWebView.frame.size.height)
                
                self.isBodyLoaded = true
                if self.isFeaturedLoaded && self.isBodyLoaded {
                    self.removeSpinner()
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
