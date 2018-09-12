//
//  SOSViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 08/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

struct AllSOS: Codable {
    let per_page: Int
    let current_page: Int
    let next_page_url: String?
    let prev_page_url: String?
    let from: Int
    let to: Int
    let data: [SOSData]
    
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

struct SOSData: Codable {
    let id: Int
    let title: String
}

class SOSViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var hospitalTableView: UITableView!
    
    let sosUrl = Constants.url + Constants.apiPrefix + "/sos"
    
    let hospitals = ["img_hanoi", "img_dannang", "img_hcm"];
    var hospitalIds = [1, 2, 3]
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)

        // Do any additional setup after loading the view.
        self.navigationItem.title = "SOS"
        
        guard let url = URL(string: sosUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, resonse, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let jsonData = try JSONDecoder().decode(AllSOS.self, from: data)
                
                // Get back to the main queue
                DispatchQueue.main.async {
                    self.hospitalIds = []
                    
                    for i in 0 ..< jsonData.data.count {
                        self.hospitalIds.append(jsonData.data[i].id)
                    }
                    
                    self.hospitalTableView.reloadData()
                }
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
    }
    
    // The method returning size of the list
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hospitalIds.count
    }
    
    // The method returning each cell of the list
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "sosCell", for: indexPath) as! SOSCell
        
        cell.tag = hospitalIds[indexPath.row]
        
        // Displaying values
        cell.hospitalImage.image = UIImage(named: hospitals[indexPath.row])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SOSViewController.onHospitalTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        
        cell.isUserInteractionEnabled = true
        cell.addGestureRecognizer(tapGesture)
        
        return cell
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func onHospitalTap(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SOSDetailViewController") as! SOSDetailViewController
        vc.hospitalId = (sender.view?.tag)!
        
        self.navigationController?.pushViewController(vc, animated: true)
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
