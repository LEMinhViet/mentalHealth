//
//  VideoViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 13/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

struct AllVideoData: Codable {
    let per_page: Int
    let current_page: Int
    let next_page_url: String?
    let prev_page_url: String?
    let from: Int
    let to: Int
    let data: [VideoData]
    
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

struct VideoData: Codable {
    let id: Int
    let title: String
    let url: String
    let created_at: String
    let updated_at: String
}

class VideoViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var videoTableView: UITableView!
    
    let apiUrl = Constants.url + Constants.apiPrefix + "/videos"
    var videosData = AllVideoData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.displaySpinner(onView: self.view)

        // Do any additional setup after loading the view.
        guard let url = URL(string: apiUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, resonse, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let jsonData = try JSONDecoder().decode(AllVideoData.self, from: data)
                
                // Get back to the main queue
                DispatchQueue.main.async {
                    self.videosData = jsonData
                    self.videoTableView.reloadData()
                    
                    self.removeSpinner()
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
    

    // The method returning size of the list
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videosData.data.count
    }
    
    // The method returning each cell of the list
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! VideoCell
        
        if (cell.contentStackView.subviews.count > 0) {
            return cell
        }
        
        // Displaying values
        let video: VideoByDayCell = Bundle.main.loadNibNamed("VideoByDayCell", owner: self, options: nil)?.first as! VideoByDayCell
        
        let cellWidth = cell.frame.width;
        
        video.frame.size = CGSize(width: cellWidth, height: video.frame.height)
        video.titleLabel.text = videosData.data[videosData.data.count - 1 - indexPath.row].title
        video.initVideo(srcUrl: "https://www.youtube.com/watch?v=waMl_fNmLpE", srcFrame: video.frame)
        print("SIZE ", cellWidth, video.frame.height)
        print("ID ", String(videosData.data.count - 1 - indexPath.row))
        print("LABEL", videosData.data[videosData.data.count - 1 - indexPath.row].title)
        print("URL ", videosData.data[videosData.data.count - 1 - indexPath.row].url)
//        video.featuredVideo.image = UIImage(named: videosData.data[indexPath.row].)
                        
        cell.contentStackView.addArrangedSubview(video);
        
        return cell
    }
}
