//
//  DocumentViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 25/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

struct AllDocumentData: Codable {
    let per_page: Int
    let current_page: Int
    let next_page_url: String?
    let prev_page_url: String?
    let from: Int
    let to: Int
    let data: [DocumentData]
    
    init() {
        per_page = 0
        current_page = 0
        next_page_url = ""
        prev_page_url = ""
        from = 0
        to = 0
        data = []
    }
}

class DocumentViewController: BaseViewController {
    
    @IBOutlet weak var documentStackView: UIStackView!
    
    let apiUrl = Constants.url + Constants.apiPrefix + "/documents"
    var allDocumentData = AllDocumentData()
    
    @objc func openDocumentById(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DocumentDetailViewController") as? DocumentDetailViewController
        vc?.documentId = sender.view?.tag ?? 1
        
        navigationController?.pushViewController(vc!, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.displaySpinner(onView: self.view)
        
        documentStackView.isHidden = true
        
        guard let url = URL(string: apiUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, resonse, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            do {
                self.allDocumentData = try JSONDecoder().decode(AllDocumentData.self, from: data)
                
                // Get back to the main queue
                DispatchQueue.main.async {
                    self.documentStackView.isHidden = false
                    
                    for i in 0 ..< self.allDocumentData.data.count {
                        let id = self.allDocumentData.data[i].id
                        
                        // Default image
                        let imageView = UIImageView(image: UIImage(named: "img_sinhvien.png"))
                        
                        let imageName = Constants.url + Constants.publicPrefix + "/" + (self.allDocumentData.data[i].image ?? "")
                        print("  ", imageView.frame.height)
                        if let imageUrl = URL(string: imageName.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!) {
                            DispatchQueue.global().async {
                                if let data = try? Data(contentsOf: imageUrl) {
                                    DispatchQueue.main.async {
                                        imageView.image = UIImage(data: data)
                                        imageView.contentMode = .scaleAspectFit
                                        
                                        // Fit container to image
                                        let ratio = imageView.image!.size.width / imageView.image!.size.height
                                        let newHeight = self.documentStackView.frame.width / ratio
                                        
                                        let imageHeightConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: newHeight);
                                        imageHeightConstraint.isActive = true
                                    }
                                }
                            }
                        }
                        
                        imageView.tag = id
                        
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DocumentViewController.openDocumentById(_:)))
                        tapGesture.numberOfTapsRequired = 1
                        tapGesture.numberOfTouchesRequired = 1
                        
                        imageView.isUserInteractionEnabled = true
                        imageView.addGestureRecognizer(tapGesture)
                        
                        self.documentStackView.addArrangedSubview(imageView)
                    }
                    
                    self.removeSpinner()
                }
            } catch let jsonError {
                DispatchQueue.main.async {
                    self.removeSpinner()
                }
                
                print(jsonError)
            }
        }.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
