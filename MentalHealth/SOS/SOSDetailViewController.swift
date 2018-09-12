//
//  SOSDetailViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 09/09/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

struct SOSDetailData: Codable {
    let id: Int
    let title: String
    let image: String
    let description: String
    let content: String
    let created_at: String
    let updated_at: String
}

class SOSDetailViewController: BaseViewController {
    
    @IBOutlet weak var featuredImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    public var hospitalId: Int = 1
    let sosUrl = Constants.url + Constants.apiPrefix + "/sos"

    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false, withItems: false)
        
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
                    let imageUrl = Constants.url + Constants.filePrefix + "/" + (jsonData.image).replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)

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
                    self.contentLabel.text = jsonData.content.htmlToString
                }
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
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
