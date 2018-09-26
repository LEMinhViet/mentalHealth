//
//  StoryBoardManager.swift
//  MentalHealth
//
//  Created by PS Solutions on 9/16/18.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import Foundation
import UIKit

class StoryboardManager {
    static let shared = StoryboardManager()
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    func instantiateNewsViewContrller() -> NewsViewController {
        return storyboard.instantiateViewController(withIdentifier: "NewsViewController") as! NewsViewController
    }
    
    func instantiateNewsDetailViewContrller() -> NewsDetailViewController {
        return storyboard.instantiateViewController(withIdentifier: "NewsDetailViewController") as! NewsDetailViewController
    }
    
    func instantiateChatViewController() -> ChatViewController {
        return storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
    }
    
    func instantiateQuizViewController() -> GameViewController {
       return storyboard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
    }
    
    func instantiateThirtyDaysViewController() -> ThirtyDaysViewController {
        return storyboard.instantiateViewController(withIdentifier: "ThirtyDaysViewController") as! ThirtyDaysViewController
    }
    
    func instantiateDayViewController() -> DayViewController {
        return storyboard.instantiateViewController(withIdentifier: "DayViewController") as! DayViewController
    }
    
    func instantiateEmotionViewController() -> UIViewController? {
        return nil
    }
}
