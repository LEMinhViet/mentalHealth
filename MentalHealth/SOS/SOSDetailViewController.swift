//
//  SOSDetailViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 09/09/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit
import WebKit

struct SOSDetailData: Codable {
    let id: Int
    let title: String
    let image: String
    let description: String
    let content: String
    let created_at: String
    let updated_at: String
}

class SOSDetailViewController: BaseViewController, WKNavigationDelegate {
    
    @IBOutlet weak var featuredImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    private var contentWebView: WKWebView = WKWebView()
    private var contentWebViewHeightConstraint: NSLayoutConstraint?
    private var baseHTML: String = "<html><head><meta name=\"viewport\" content=\"initial-scale=1.0\" /></head><body>{body}</body></html>"
    
    public var hospitalId: Int = 1
    let sosUrl = Constants.url + Constants.apiPrefix + "/sos"

    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false, withItems: false)
        
        contentWebView.configuration.dataDetectorTypes = .all
        
        contentWebViewHeightConstraint = NSLayoutConstraint(item: contentWebView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 235)
        mainStackView.addArrangedSubview(contentWebView)
        
        self.displaySpinner(onView: self.view)

        guard let url = URL(string: sosUrl + "/" + String(hospitalId)) else { return }
        URLSession.shared.dataTask(with: url) { (data, resonse, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let jsonData = try JSONDecoder().decode(SOSDetailData.self, from: data)
                
                // Get back to the main queue
                DispatchQueue.main.async {
                    // let imageUrl = Constants.url + Constants.filePrefix + "/" + (jsonData.image).replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
                    let imageUrl = Constants.url + Constants.filePrefix + "/" + (jsonData.image).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!

                    if let url = URL(string: imageUrl) {
                        DispatchQueue.global().async {
                            if let data = try? Data(contentsOf: url)
                            {
                                DispatchQueue.main.async {
                                    self.featuredImage.image = UIImage(data: data)
                                    self.removeSpinner()
                                }
                            }
                            else {
                                self.removeSpinner()
                            }
                        }
                    }
                    else {
                        self.removeSpinner()
                    }
                    
                    self.title = jsonData.title
                    self.titleLabel.text = jsonData.description.htmlToString
                    
                    let contentText = self.baseHTML.replacingOccurrences(of: "{body}", with: jsonData.content)
                    
                    self.contentWebViewHeightConstraint?.isActive = false
                    self.contentWebView.navigationDelegate = self
                    self.contentWebView.loadHTMLString("\(contentText)", baseURL: Bundle.main.bundleURL)
                }
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
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
                
                self.contentWebViewHeightConstraint = NSLayoutConstraint(item: self.contentWebView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.contentWebView.scrollView.contentSize.height);
                self.contentWebViewHeightConstraint?.isActive = true
                
                self.mainScrollView.contentSize = CGSize(
                    width: self.mainScrollView.frame.width,
                    height: self.contentWebView.frame.origin.y + self.contentWebView.frame.size.height)
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
