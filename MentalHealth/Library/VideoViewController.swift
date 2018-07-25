//
//  VideoViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 13/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class VideoViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var videoTableView: UITableView!
    
    let dataByDays: [[String]] = [["img_hospital1", "img_hospital2"], ["img_hospital3.png"]];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        videoTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // The method returning size of the list
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataByDays.count
    }
    
    // The method returning each cell of the list
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! VideoCell
        
        // Displaying values
        for i in 0 ..< dataByDays[indexPath.row].count {
            let video: VideoByDayCell = Bundle.main.loadNibNamed("VideoByDayCell", owner: self, options: nil)?.first as! VideoByDayCell
            
            let cellWidth = cell.frame.width;
            
            video.frame.size = CGSize(width: cellWidth, height: video.frame.height)
            video.featuredVideo.image = UIImage(named: dataByDays[indexPath.row][i])
            
            cell.contentStackView.addArrangedSubview(video);
        }
        
        return cell
    }
}
