//
//  NotificationPublisher.swift
//  FoodExp Manager
//
//  Created by Hanzhuo Gong on 11/28/22.
//

import Foundation
import UserNotifications
import UIKit

class NotificationPublisher: NSObject {
    func sendNotification(title: String,
                          body: String,
                          badge: Int?,
                          delayInterval: Int?) {
        
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = body
        
        var delayTimeTrigger: UNTimeIntervalNotificationTrigger?
        
        if let delayInterval = delayInterval {
            delayTimeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(delayInterval), repeats: false)
        }
        
        if let badge = badge {
            var currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
            currentBadgeCount += badge
            notificationContent.badge = NSNumber(integerLiteral: currentBadgeCount)
        }
        
        notificationContent.sound = UNNotificationSound.default
        
        UNUserNotificationCenter.current().delegate = self
        
        let uuidString = UUID().uuidString
        //let date = Date().addingTimeInterval(5)
        //let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        //replace the identifier with the uuidString later
        let request = UNNotificationRequest(identifier: uuidString, content: notificationContent, trigger: delayTimeTrigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
            
        }
    }
}

extension NotificationPublisher: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("The notification is about to be presented")
        completionHandler([.alert , .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let identifer = response.actionIdentifier
        
        switch identifer {
        case UNNotificationDismissActionIdentifier:
            print("The notification was dismissed")
            completionHandler()

        case UNNotificationDismissActionIdentifier:
            print("The user opened the app from the notification")
            completionHandler()
        
        default:
            print("notification default case was called")
        }
    }
}
