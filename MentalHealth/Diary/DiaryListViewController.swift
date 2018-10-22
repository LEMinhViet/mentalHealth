//
//  DiaryListViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 21/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

struct DiaryData: Codable {
    var id: Int
    var title: String
    var content: String
    var createdDate: Date
}

struct DiaryDataByMonth: Codable {
    var month: Int
    var diaries: [DiaryData]
}

struct DiaryDataByYear: Codable {
    var year: Int
    var months: [DiaryDataByMonth]
}

class DiaryListViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    let WEEK_DAY: [String] = [
        "",
        "CHỦ NHẬT",
        "THỨ 2",
        "THỨ 3",
        "THỨ 4",
        "THỨ 5",
        "THỨ 6",
        "THỨ 7",
    ]
    
    var diaryData: [DiaryData] = []
    var diaryDataByYears: [DiaryDataByYear] = []
    var showingYear: Int = -1
    var showingMonth: Int = -1
    var showingDiaryData: [DiaryData] = []
    var byMonthSelected: Bool = false
    var isTodaySelected: Bool = false
    
    @IBOutlet weak var diaryTableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBAction func addClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newDiaryVC = storyboard.instantiateViewController(withIdentifier: "NewDiaryViewController") as! NewDiaryViewController
        newDiaryVC.setDiaryData(data: diaryData)
        
        let vc = newDiaryVC as UIViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBOutlet weak var monthIcon: UIImageView!
    @IBOutlet weak var monthButton: UIButton!
    @IBAction func monthClicked(_ sender: Any) {
        self.byMonthSelected = !self.byMonthSelected
        self.showingYear = -1
        self.showingMonth = -1
        
        self.isTodaySelected = false
        self.updateShowingData()
        self.updateButtons()
    }
    
    @IBOutlet weak var dayIcon: UIImageView!
    @IBOutlet weak var dayButton: UIButton!
    @IBAction func dayClicked(_ sender: Any) {
        self.byMonthSelected = false
        self.showingYear = -1
        self.showingMonth = -1
        
        self.isTodaySelected = !self.isTodaySelected
        self.updateShowingData()
        self.updateButtons()
    }
    
    func isThisMonth(date: Date) -> Bool {
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        let curDate = Date()
        let curYear = calendar.component(.year, from: curDate)
        let curMonth = calendar.component(.month, from: curDate)
        
        return year == curYear && month == curMonth
    }
    
    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        let curDate = Date()
        let curYear = calendar.component(.year, from: curDate)
        let curMonth = calendar.component(.month, from: curDate)
        let curDay = calendar.component(.day, from: curDate)
        
        return year == curYear && month == curMonth && day == curDay
    }
    
    func updateShowingData() {
        if byMonthSelected {
            showingYear = -1
            showingMonth = -1
            diaryDataByYears = []
            for i in 0 ..< diaryData.count {
                let calendar = Calendar.current
                
                let year = calendar.component(.year, from: diaryData[i].createdDate)
                let month = calendar.component(.month, from: diaryData[i].createdDate)
                
                let curYearIndex = diaryDataByYears.index(where: { $0.year == year })
                
                // If no year data => Add this year and this month too
                if curYearIndex == nil {
                    let curYearData = DiaryDataByYear(
                        year: year,
                        months: [DiaryDataByMonth(month: month, diaries: [diaryData[i]])])
                    
                    diaryDataByYears.append(curYearData)
                }
                else {
                    let curMonthIndex = diaryDataByYears[curYearIndex!].months.index(where: { $0.month == month })
                    
                    if curMonthIndex == nil {
                        let curMonthData = DiaryDataByMonth(
                            month: month,
                            diaries: [diaryData[i]])
                        
                        diaryDataByYears[curYearIndex!].months.append(curMonthData)
                    }
                    else {
                        diaryDataByYears[curYearIndex!].months[curMonthIndex!].diaries.append(diaryData[i])
                    }
                }
            }
            
            // Sort data
            diaryDataByYears.sort(by: { $0.year > $1.year })
            for i in 0 ..< diaryDataByYears.count {
                diaryDataByYears[i].months.sort(by: { $0.month < $1.month })
            }
        }
        else if isTodaySelected {
            showingDiaryData = []
            for i in 0 ..< diaryData.count {
                if isToday(date: diaryData[i].createdDate) {
                    showingDiaryData.append(diaryData[i])
                }
            }
        }
        else {
            showingDiaryData = diaryData
        }
        
        diaryTableView.reloadData()
    }
    
    func updateButtons() {
        if (isTodaySelected) {
            dayButton.setTitleColor(UIColor.white, for: .normal)
            dayButton.backgroundColor = colorFromRGB(red: 240, green: 120, blue: 125, alpha: 1)
            dayIcon.isHighlighted = true
        }
        else {
            dayButton.setTitleColor(colorFromRGB(red: 93, green: 91, blue: 91, alpha: 1), for: .normal)
            dayButton.backgroundColor = UIColor.white
            dayIcon.isHighlighted = false
        }

        if (byMonthSelected) {
            monthButton.setTitleColor(UIColor.white, for: .normal)
            monthButton.backgroundColor = colorFromRGB(red: 240, green: 120, blue: 125, alpha: 1)
            monthIcon.isHighlighted = true
        }
        else {
            monthButton.setTitleColor(colorFromRGB(red: 93, green: 91, blue: 91, alpha: 1), for: .normal)
            monthButton.backgroundColor = UIColor.white
            monthIcon.isHighlighted = false
        }
    }
    
    func colorFromRGB(red: Int, green: Int, blue: Int, alpha: Int) -> UIColor {
        return UIColor(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: CGFloat(alpha)
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let data = UserDefaults.standard.value(forKey: "diaryData") as? Data {
            self.diaryData = try! PropertyListDecoder().decode(Array<DiaryData>.self, from: data)
//            Debug DATA
//            print ("DATA ", diaryData)
//            diaryData = [
//                DiaryData(id: 0, title: "1", content: "1", createdDate: Date(timeInterval: -60 * 60 * 24 * 1, since: Date())),
//                DiaryData(id: 0, title: "2", content: "2", createdDate: Date(timeInterval: -60 * 60 * 24 * 2, since: Date())),
//                DiaryData(id: 0, title: "3", content: "3", createdDate: Date(timeInterval: -60 * 60 * 24 * 5, since: Date())),
//                DiaryData(id: 0, title: "4", content: "4", createdDate: Date(timeInterval: -60 * 60 * 24 * 9, since: Date())),
//                DiaryData(id: 0, title: "5", content: "5", createdDate: Date(timeInterval: -60 * 60 * 24 * 50, since: Date())),
//                DiaryData(id: 0, title: "6", content: "6", createdDate: Date(timeInterval: -60 * 60 * 24 * 100, since: Date())),
//                DiaryData(id: 0, title: "7", content: "7", createdDate: Date(timeInterval: -60 * 60 * 24 * 300, since: Date())),
//                DiaryData(id: 0, title: "8", content: "8", createdDate: Date(timeInterval: -60 * 60 * 24 * 400, since: Date())),
//                DiaryData(id: 0, title: "9", content: "9", createdDate: Date(timeInterval: -60 * 60 * 24 * 500, since: Date())),
//                DiaryData(id: 0, title: "10", content: "10", createdDate: Date(timeInterval: -60 * 60 * 24 * 50, since: Date()))
//            ]
            
            updateShowingData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if byMonthSelected {
            if (showingYear == -1) {
                return diaryDataByYears.count
            }
            else if (showingMonth == -1) {
                return diaryDataByYears[showingYear].months.count
            }
            else {
                return diaryDataByYears[showingYear].months[showingMonth].diaries.count
            }
        }
        else {
            return showingDiaryData.count
        }
    }
    
    // The method returning each cell of the list
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if byMonthSelected && (showingYear == -1 || showingMonth == -1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "diaryGroupCell", for: indexPath) as! DiaryGroupCell
            
            if showingYear == -1 {
                let cellData = self.diaryDataByYears[indexPath.row]
                
                cell.tag = indexPath.row
                cell.yearLabel.text = String(cellData.year)
                cell.monthLabel.text = "Năm"
            }
            else if showingMonth == -1 {
                let cellData = self.diaryDataByYears[showingYear].months[indexPath.row]
                
                cell.tag = indexPath.row
                cell.yearLabel.text = String(self.diaryDataByYears[showingYear].year)
                cell.monthLabel.text = "Tháng " + String(cellData.month)
            }
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DiaryListViewController.onCellTap(_:)))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            
            cell.addGestureRecognizer(tapGesture)
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "diaryListCell", for: indexPath) as! DiaryListCell
            
            var cellData = self.showingDiaryData[indexPath.row]
            if byMonthSelected {
                cellData = self.diaryDataByYears[showingYear].months[showingMonth].diaries[indexPath.row]
            }
            
            let calendar = Calendar.current
            
            let date = calendar.component(.weekday, from: cellData.createdDate)
            let month = calendar.component(.month, from: cellData.createdDate)
            let day = calendar.component(.day, from: cellData.createdDate)
            
            cell.tag = self.diaryData.index(where: { $0.id == cellData.id })!
            cell.titleLabel.text = cellData.title
            cell.dateLabel.text = String(day) + " tháng " + String(month)
            cell.dayLabel.text = WEEK_DAY[date]
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DiaryListViewController.onCellTap(_:)))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1

            cell.addGestureRecognizer(tapGesture)
            
            let deleteGesture = UITapGestureRecognizer(target: self, action: #selector(DiaryListViewController.onCellDelete(_:)))
            deleteGesture.numberOfTapsRequired = 1
            deleteGesture.numberOfTouchesRequired = 1
            
            cell.deleteImage.tag = indexPath.row
            cell.deleteImage.addGestureRecognizer(deleteGesture)
            
            return cell
        }
    }
    
    @objc func onCellTap(_ sender: UITapGestureRecognizer) {
        if byMonthSelected && (showingYear == -1 || showingMonth == -1) {
            let cell = sender.view as? DiaryGroupCell
            
            if showingYear == -1 {
                showingYear = (cell?.tag)!
            }
            else if showingMonth == -1 {
                showingMonth = (cell?.tag)!
            }
            
            diaryTableView.reloadData()
        }
        else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let diaryDetailVC = storyboard.instantiateViewController(withIdentifier: "DiaryDetailViewController") as! DiaryDetailViewController
            
            let cell = sender.view as? DiaryListCell
            let cellData = self.diaryData[(cell?.tag)!]
            let calendar = Calendar.current
            
            let date = calendar.component(.weekday, from: cellData.createdDate)
            let month = calendar.component(.month, from: cellData.createdDate)
            let day = calendar.component(.day, from: cellData.createdDate)
            
            diaryDetailVC.setDateText(value: WEEK_DAY[date] + " - " + String(day) + " tháng " + String(month))
            diaryDetailVC.setTitleText(value: cellData.title)
            diaryDetailVC.setContentText(value: cellData.content)
            diaryDetailVC.setDiaryIndex(index: (cell?.tag)!)
            diaryDetailVC.setDiaryData(data: self.diaryData)
            
            let vc = diaryDetailVC as UIViewController
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func onCellDelete(_ sender: UITapGestureRecognizer) {
        let cell = sender.view as? UIImageView
        
        diaryData.remove(at: (cell?.tag)!)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(diaryData), forKey: "diaryData")
        updateShowingData()
    }
}
