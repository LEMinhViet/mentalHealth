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

        case .thirtyDay:
            var thirtyDayVC: ThirtyDaysViewController?
            for controller in navigation.viewControllers as Array {
                if controller.isKind(of: ThirtyDaysViewController.self) {
                    thirtyDayVC = controller as? ThirtyDaysViewController
                    break
                }
            }
            
            let dayVC = StoryboardManager.shared.instantiateDayViewController()
            dayVC.dayId = noti.id
            navigation.pushViewController(dayVC, animated: true)
            
            // Update read state
            let apiUrl: String = Constants.url + Constants.apiPrefix + "/update_day"
            guard let updateUrl = URL(string: apiUrl) else { return }
            
            let defaults = UserDefaults.standard
            let userId = defaults.integer(forKey: "loggedUserId")
            
            let updateData: [String: Any] = [
                "user_id": userId,
                "day_id": noti.id
            ]
            
            guard let httpBody = try? JSONSerialization.data(withJSONObject: updateData, options: []) else {
                return
            }
            
            var updateUrlRequest = URLRequest(url: updateUrl)
            updateUrlRequest.httpMethod = "POST"
            updateUrlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            updateUrlRequest.httpBody = httpBody
            
            URLSession.shared.dataTask(with: updateUrlRequest) { (data, response, error)
                in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                guard let data = data else { return }
                
                do {
                    let updateResult = try JSONDecoder().decode(UpdateResult.self, from: data)

                    //Get back to the main queue
                    DispatchQueue.main.async {
                        if thirtyDayVC != nil {
                            thirtyDayVC?.updateCellContent(
                                row: updateResult.day_id!,
                                section: 0,
                                type: ThirtyDaysCell.ThirtyDayEnum.PassedDay.rawValue)
                        }
                    }
                } catch let jsonError {
                    print(jsonError)
                }
            }.resume()

        case .emotion:
            let emotionVC = StoryboardManager.shared.instantiateChatViewController()
            navigation.pushViewController(emotionVC, animated: true)

        case .quiz:
            let quizVC = StoryboardManager.shared.instantiateQuizViewController()
//            quizVC.showLevel(noti.id)
            navigation.pushViewController(quizVC, animated: true)
            
        case .az:
            let azVC = StoryboardManager.shared.instantiateAZViewController()
            navigation.pushViewController(azVC, animated: true)
        
        case .video:
            let videoVC = StoryboardManager.shared.instantiateVideoViewController()
            navigation.pushViewController(videoVC, animated: true)
            
        default:
            let newVC = StoryboardManager.shared.instantiateNewsViewContrller()
            navigation.pushViewController(newVC, animated: true)
        }
    }
}

struct NotiObject: Codable {
    var id : Int = 0
    var type: NotiType = .news
    var title: String = ""
    var date: Date?
    var isRead: Bool?
    
    init(dict: [AnyHashable: Any]) {
        
        if let newId = dict["id"] as? String {
            self.id = Int(newId) ?? -1
        }
        
        if let type = dict["type"] as? String {
            self.type = NotiType(rawValue: Int(type) ?? 0) ?? .news
        }
        
        if let aps = dict["aps"] as? [String: Any] {
            if let alertObj = aps["alert"] as? [String: Any] {
                if let title = alertObj["title"] as? String {
                    self.title = title.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                }
            }
        }
        
        self.date = Date()
        self.isRead = false
    }
}

enum NotiType: Int, Codable {
    case news, thirtyDay, emotion, quiz, az, video
}
