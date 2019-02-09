//
//  SearchViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 05/09/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class SearchViewController: BaseViewController, UISearchResultsUpdating, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var placeholderLabel: UILabel!
    private var searchControl: UISearchController?
    
    @IBOutlet weak var searchTableBottomContraint: NSLayoutConstraint!
    @IBOutlet weak var searchTableView: UITableView!
    private var searchData: [NewsDetailData] = []
    
    private var nbLoadingImage: Int = 0
    private var currentTag: Int = 0
    
    let apiUrl = Constants.url + Constants.apiPrefix + "/search"
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false, withItems: false)

        // Do any additional setup after loading the view.
        searchControl = UISearchController(searchResultsController: nil)
        searchControl?.searchResultsUpdater = self
        searchControl?.dimsBackgroundDuringPresentation = false
        searchControl?.hidesNavigationBarDuringPresentation = false
        searchControl?.searchBar.delegate = self
        
        navigationItem.titleView = searchControl?.searchBar
        searchControl?.searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.view.backgroundColor = UIColor.white
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateSearchResults(for searchController: UISearchController) {
        self.displaySpinner(onView: self.view)
        
        let searchUrl = apiUrl + "/" + (searchControl?.searchBar.text)!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

        guard let url = URL(string: searchUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, resonse, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let jsonData = try JSONDecoder().decode([NewsDetailData].self, from: data)
                
                // Get back to the main queue
                DispatchQueue.main.async {
                    self.searchData = jsonData
                    self.nbLoadingImage = self.searchData.count
                    
                    self.currentTag += 1
                    self.searchTableView.reloadData()
                    
                    self.placeholderLabel.isHidden = jsonData.count > 0
                    
                    if self.nbLoadingImage == 0 {
                        self.removeSpinner()
                    }
                }
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.nbLoadingImage = 0
        self.removeSpinner()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchData.count
    }
    
    // The method returning each cell of the list
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchListCell", for: indexPath) as! SearchListCell
        
        let cellData = self.searchData[indexPath.row]
        
        cell.tag = indexPath.row
        cell.titleLabel.text = cellData.title
        cell.featuredImageView.tag = self.currentTag
        
        // if let url = URL(string: Constants.url + Constants.publicPrefix + "/" + (cellData.image!).replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)) {
        if let url = URL(string: Constants.url + Constants.publicPrefix + "/" + (cellData.image!).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        cell.featuredImageView.image = UIImage(data: data)
                        
                        // Fit container to image
                        let image = cell.featuredImageView.image
                        let ratio = (image?.size.width)! / (image?.size.height)!
                        let newHeight = cell.featuredImageView.frame.width / ratio
                        
                        cell.featuredImageHeightConstraint.constant = newHeight
                        if cell.featuredImageView.tag == self.currentTag {
//                            print("LOADING ", self.nbLoadingImage)
                            self.nbLoadingImage -= 1
                        }
                        
                        if (self.nbLoadingImage == 0) {
                            self.removeSpinner()
                            
                            self.searchTableView.beginUpdates()
                            self.searchTableView.endUpdates()
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                        cell.featuredImageView.image = UIImage(named: "img_roiloancamxuc")
                        
                        self.nbLoadingImage -= 1
                        if (self.nbLoadingImage == 0) {
                            self.removeSpinner()
                            
                            self.searchTableView.beginUpdates()
                            self.searchTableView.endUpdates()
                        }
                    }
                }
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.onCellTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        
        cell.addGestureRecognizer(tapGesture)
        
        return cell
    }
    
    @objc func onCellTap(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewsDetailViewController") as! NewsDetailViewController
        let cellData = self.searchData[(sender.view?.tag)!]
        
        vc.setNewsId(value: String(cellData.id))
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
