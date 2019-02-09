//
//  ChartViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 22/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit
import SwiftChart

struct AllActivities: Codable {
    let per_page: Int
    let current_page: Int
    let next_page_url: String?
    let prev_page_url: String?
    let from: Int
    let to: Int
    let data: [OneActivity]
    
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

struct OneActivity: Codable {
    let id: Int
    let name: String
    let created_at: String?
    let updated_at: String?
}

struct AllFeelings: Codable {
    let per_page: Int
    let current_page: Int
    let next_page_url: String?
    let prev_page_url: String?
    let from: Int
    let to: Int
    let data: [OneFeeling]
    
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

struct OneFeeling: Codable {
    let id: Int
    let name: String
    let created_at: String?
    let updated_at: String?
}

class ChartViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var emoticonChartView: UIView!
    @IBOutlet weak var activityView: UIView!
    
    @IBOutlet weak var activitiesCollectionView: UICollectionView!
    @IBOutlet weak var activitiesHeight: NSLayoutConstraint!
    
    @IBOutlet weak var emoChart: Chart!
    
    // ---------------------------------------------------------------------------
    // Constants for activities chat
    let chartIcons: [String: String] = [
        "1": "ic_filmcircle.png",
        "2": "ic_friends.png",
        "3": "ic_partycircle.png",
        "4": "ic_relaxcircle.png",
        "5": "ic_filmcircle.png"
    ]
    // "ic_workcircle.png", "ic_relaxcircle.png", "ic_partycircle.png", "ic_filmcircle.png",  "ic_gamecircle.png" ]
    var charTexts: [String] = [] // ["Làm việc", "Thư giãn", "Tiệc tùng", "Xem phim", "Chơi game"]
    var chartNb: [Int] = [] // [3, 2, 5, 1, 1]
    var chartId: [String] = []
    
    let offsetX: [String: CGFloat] = [
        "1": 0,
        "2": 1
    ]
    // 0, -1, 1, 0, 1
    
    let offsetY: [String: CGFloat] = [
        "1": 1,
        "2": -3
    ]
    // 0, 0, -3, 1, 0
    
    let nbItemPerSection: Int = 5
    
    var activities: [ActivityViewCell] = []
    
    let doingApiUrl = Constants.url + Constants.apiPrefix + "/doing"
    var activitiesData = AllActivities()
    
    // Constants for activities chat
    
    let nbFeelingTypes: Double = 5
    
    let feelingApiUrl = Constants.url + Constants.apiPrefix + "/feeling"
    var feelingsData = AllFeelings()
    
    // ---------------------------------------------------------------------------
    // Functions
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)

        // Do any additional setup after loading the view.
        
        emoticonChartView.layer.shadowColor = UIColor.black.cgColor
        emoticonChartView.layer.shadowOpacity = 0.4
        emoticonChartView.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        emoChart.minY = 0
        emoChart.maxY = 5
//        emoChart.xLabels = [0, 1, 2, 3, 4, 5, 6]
        emoChart.xLabelsFormatter = { String(Int(round($1 + 1))) }
        emoChart.yLabels = [0, 1, 2, 3, 4]
        emoChart.topInset = 0
        emoChart.leftInset = 40
        
        guard let feelingUrl = URL(string: feelingApiUrl) else { return }
        URLSession.shared.dataTask(with: feelingUrl) { (data, resonse, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let jsonData = try JSONDecoder().decode(AllFeelings.self, from: data)
                
                //Get back to the main queue
                DispatchQueue.main.async {
                    self.feelingsData = jsonData
                    
                    self.emoChart.removeAllSeries()
                    
                    var series: [Double] = []
                    var xLabels: [Double] = [0]
                    for i in 0 ..< self.feelingsData.data.count {
                        series.append(self.nbFeelingTypes - Double(self.feelingsData.data[i].id) - 1)
                        xLabels.append(Double(i + 1))
                    }
                    
                    self.emoChart.xLabels = xLabels
                    self.emoChart.add(ChartSeries(series))
                }
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
        
        activityView.layer.shadowColor = UIColor.black.cgColor
        activityView.layer.shadowOpacity = 0.4
        activityView.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        guard let doingUrl = URL(string: doingApiUrl) else { return }
        URLSession.shared.dataTask(with: doingUrl) { (data, resonse, error) in
            if error != nil {
                print(error!.localizedDescription)
            }

            guard let data = data else { return }

            do {
                let jsonData = try JSONDecoder().decode(AllActivities.self, from: data)

                //Get back to the main queue
                DispatchQueue.main.async {
                    self.activitiesData = jsonData

                    self.chartNb = []
                    self.chartId = []
                    self.charTexts = []

                    for i in 0 ..< self.activitiesData.data.count {
                        self.chartNb.append(1)
                        self.chartId.append(String(self.activitiesData.data[i].id))
                        self.charTexts.append(self.activitiesData.data[i].name)
                    }

                    self.activitiesCollectionView.reloadData()
                    
                    let height: CGFloat = self.activitiesCollectionView.collectionViewLayout.collectionViewContentSize.height
                    self.activitiesHeight.constant = height
                    self.view.layoutIfNeeded()
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
    

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 // Int(ceil(CGFloat(chartNb.count) / CGFloat(nbItemPerSection)))
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
//        let nbSection: Int = Int(ceil(CGFloat(chartNb.count) / CGFloat(nbItemPerSection)))
//        if (section < nbSection - 1) {
//            return nbItemPerSection
//        }
//        else {
//            return chartNb.count - (nbSection - 1) * nbItemPerSection
//        }
        
        return chartNb.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index: Int = indexPath.section * nbItemPerSection + indexPath.row
        
        let cell: ActivityViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "activityViewCell" , for: indexPath) as! ActivityViewCell
        
        cell.iconImage.image = UIImage(named: chartIcons[chartId[index]]!)
        cell.nbLabel.text = String(chartNb[index])
        
        cell.nbLabel.isHidden = true
//        cell.nbLabel.frame.origin = CGPoint(
//            x: cell.nbLabel.frame.origin.x + offsetX[chartId[index]]!,
//            y: cell.nbLabel.frame.origin.y + offsetY[chartId[index]]!
//        )
        
        cell.titleLabel.text = charTexts[index]

        activities.append(cell)

        // Configure the cell
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let nbSection = Int(ceil(CGFloat(chartNb.count) / CGFloat(nbItemPerSection)))
//
//        let frameW = self.activitiesCollectionView.frame.width - 10 * CGFloat(nbItemPerSection)
//
//        let ratio: CGFloat = CGFloat(58) / CGFloat(64)
//        let width: CGFloat = frameW / CGFloat(nbItemPerSection)
//        let height: CGFloat = width / ratio
//
//        print (self.activitiesCollectionView.frame.height, nbSection, height)
//
//        return CGSize(
//            width: width,
//            height: height
//        );
//    }

}
