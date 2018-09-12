//
//  DayViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 11/07/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

struct OneDayDetail: Codable {
    let id: Int
    let day_id: String
    let title: String
    let image: String?
    let video: String?
    let text: String?
    let created_at: String
    let updated_at: String
}

class DayViewController: BaseViewController {
    
    @IBOutlet weak var paginationControl: UIPageControl!
    @IBOutlet weak var contentView: UIView!
    
    public var dayId: Int = 0
    
    private var allData: [OneDayDetail] = []
    
    private var dayPages: [UIView] = []
    private var currentPage: Int = 0
    
    let apiUrl = Constants.url + Constants.apiPrefix + "/day"
    
    @IBOutlet var rightSwipeRecognizer: UISwipeGestureRecognizer!
    @IBAction func rightSwipe(_ sender: Any) {
        currentPage = max(currentPage - 1, 0)
        self.setPage()
    }
    
    @IBOutlet var leftSwipeRecognizer: UISwipeGestureRecognizer!
    @IBAction func leftSwipe(_ sender: Any) {
        currentPage = min(currentPage + 1, paginationControl.numberOfPages - 1)
        self.setPage()
    }
    
    func setPage() {
        self.paginationControl.currentPage = currentPage
        self.enableSwipe(value: false)
        
        var ok: Bool = false
        for i in 0 ..< self.dayPages.count {
            if i == currentPage {
                if dayPages[i].alpha == 0 {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.dayPages[i].alpha = 1
                    }, completion: { (done: Bool) in
                        self.enableSwipe(value: true)
                    })
                    
                    ok = true
                }
                else {
                    self.enableSwipe(value: true)
                    ok = true
                }
            }
            else {
                dayPages[i].alpha = 0.0
            }
        }
        
        if !ok {
            self.enableSwipe(value: true)
        }
    }
    
    func enableSwipe(value: Bool) {
        rightSwipeRecognizer.isEnabled = value
        leftSwipeRecognizer.isEnabled = value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: false)

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Ngày thứ " + String(dayId)
        
        guard let url = URL(string: apiUrl + "/" + String(dayId)) else { return }
        URLSession.shared.dataTask(with: url) { (data, resonse, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let jsonData = try JSONDecoder().decode([OneDayDetail].self, from: data)
                
                self.allData = jsonData
                
                //Get back to the main queue
                DispatchQueue.main.async {
                    // Remove old content if needed
                    for oldView in self.contentView.subviews{
                        oldView.removeFromSuperview()
                    }
                    
                    if jsonData.count > 0 {
                        self.contentView.isHidden = false
                        
                        for i in 0 ..< jsonData.count {
                            self.createSlide(index: i, data: jsonData[i])
                        }
                        
                        self.paginationControl.numberOfPages = self.dayPages.count
                        self.setPage()
                    }
                    else {
                        self.contentView.isHidden = true
                        self.paginationControl.numberOfPages = 1
                        self.enableSwipe(value: false)
                    }
                }
            } catch let jsonError {
                print(jsonError)
                DispatchQueue.main.async {
                    self.contentView.isHidden = true
                    self.paginationControl.numberOfPages = 1
                    self.enableSwipe(value: false)
                }
            }
        }.resume()
    }
    
    private func createSlide(index: Int, data: OneDayDetail) {
        let slide: DayViewSlide = Bundle.main.loadNibNamed("DayViewSlide", owner: self, options: nil)?.first as! DayViewSlide
        
       slide.titleLabel.text = data.title

        let contentView: UIView
        if data.text != nil && data.text != "" {
            contentView = self.createTextSlide(index: index, text: data.text!)
        }
        else if data.video != nil && data.video != "" {
            contentView = self.createVideoSlide(index: index, image: data.image!, video: data.video!)
        }
        else {
            contentView = self.createImageSlide(index: index, image: data.image!)

        }
        
        slide.contentView.addSubview(contentView)
        self.fillAnchor(parent: slide.contentView, child: contentView)
        contentView.contentMode = .center
        contentView.tag = index
        
        self.dayPages.append(slide)
        self.contentView.insertSubview(slide, at: 0)
        
        self.fillAnchor(parent: self.contentView, child: slide)
        slide.contentMode = .center
        slide.alpha = 0
        slide.tag = index
    }
    
    private func createImageSlide(index: Int, image: String) -> UIImageView {
        let slideContent: UIImageView = UIImageView(image: UIImage(named: "img_roiloancamxuc"))
        
        let urlImage = Constants.url + Constants.filePrefix + "/" + image.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
        
        if let url = URL(string: urlImage) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        slideContent.image = UIImage(data: data)
                    }
                }
            }
        }
        
        return slideContent
    }
    
    private func createVideoSlide(index: Int, image: String, video: String) -> UIImageView {
        let slideContent: UIImageView = UIImageView(image: UIImage(named: "img_roiloancamxuc"))
        
        let urlImage = Constants.url + Constants.filePrefix + "/" + image.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
        
        if let url = URL(string: urlImage) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        slideContent.image = UIImage(data: data)
                    }
                }
            }
        }
        
        let playImage = UIImageView(image: UIImage(named: "ic_video"))
        slideContent.addSubview(playImage)
        
        slideContent.isUserInteractionEnabled = true
        
        self.fillAnchor(parent: slideContent, child: playImage)
        playImage.contentMode = .center
        
        // Tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DayViewController.onVideoTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        
        slideContent.addGestureRecognizer(tapGesture)
        
        return slideContent
    }
    
    @objc func onVideoTap(_ sender: UITapGestureRecognizer) {
        let videoUrl = self.allData[(sender.view?.tag)!].video
        guard let url = URL(string: videoUrl!) else {
            return // Be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    private func createTextSlide(index: Int, text: String) -> UILabel {
        let slideContent = UILabel(frame: CGRect.zero)
        
        slideContent.textAlignment = .center
        slideContent.textColor = UIColor.black
        slideContent.numberOfLines = 0
        slideContent.text = text
        slideContent.alpha = 0
        slideContent.sizeToFit()

        return slideContent
    }

    private func fillAnchor(parent: UIView, child: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        
        child.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        child.trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
        child.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        child.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
    }
    
    private func fillHorizontal(parent: UIView, child: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        
        child.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        child.trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
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
