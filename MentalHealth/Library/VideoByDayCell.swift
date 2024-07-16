//
//  VideoByDayCell.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 13/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit
import WebKit

class VideoByDayCell: UIView, WKNavigationDelegate {

    @IBOutlet weak var featuredVideo: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var webView: WKWebView = WKWebView()
    private let watchPrefix: String = "watch?v="
    private let embedPrefix: String = "embed/"
    
    @IBAction func onClicked(_ sender: Any) {
//        if #available(iOS 10.0, *) {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        } else {
//            UIApplication.shared.openURL(url)
//        }
    }
    
    public var videoUrl: String = ""
    
    public func initVideo(srcUrl: String, srcFrame: CGRect) {
        // Convert to embed url
        // videoUrl = srcUrl.replacingOccurrences(of: watchPrefix, with: embedPrefix, options: .literal, range: nil)
        
        guard let url = URL(string: srcUrl) else {
            return // Be safe
        }
        
        self.webView.frame = srcFrame
        self.webView.configuration.allowsInlineMediaPlayback = true
        self.webView.load(URLRequest(url: url))
        self.webView.isHidden = false
        self.webView.navigationDelegate = self
        
        self.addSubview(self.webView)
        self.fillAnchor(parent: self, child: self.webView)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webView.isHidden = false
    }
    
    private func fillAnchor(parent: UIView, child: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        
        child.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        child.trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
        child.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        child.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
    }

    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
