//
//  FavoritesViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 04/09/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

struct FavoritesData: Codable {
    var id: String
    var title: String
    var date: String
    var featuredImage: String
    var description: String
    var content: String
}

class FavoritesViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var favoritesTableView: UITableView!
    
    var nbLoadingImage: Int = 0
    
    @IBOutlet weak var placeholderLabel: UILabel!
    private var favoritesData: [FavoritesData] = []

    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)
        
        self.displaySpinner(onView: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let data = UserDefaults.standard.value(forKey: "favoritesData") as? Data {
            self.favoritesData = try! PropertyListDecoder().decode(Array<FavoritesData>.self, from: data)
            
            self.nbLoadingImage = favoritesData.count
            favoritesTableView.reloadData()
            
            self.placeholderLabel.isHidden = favoritesData.count > 0
            print("NB LOADING", self.nbLoadingImage)
            if self.nbLoadingImage == 0 {
                self.removeSpinner()
            }
        }
        else {
            self.removeSpinner()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesData.count
    }
    
    // The method returning each cell of the list
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoritesListCell", for: indexPath) as! FavoritesListCell
        
        let cellData = self.favoritesData[indexPath.row]
        
        cell.tag = indexPath.row
        cell.titleLabel.text = cellData.title
        print ("IMAGE ", cellData.featuredImage)
        if cellData.featuredImage != "" {
            if let url = URL(string: cellData.featuredImage) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            cell.featuredImageView.image = UIImage(data: data)
                            
                            // Fit container to image
                            let image = cell.featuredImageView.image
                            let ratio = (image?.size.width)! / (image?.size.height)!
                            let newHeight = cell.featuredImageView.frame.width / ratio
                            
                            cell.imageHeightConstraint.constant = newHeight
                            
                            self.nbLoadingImage -= 1
                            if (self.nbLoadingImage == 0) {
                                self.favoritesTableView.beginUpdates()
                                self.favoritesTableView.endUpdates()
                                
                                self.removeSpinner()
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.nbLoadingImage -= 1
                            if (self.nbLoadingImage == 0) {
                                self.favoritesTableView.beginUpdates()
                                self.favoritesTableView.endUpdates()
                                
                                self.removeSpinner()
                            }
                        }
                    }
                }
            }
        }
        else {
            self.removeSpinner()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FavoritesViewController.onCellTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        
        cell.addGestureRecognizer(tapGesture)
        
        return cell
    }
    
    @objc func onCellTap(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewsDetailViewController") as! NewsDetailViewController
        let cellData = self.favoritesData[(sender.view?.tag)!]
        
        vc.setNewsId(value: cellData.id)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
