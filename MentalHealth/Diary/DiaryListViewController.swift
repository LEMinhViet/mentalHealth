//
//  DiaryListViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 21/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class DiaryListViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {    
    
    let diaryData: [String] = ["", "", ""];
    @IBOutlet weak var diaryTableView: UITableView!
    
    @IBOutlet weak var addButton: UIButton!
    @IBAction func addClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewDiaryViewController") as UIViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBOutlet weak var monthButton: UIButton!
    @IBAction func monthClicked(_ sender: Any) {
        
    }
    
    @IBOutlet weak var dayButton: UIButton!
    @IBAction func dayClicked(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)

        // Do any additional setup after loading the view.
        diaryTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        addButton.layer.cornerRadius = 5
        monthButton.layer.cornerRadius = 5
        dayButton.layer.cornerRadius = 5
        
        monthButton.layer.shadowColor = UIColor.black.cgColor
        monthButton.layer.shadowOpacity = 0.2
        monthButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        dayButton.layer.shadowColor = UIColor.black.cgColor
        dayButton.layer.shadowOpacity = 0.2
        dayButton.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diaryData.count
    }
    
    // The method returning each cell of the list
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "diaryListCell", for: indexPath) as! DiaryListCell
        
        return cell
    }
}
