//
//  NotificationService.swift
//  NotificationService
//
//  Created by LE Minh Viet on 01/10/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UserNotifications

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
        
        self.title = dict["title"] as! String
        if let notiName = dict["name"] as? String {
            self.title += ": " + notiName
        }
        self.title = self.title.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)

        self.date = Date()
        self.isRead = false
    }
}

enum NotiType: Int, Codable {
    case news, thirtyDay, emotion, quiz
}

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        print("DID RECEIVE")
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        let userInfo = request.content.userInfo as! [String: Any]
        let noti = NotiObject(dict: userInfo)
        
        let groupDefaults = UserDefaults.init(suiteName: "group.crisp.mentalhealth.shinningmind")
        var nbBadge = groupDefaults?.integer(forKey: "nbBadge")
        
        let notificationRawDatas = groupDefaults?.value(forKey: "notificationDatas") as? Data
        var notificationDatas = Array<NotiObject>()
        
        
        if nbBadge == nil {
            nbBadge = 0
        }
        
        nbBadge = nbBadge! + 1
        
        if notificationRawDatas != nil {
            notificationDatas = try! PropertyListDecoder().decode(Array<NotiObject>.self, from: notificationRawDatas!)
        }
        
        notificationDatas.append(noti)
        
        groupDefaults?.set(nbBadge, forKey: "nbBadge")
        groupDefaults?.set(try? PropertyListEncoder().encode(notificationDatas), forKey: "notificationDatas")
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = noti.title
            
            bestAttemptContent.sound = .default
            bestAttemptContent.badge = nbBadge as NSNumber?
                        
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
