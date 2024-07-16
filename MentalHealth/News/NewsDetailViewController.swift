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
    let cate_id: Int
    let created_at: String?
    let updated_at: String?
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
                    date: self.newsDate,
                    featuredImage: self.featuredImage,
                    description: self.newsDescription,
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
    var newsDate: String = ""
    var featuredImage: String = ""
    var newsDescription: String = ""
    var newsContent: String = ""
    
    func setNewsId(value: String) {
        newsId = value
    }
    
    func setNewsTitle(value: String) {
        newsTitle = value
    }
    
    func setNewsDate(value: String) {
        newsDate = value
    }
    
    func setFeaturedImage(value: String) {
        featuredImage = value
    }
    
    func setNewsDescription(value: String) {
        newsDescription = value
    }
    
    func setNewsContent(value: String) {
        newsContent = value
    }
    
    let apiUrl = Constants.url + Constants.apiPrefix + "/news"
    
    private var baseHTML: String = "<html><head><meta name=\"viewport\" content=\"initial-scale=1.0\" /></head><body>{body}</body></html>"
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var featuredImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var contentWebView: WKWebView = WKWebView()

    @IBOutlet weak var featuredImageHeightConstraint: NSLayoutConstraint!
    private var contentWebViewHeightConstraint: NSLayoutConstraint?
    private var contentWebViewTopConstraint: NSLayoutConstraint?
    
    private var isFeaturedLoaded: Bool = false
    private var isBodyLoaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false, withItems: false)
        
        contentWebView.configuration.dataDetectorTypes = .all
        
        contentWebViewHeightConstraint = NSLayoutConstraint(item: contentWebView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 235)
        
        mainStackView.addArrangedSubview(contentWebView)
        
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
            guard let url = URL(string: newsUrl) else {
                print("News url faildd")
                return
            }
            
            URLSession.shared.dataTask(with: url) { (data, resonse, error) in
                if error != nil {
                    print("Error when loading news detail", error!.localizedDescription)
                }
                
                guard let data = data else { return }
                
                do {
                    print("News raw data : ", data)
                    let jsonData = try JSONDecoder().decode(NewsDetailData.self, from: data)
                    
                    print("JSON Data: ", jsonData);
                    
                    // Get back to the main queue
                    DispatchQueue.main.async {
                        self.titleLabel.text = jsonData.title
                        self.setNewsTitle(value: jsonData.title)
                        
                        self.dateLabel.text = self.formatDate(jsonData.updated_at ?? "")
                        self.setNewsDate(value: jsonData.updated_at ?? "")
                        
                        var despStr: String = jsonData.description?.htmlToString ?? ""
                        if despStr.last == "\n" {
                            despStr.removeLast()
                        }
                        
                        self.descriptionLabel.text = despStr
                        self.setNewsDescription(value: jsonData.description ?? "")
                        
                        if jsonData.image != nil {
                            // let urlImage = Constants.url + Constants.publicPrefix + "/" + (jsonData.image!).replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
                            let urlImage = Constants.url + Constants.publicPrefix + "/" + (jsonData.image!).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
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
                        
                        self.contentWebViewHeightConstraint?.isActive = false
                        self.contentWebView.navigationDelegate = self
                        self.contentWebView.loadHTMLString("\(contentText)", baseURL: Bundle.main.bundleURL)
                    }
                } catch let jsonError {
                    print("Error when loading news detail", jsonError)
                }
            }.resume()
        }
        else {
            self.removeSpinner()
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            if let url = navigationAction.request.url {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:])
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            
            decisionHandler(WKNavigationActionPolicy.cancel)
            return
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                self.contentWebView.frame.size = self.contentWebView.scrollView.contentSize
                
                self.contentWebViewHeightConstraint = NSLayoutConstraint(item: self.contentWebView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.contentWebView.scrollView.contentSize.height);
                self.contentWebViewHeightConstraint?.isActive = true
                
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
    
    func formatDate(_ date: String) -> String {
        let dateFormatterIn = DateFormatter()
        dateFormatterIn.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatterOut = DateFormatter()
        dateFormatterOut.dateFormat = "dd/MM/yyyy"
        
        if let date = dateFormatterIn.date(from: date) {
            return dateFormatterOut.string(from: date)
        } else {
            print("There was an error decoding the string")
            return ""
        }
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
