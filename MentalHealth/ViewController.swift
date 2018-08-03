//
//  ViewController.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 25/06/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit

class ViewController: BaseViewController, UIScrollViewDelegate {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var mainView: UIStackView!
    @IBOutlet weak var featuredScrollView: UIScrollView!
    @IBOutlet weak var featuredPageControl: UIPageControl!
    
    @IBAction func newsClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewsViewController") as UIViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func thirtyDaysClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ThirtyDaysViewController") as UIViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func azClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AZViewController") as UIViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func libraryClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LibraryViewController") as UIViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func diaryClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DiaryViewController") as UIViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func gameClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GameViewController") as UIViewController
        navigationController?.pushViewController(vc, animated: false)
    }
    
    let placeHolders = ["ic_tramcam.jpg", "ic_tramcam.jpg", "ic_tramcam.jpg"];
    
    var slides: [FeaturedSlide] = [];
    
    let leftPanelOffset: CGFloat = 240
    var leftPanelExpanded = false
    var leftViewController: LeftViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad(withMenu: true)
        // Do any additional setup after loading the view, typically from a nib.
        
        let navibarHeight = (self.navigationController?.navigationBar.frame.height)!
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.leftViewController = storyboard.instantiateViewController(withIdentifier: "LeftViewController") as? LeftViewController

        view.insertSubview((self.leftViewController?.view)!, at: 1)
        addChildViewController(self.leftViewController!)

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
    }
    
    @objc private func menuPush() {
        leftPanelExpanded = !leftPanelExpanded
        if (leftPanelExpanded) {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.view.frame.origin.x = self.leftPanelOffset;
                self.navigationController?.navigationBar.frame.origin.x = self.leftPanelOffset
            }, completion: nil)
            
            // Disable interaction of main menu when left menu is opened
            self.view.isUserInteractionEnabled = false
        }
        else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.view.frame.origin.x = 0;
                self.navigationController?.navigationBar.frame.origin.x = 0
            }, completion: nil)
            
            self.view.isUserInteractionEnabled = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        featuredScrollView.delegate = self
        
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        featuredPageControl.numberOfPages = slides.count
        featuredPageControl.currentPage = 0
        view.bringSubview(toFront: featuredPageControl)
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
        let slide_00: FeaturedSlide = Bundle.main.loadNibNamed("FeaturedSlide", owner: self, options: nil)?.first as! FeaturedSlide
        slide_00.imageView.image = UIImage(named: placeHolders[0])
        
        let slide_01: FeaturedSlide = Bundle.main.loadNibNamed("FeaturedSlide", owner: self, options: nil)?.first as! FeaturedSlide
        slide_01.imageView.image = UIImage(named: placeHolders[1])
        
        let slide_02: FeaturedSlide = Bundle.main.loadNibNamed("FeaturedSlide", owner: self, options: nil)?.first as! FeaturedSlide
        slide_02.imageView.image = UIImage(named: placeHolders[2])
        
        return [slide_00, slide_01, slide_02]
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
                height: width * ratio)
            
            slides[i].imageView.frame.origin = CGPoint(
                x: (width - slides[i].imageView.frame.width) / 2,
                y: (height - slides[i].imageView.frame.height) / 2
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
    
    
}
