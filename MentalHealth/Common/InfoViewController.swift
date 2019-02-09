//
//  InfoViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 30/08/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit
import WebKit

struct AllInfo: Codable {
    let info: String
    
    init() {
        info = ""
    }
}

class InfoViewController: BaseViewController, WKNavigationDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    private var baseHTML: String = "<html><head><meta name=\"viewport\" content=\"initial-scale=1.0\" /></head><body>{body}</body></html>"
    
    private var contentWebView: WKWebView = WKWebView()
    private var contentWebViewHeightConstraint: NSLayoutConstraint?
    private var contentWebViewTopConstraint: NSLayoutConstraint?
    
    let apiUrl = Constants.url + Constants.apiPrefix + "/info"
    var infoData: AllInfo = AllInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)
        
        contentWebView.configuration.dataDetectorTypes = .all
        contentWebViewHeightConstraint = NSLayoutConstraint(item: contentWebView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 235)
        
        self.stackView.addArrangedSubview(contentWebView)

        guard let url = URL(string: apiUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let jsonData = try JSONDecoder().decode(AllInfo.self, from: data)
                
                DispatchQueue.main.async {
                    self.infoData = jsonData
                    
                    let contentText = self.baseHTML.replacingOccurrences(of: "{body}", with: jsonData.info)
                    
                    self.contentWebViewHeightConstraint?.isActive = false
                    self.contentWebView.navigationDelegate = self
                    self.contentWebView.loadHTMLString("\(contentText)", baseURL: Bundle.main.bundleURL)
                }
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                self.contentWebView.frame.size = self.contentWebView.scrollView.contentSize
                
                self.contentWebViewHeightConstraint = NSLayoutConstraint(item: self.contentWebView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.contentWebView.scrollView.contentSize.height);
                self.contentWebViewHeightConstraint?.isActive = true
                
                self.scrollView.contentSize = CGSize(
                    width: self.scrollView.frame.width,
                    height: self.contentWebView.frame.origin.y + self.contentWebView.frame.size.height)
            }
        })
    }

}
