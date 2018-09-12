//
//  AppDelegate.swift
//  MentalHealth
//
//  Created by LE Minh Viet on 25/06/2018.
//  Copyright © 2018 LE Minh Viet. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

struct LogResult: Codable {
    let message: String
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
//        if let messageID = userInfo {
//            print("Message ID: \(messageID)")
//        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }

    
    // The callback to handle data message received via FCM for devices running iOS 10 or above.
    func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        FirebaseApp.configure()
        
        // Select viewcontroller to start
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let defaults = UserDefaults.standard
        let isLoggedIn = defaults.bool(forKey: "isUserLoggedIn")
        print ("IS USER LOGGED ", isLoggedIn)
        if isLoggedIn {
            let nvc = storyboard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
            
            self.window?.rootViewController = nvc
            self.window?.makeKeyAndVisible()
            
            self.logTime(action: Constants.TO_FOREGROUND)
        }
        else {
            let lc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            
            self.window?.rootViewController = lc
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        logTime(action: Constants.TO_BACKGROUND)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        logTime(action: Constants.TO_FOREGROUND)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        logTime(action: Constants.TO_BACKGROUND)
    }

    func logTime(action: Int) {
        let apiUrl: String = Constants.url + Constants.apiPrefix + "/logtime"
        guard let loginUrl = URL(string: apiUrl) else { return }
        
        let defaults = UserDefaults.standard
        let userId = defaults.integer(forKey: "loggedUserId")
        var deviceId = defaults.string(forKey: "loggedDeviceId") ?? ""
        
        if deviceId == "" {
            deviceId = (UIDevice.current.identifierForVendor?.uuidString)!
        }
        
        let logData: [String: Any] = [
            "user_id": userId,
            "action": action,
            "device_id": deviceId
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: logData, options: []) else {
            return
        }
        
        var logUrlRequest = URLRequest(url: loginUrl)
        logUrlRequest.httpMethod = "POST"
        logUrlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        logUrlRequest.httpBody = httpBody
        
        URLSession.shared.dataTask(with: logUrlRequest) { (data, response, error)
            in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let logResult = try JSONDecoder().decode(LogResult.self, from: data)
                
                //Get back to the main queue
                DispatchQueue.main.async {
                    print("LOG ", action, logResult)
                    if logResult.message == "success" {
                        
                    }
                    else {
                        
                    }
                }
            } catch let jsonError {
                print(jsonError)
                DispatchQueue.main.async {
                    
                }
            }
        }.resume()
    }
}

