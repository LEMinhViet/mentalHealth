//
//  AZViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 12/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

struct AllAZ: Codable {
    let per_page: Int
    let current_page: Int
    let next_page_url: String?
    let prev_page_url: String?
    let from: Int
    let to: Int
    let data: [OneAZ]
    
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

struct OneAZ: Codable {
    let id: Int
    let name: String
    let created_at: String
    let updated_at: String
}

struct DetailAZ: Codable {
    let id: Int
    let subject_id: Int
    let definition: String
    let symptom: String
    let treatments: String
    let quote: String
    let type: String
    let help: String
    let created_at: String
    let updated_at: String
}

class AZViewController: BaseViewController {
    
    var sectionImages: [String: String] = [
        "1": "img_roiloanloau.png",
        "2": "img_roiloanluongcuc.png",
        "4": "img_roiloantramcam.png"
    ]
    
    var defaultSectionImage: String = "img_defaultAZ.png";
    
    var headerImages: [String: String] = [
        "1": "img_roiloanloau-1.png",
        "2": "img_roiloancamxuc.png",
        "4": "img_roiloantramcam-1.png"
    ]
    
    var defaultHeaderImage: String = "img_roiloantramcam-1.png";

    
    let apiUrl = Constants.url + Constants.apiPrefix + "/subject"
    var azData = AllAZ();
    
    let detailApiUrl = Constants.url + Constants.apiPrefix + "/diseases/"
    var detailData: [DetailAZ] = []
    
    @IBOutlet weak var azStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)
        
        self.displaySpinner(onView: self.view)

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Từ A - Z"
        
        guard let url = URL(string: apiUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, resonse, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let jsonData = try JSONDecoder().decode(AllAZ.self, from: data)
                
                // Get back to the main queue
                DispatchQueue.main.async {
                    self.azData = jsonData

                    for i in stride(from: self.azData.data.count - 1, to: -1, by: -1) {
                        let id = self.azData.data[i].id
                        let curSectionImage = self.sectionImages[String(id)]
                        let useDefaultImage = curSectionImage == nil
                        
                        // Default image
                        let imageView = UIImageView(image: UIImage(named: curSectionImage ?? self.defaultSectionImage))
                        imageView.contentMode = .scaleAspectFit
                                            
                        // Fit container to image
                        let ratio = imageView.image!.size.width / imageView.image!.size.height
                        let newHeight = self.azStackView.frame.width / ratio
                        
                        let imageHeightConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: newHeight);
                        imageHeightConstraint.isActive = true
                        imageView.tag = id;
                        
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AZViewController.onImageTap(_:)))
                        tapGesture.numberOfTapsRequired = 1
                        tapGesture.numberOfTouchesRequired = 1
                        
                        imageView.isUserInteractionEnabled = true
                        imageView.addGestureRecognizer(tapGesture)
                        
                        self.azStackView.addArrangedSubview(imageView)
                        
                        if useDefaultImage {
                            let containerWidth = self.azStackView.bounds.width
                            let containerHeight = newHeight
                            
                            let titleView = UILabel(frame: CGRect(x: containerWidth * 0.4, y: 0, width: containerWidth / 2, height: containerHeight))
                            titleView.font = UIFont.boldSystemFont(ofSize: 20.0)
                            titleView.textAlignment = .center
                            titleView.textColor = UIColor.white
                            titleView.numberOfLines = 0
                            titleView.text = self.azData.data[i].name

                            imageView.addSubview(titleView)
                        }
                    }
                    
                    self.removeSpinner()
                }
            } catch let jsonError {
                DispatchQueue.main.async {
                    self.removeSpinner()
                }
                
                print("Error when loading AZ data", jsonError)
            }
        }.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func onImageTap(_ sender: UITapGestureRecognizer) {        
        self.jumpToDetail(sender.view?.tag ?? 1)
    }
    
    func jumpToDetail(_ detailId: Int) {
        guard let url = URL(string: detailApiUrl + String(detailId)) else { return }
        URLSession.shared.dataTask(with: url) { (data, resonse, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            do {
                let jsonData = try JSONDecoder().decode([DetailAZ].self, from: data)
                
                // Get back to the main queue
                DispatchQueue.main.async {
                    self.detailData = jsonData
                    
                    if (self.detailData.count > 0) {
                        let updateData = self.detailData[0]
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let azViewController = storyboard.instantiateViewController(withIdentifier: "AZDetailViewController") as! AZDetailViewController
                        azViewController.setData(
                            header: self.headerImages[String(updateData.subject_id)] ?? self.defaultHeaderImage,
                            definition: updateData.definition,
                            symptom: updateData.symptom,
                            type: updateData.type,
                            treatments: updateData.treatments,
                            help: updateData.help,
                            quote: updateData.quote)
                        
                        let vc = azViewController as UIViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    
                    self.removeSpinner()
                }
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
    }
}
