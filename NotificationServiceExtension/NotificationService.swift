//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by Seb Vidal on 24/08/2021.
//

import UserNotifications
import FirebaseMessaging

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        self.contentHandler = contentHandler
        
        bestAttemptContent = request.content.mutableCopy() as? UNMutableNotificationContent
        
        guard let bestAttemptContent = bestAttemptContent else {
            
            return
            
        }
        
        FIRMessagingExtensionHelper().populateNotificationContent(
            bestAttemptContent,
            withContentHandler: contentHandler)
        
    }
    
    override func serviceExtensionTimeWillExpire() {
        
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            
            contentHandler(bestAttemptContent)
            
        }
        
    }

}
