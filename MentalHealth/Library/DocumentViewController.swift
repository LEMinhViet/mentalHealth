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
    @IBOutlet weak var studentImageView: UIImageView!
    @IBOutlet weak var anxietyDisorderImageView: UIImageView!
    @IBOutlet weak var stressImageView: UIImageView!
    
    let apiUrl = Constants.url + Constants.apiPrefix + "/documents"
    var allDocumentData = AllDocumentData()
    
    @IBAction func studentClicked(_ sender: Any) {
        if (allDocumentData.data.count > 0) {
            openDocumentById(id: allDocumentData.data[0].id)
        }
    }
    
    @IBAction func anxietyDisorderClicked(_ sender: Any) {
        if (allDocumentData.data.count > 1) {
            openDocumentById(id: allDocumentData.data[1].id)
        }
    }
    
    @IBAction func stressClicked(_ sender: Any) {
        if (allDocumentData.data.count > 2) {
            openDocumentById(id: allDocumentData.data[2].id)
        }
    }
    
    private func openDocumentById(id: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DocumentDetailViewController") as? DocumentDetailViewController
        vc?.documentId = id
        
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
