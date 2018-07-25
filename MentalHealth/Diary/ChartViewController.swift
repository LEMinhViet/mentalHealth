//
//  ChartViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 22/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit
import SwiftChart

class ChartViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var emoticonChartView: UIView!
    @IBOutlet weak var activityView: UIView!
    
    @IBOutlet weak var activitiesCollectionView: UICollectionView!
    @IBOutlet weak var activitiesHeight: NSLayoutConstraint!
    
    @IBOutlet weak var emoChart: Chart!
    
    let chartIcons: [String] = ["ic_workcircle.png", "ic_relaxcircle.png", "ic_partycircle.png", "ic_filmcircle.png", "ic_gamecircle.png" ]
    let charTexts: [String] = ["Làm việc", "Thư giãn", "Tiệc tùng", "Xem phim", "Chơi game" ]
    let chartNb: [Int] = [3, 2, 5, 1, 1]
    
    let offsetX: [CGFloat] = [0, -1, 1, 0, 1]
    let offsetY: [CGFloat] = [0, 0, -3, 1, 0]
    
    let nbItemPerSection: Int = 5
    
    var activities: [ActivityViewCell] = []
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)

        // Do any additional setup after loading the view.
        
        emoticonChartView.layer.shadowColor = UIColor.black.cgColor
        emoticonChartView.layer.shadowOpacity = 0.4
        emoticonChartView.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        emoChart.minY = 0
        emoChart.maxY = 5
        emoChart.xLabels = [0, 1, 2, 3, 4, 5, 6]
        emoChart.xLabelsFormatter = { String(Int(round($1 + 1))) }
        emoChart.yLabels = [0, 1, 2, 3, 4]
        emoChart.topInset = 0
        emoChart.leftInset = 40
        
        let series = ChartSeries([2, 1, 4, 3, 3, 3])
        emoChart.add(series)
        
        activityView.layer.shadowColor = UIColor.black.cgColor
        activityView.layer.shadowOpacity = 0.4
        activityView.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        let height: CGFloat = self.activitiesCollectionView.collectionViewLayout.collectionViewContentSize.height
        activitiesHeight.constant = height
        self.view.layoutIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Int(round(Double(chartNb.count / nbItemPerSection)))
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return nbItemPerSection
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index: Int = indexPath.section * nbItemPerSection + indexPath.row
        
        let cell: ActivityViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "activityViewCell" , for: indexPath) as! ActivityViewCell
        
        cell.iconImage.image = UIImage(named: chartIcons[index])
        cell.nbLabel.text = String(chartNb[index])
        
        cell.nbLabel.frame.origin = CGPoint(
            x: cell.nbLabel.frame.origin.x + offsetX[index],
            y: cell.nbLabel.frame.origin.y + offsetY[index]
        )
        
        cell.titleLabel.text = charTexts[index]

        activities.append(cell)

        // Configure the cell
        return cell
    }

}
