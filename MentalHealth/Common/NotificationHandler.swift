//
//  NotificationHandler.swift
//  MentalHealth
//
//  Created by PS Solutions on 9/16/18.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import Foundation
import UIKit

class NotificationHandler {
    static func receiveNoti(_ noti: NotiObject) {
        
        guard let navigation = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else {
            return
        }
        
        switch noti.type {
        case .news:
            let newVC = StoryboardManager.shared.instantiateNewsDetailViewContrller()
            newVC.newsId = "\(noti.id)"
            navigation.pushViewController(newVC, animated: true)

        case .thirdtyDay:
            let thirtyDayVC = StoryboardManager.shared.instantiateDayViewController()
            thirtyDayVC.dayId = noti.id
            navigation.pushViewController(thirtyDayVC, animated: true)

        case .emotion:
            let emotionVC = StoryboardManager.shared.instantiateChatViewController()
            navigation.pushViewController(emotionVC, animated: true)

        case .quiz:
            let quizVC = StoryboardManager.shared.instantiateQuizViewController()
            navigation.pushViewController(quizVC, animated: true)
            
        default:
            let newVC = StoryboardManager.shared.instantiateNewsViewContrller()
            navigation.pushViewController(newVC, animated: true)
        }
    }
}

struct NotiObject {
    var id : Int = 0
    var type: NotiType = .news
    var title: String = ""
    
    init(dict: [AnyHashable: Any]) {
        
        if let newId = dict["id"] as? String {
            self.id = Int(newId) ?? -1
        }
        
        if let type = dict["type"] as? String {
            self.type = NotiType(rawValue: Int(type) ?? 0) ?? .news
        }
        
        if let title = dict["title"] as? String {
            self.title = title
        }
    }
}

enum NotiType: Int {
    case news, thirdtyDay, emotion, quiz
}
