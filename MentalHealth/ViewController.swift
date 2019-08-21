//
//  ViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 25/06/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

struct FeaturedData: Codable {
    let title: String
    let image: String
}

class ViewController: BaseViewController, UIScrollViewDelegate, ShowLeftSubPageDelegate {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var mainView: UIStackView!
    @IBOutlet weak var subBgView: UIView!
    @IBOutlet weak var featuredScrollView: UIScrollView!
    @IBOutlet weak var featuredPageControl: UIPageControl!
    
    @IBOutlet var newsTapGesture: UITapGestureRecognizer!
    @IBAction func newsClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewsViewController") as UIViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBOutlet var thirtyDaysTapGesture: UITapGestureRecognizer!
    @IBAction func thirtyDaysClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ThirtyDaysViewController") as UIViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBOutlet var azTapGesture: UITapGestureRecognizer!
    @IBAction func azClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AZViewController") as UIViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBOutlet var libraryTapGesture: UITapGestureRecognizer!
    @IBAction func libraryClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LibraryViewController") as UIViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBOutlet var diaryTapGesture: UITapGestureRecognizer!
    @IBAction func diaryClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DiaryListViewController") as UIViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBOutlet var gameTapGesture: UITapGestureRecognizer!
    @IBAction func gameClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GameViewController") as UIViewController
        navigationController?.pushViewController(vc, animated: false)
    }
    
    let featuredUrl = Constants.url + Constants.apiPrefix + "/news"//"/banners"
    var placeHolders = ["ic_tramcam.jpg", "ic_tramcam.jpg", "ic_tramcam.jpg"]
    var featuredTitles = [
        "Những giấu hiêu của bệnh rối loạn lo âu",
        "Những giấu hiêu của bệnh rối loạn lo âu",
        "Những giấu hiêu của bệnh rối loạn lo âu"]
    var featuredIds = [-1, -1, -1]
    
    var slides: [FeaturedSlide] = [];
    
    var nbFeaturedSlides: Int = 3
    
    let leftPanelOffset: CGFloat = 240
    var leftPanelExpanded = false
    var leftViewController: LeftViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: true)
        // Do any additional setup after loading the view, typically from a nib.
        
        self.displaySpinner(onView: self.view)
        self.updateBadge()
    
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (note) -> Void in
            self.updateBadge()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "BadgeNotification"), object: nil, queue: nil) { (note) -> Void in
            self.updateBadge()
        }
        
        let navibarHeight = (self.navigationController?.navigationBar.frame.height)!
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.leftViewController = storyboard.instantiateViewController(withIdentifier: "LeftViewController") as? LeftViewController

        view.insertSubview((self.leftViewController?.view)!, at: 1)
        addChild(self.leftViewController!)

        self.leftViewController?.view.frame = CGRect(
            x: -leftPanelOffset,
            y: -navibarHeight,
            width: self.view.frame.width,
            height: self.view.frame.height + navibarHeight
        )
        
        self.menuButton?.addTarget(self, action: #selector(menuPush), for: .touchUpInside)
        
        self.bgView.frame = CGRect(
            x: -leftPanelOffset,
            y: -navibarHeight * 2,
            width: self.view.frame.width + leftPanelOffset,
            height: self.view.frame.height + navibarHeight * 2
        )
        
        self.leftViewController?.delegate = self
        
        featuredScrollView.delegate = self
        
        guard let url = URL(string: featuredUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, resonse, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
               // let jsonData = try JSONDecoder().decode([FeaturedData].self, from: data)
                let jsonData = try JSONDecoder().decode(AllNews.self, from: data)
                // Get back to the main queue
                DispatchQueue.main.async {
                    self.placeHolders = []
                    self.featuredTitles = []
                    self.featuredIds = []
                    
                    for i in 0 ..< min(jsonData.data.count, self.nbFeaturedSlides) {
                        // self.placeHolders.append(Constants.url + Constants.publicPrefix + "/" + jsonData.data[i].image.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil))
                        self.placeHolders.append(Constants.url + Constants.publicPrefix + "/" + jsonData.data[i].image.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)
                        self.featuredTitles.append(jsonData.data[i].title)
                        self.featuredIds.append(jsonData.data[i].id)
                    }
                    
                    self.slides = self.createSlides()
                    self.setupSlideScrollView(slides: self.slides)
                    self.featuredPageControl.numberOfPages = self.slides.count
                    self.featuredPageControl.currentPage = 0
                    
                    self.removeSpinner()
                }
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
        
        self.view.bringSubviewToFront(self.featuredPageControl)
    }
    
    @objc private func menuPush() {
        leftPanelExpanded = !leftPanelExpanded
        if (leftPanelExpanded) {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.mainView.frame.origin.x = self.leftPanelOffset;
                self.subBgView.frame.origin.x = self.leftPanelOffset;
                self.leftViewController?.view.frame.origin.x = 0;
                self.navigationController?.navigationBar.frame.origin.x = self.leftPanelOffset
            }, completion: nil)
            
            // Disable interaction of main menu when left menu is opened
            self.enableMainTaps(false)
        }
        else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.mainView.frame.origin.x = 0;
                self.subBgView.frame.origin.x = 0;
                self.leftViewController?.view.frame.origin.x = -self.leftPanelOffset;
                self.navigationController?.navigationBar.frame.origin.x = 0
            }, completion: nil)
            
            self.enableMainTaps(true)
        }
    }
    
    func hideLeftPage() {
        leftPanelExpanded = true
        self.menuPush()
    }
    
    private func enableMainTaps(_ value: Bool) {
        featuredScrollView.isUserInteractionEnabled = value
        newsTapGesture.isEnabled = value
        thirtyDaysTapGesture.isEnabled = value
        azTapGesture.isEnabled = value
        libraryTapGesture.isEnabled = value
        diaryTapGesture.isEnabled = value
        gameTapGesture.isEnabled = value
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.updateBadge()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupSlideScrollView(slides: slides)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     * Create and populate slides in featured panel
     */
    func createSlides() -> [FeaturedSlide] {
        var createdSlides: [FeaturedSlide] = []
        
        for i in 0 ..< placeHolders.count {
            let slide: FeaturedSlide = Bundle.main.loadNibNamed("FeaturedSlide", owner: self, options: nil)?.first as! FeaturedSlide
            
            slide.titleLabel.text = featuredTitles[i]
            slide.newsId = featuredIds[i]
            
            if let url = URL(string: placeHolders[i]) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url)
                    {
                        DispatchQueue.main.async {
                            slide.imageView.image = UIImage(data: data)
                            
//                            if i == 0 {
//                                self.removeSpinner()
//                            }
                        }
                    }
//                    else if i == 0 {
//                        self.removeSpinner()
//                    }
                }
            }
