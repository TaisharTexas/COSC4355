//
//  NotificationManager.swift
//  XrayClassifier
//
//  Created by Ioannis Pavlidis on 11/12/25.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    // Call this once (e.g., at app launch)
    //UNUserNotificationCenter is a system notification manager class. You use it from the SwiftUI code to schedule notifications.
    
    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("🔴 Notification authorization error:", error)
            } else {
                print("🔔 Notification permission granted:", granted)
            }
        }
    }

    /// Schedule a repeating notification every 60 seconds with the given text.
    /// Each call updates (replaces) the previous repeating notification.
    func scheduleLastClassificationNotification(text: String) {
        let center = UNUserNotificationCenter.current()

        // Remove any previous "lastClassification" notifications so we only have one.
        center.removePendingNotificationRequests(withIdentifiers: ["lastClassification"])

        let content = UNMutableNotificationContent()
        content.title = "X-ray Classifier"
        content.body = text
        content.sound = .default

        // Minimum is 60 seconds when repeats = true
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)

        let request = UNNotificationRequest(
            identifier: "lastClassification",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("🔴 Error scheduling notification:", error)
            } else {
                print("✅ Scheduled repeating notification with text: \(text)")
            }
        }
    }
}
