//
//  DocumentDetailViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 02/09/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit
import PDFKit
import WebKit

struct DocumentData: Codable {
    let id: Int
    let title: String
    let image: String?
    let description: String?
    let content: String?
    let created_at: String?
    let updated_at: String?
}

class DocumentDetailViewController: BaseViewController, WKNavigationDelegate {
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var featuredImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    private var contentWebView: WKWebView = WKWebView()
    
    @IBOutlet weak var loadingLabel: UILabel!
    
    @IBOutlet weak var featuredImageHeightConstraint: NSLayoutConstraint!
    private var contentWebViewHeightConstraint: NSLayoutConstraint?
    
    let apiUrl = Constants.url + Constants.apiPrefix + "/documents"
    let pdfUrl = Constants.url + Constants.apiPrefix + "/pdf"
    
    private var baseHTML: String = "<html><head><meta name=\"viewport\" content=\"initial-scale=1.0\" /></head><body>{body}</body></html>"
    
    public var urlVal: String = "http://www.pdf995.com/samples/pdf.pdf"

    public var documentId: Int = 1
    
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
        
        let documentUrl = apiUrl + "/" + String(documentId)
        guard let url = URL(string: documentUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, resonse, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let jsonData = try JSONDecoder().decode(DocumentData.self, from: data)
                
                // Get back to the main queue
                DispatchQueue.main.async {
                    self.titleLabel.text = jsonData.title
                    if jsonData.image != nil {
                        // let urlImage = Constants.url + Constants.publicPrefix + "/" + (jsonData.image!).replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
                        let urlImage = Constants.url + Constants.publicPrefix + "/" + (jsonData.image!).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                        
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
                        self.featuredImageView.image = UIImage(named: "img_documnet")
                        
                        self.isFeaturedLoaded = true
                        if self.isFeaturedLoaded && self.isBodyLoaded {
                            self.removeSpinner()
                        }
                    }
                    
                    let contentText = self.baseHTML.replacingOccurrences(of: "{body}", with: jsonData.content ?? "")
                    
                    self.contentWebViewHeightConstraint?.isActive = false
                    self.contentWebView.navigationDelegate = self
                    self.contentWebView.loadHTMLString("\(contentText)", baseURL: Bundle.main.bundleURL)
                }
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
        
        loadingLabel.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                
                self.mainStackView.updateConstraints()
                
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
    
    @IBAction func pdfClicked(_ sender: Any) {
        self.loadingLabel.isHidden = false
        self.loadingLabel.setNeedsLayout()
        self.loadingLabel.layoutIfNeeded()
        
//        guard let url = URL(string: urlVal) else {
        guard let url = URL(string: pdfUrl + "/" + String(documentId)) else {
            self.loadingLabel.isHidden = true
            return
        }

        if #available(iOS 11, *) {
            DispatchQueue.global().async {
                guard let pdfDocument = PDFDocument(url: url) else {
                    DispatchQueue.main.async {
                        self.loadingLabel.isHidden = true
                    }
                    return
                }
                
                guard let pdfData = pdfDocument.dataRepresentation() else {
                    DispatchQueue.main.async {
                        self.loadingLabel.isHidden = true
                    }
                    return
                }
                
                let shareVC = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
                shareVC.popoverPresentationController?.sourceView = self.view
                self.present(shareVC, animated: true, completion: nil)
                
                DispatchQueue.main.async {
                    self.loadingLabel.isHidden = true
                }
            }

        }
        else if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            loadingLabel.isHidden = true
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