//            else if i == 0 {
//                self.removeSpinner()
//            }
            
            if createdSlides.count < 3 {
                createdSlides.append(slide)
            }
        }
        
        return createdSlides
    }
    
    func setupSlideScrollView(slides: [FeaturedSlide]) {
        let width = featuredScrollView.frame.width
        let height = featuredScrollView.frame.height
        
        featuredScrollView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        featuredScrollView.contentSize = CGSize(width: width * CGFloat(slides.count), height: height)
        featuredScrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            let ratio = slides[i].imageView.frame.height / slides[i].imageView.frame.width
            
            slides[i].frame = CGRect(
                x: width * CGFloat(i),
                y: 0,
                width: width,
                height: width * ratio
            )
            
            slides[i].imageView.frame = CGRect(
                x: 0,
                y: 0,
                width: width,
                height: height
            )
            
            slides[i].titleBackground.frame = CGRect(
                x: 0,
                y: height - 80,
                width: width,
                height: 80
            )
            
            slides[i].titleLabel.frame.origin = CGPoint(
                x: (width - slides[i].titleLabel.frame.width) / 2,
                y: height - featuredPageControl.frame.height - slides[i].titleLabel.frame.height
            )
            
            slides[i].setNavigation(navigation: navigationController!)
            
            featuredScrollView.addSubview(slides[i])
        }
    }
    
    /*
     * default function called when view is scrolled. In order to enable callback
     * when scrollview is scrolled, the below code needs to be called:
     * slideScrollView.delegate = self or
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / featuredScrollView.frame.width)
        featuredPageControl.currentPage = Int(pageIndex)
    }
    
    func updateBadge() {
        let groupDefaults = UserDefaults.init(suiteName: Constants.APP_GROUP)
        var nbBadge = groupDefaults?.integer(forKey: "nbBadge")
        print("BQDGE ", nbBadge)
        if nbBadge == nil {
            nbBadge = 0
        }
        
        self.updateNotification(nbBadge: nbBadge!)
    }
}
