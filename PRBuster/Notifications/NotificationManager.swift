import Foundation
import UserNotifications
import Cocoa

class NotificationManager: NSObject {
    static let shared = NotificationManager()
    private let settingsManager = SettingsManager.shared
    private let center = UNUserNotificationCenter.current()
    
    private override init() {
        super.init()
    }
    
    // MARK: - Permission Management
    
    func requestNotificationPermissions(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification permission error: \(error)")
                }
                completion(granted)
            }
        }
    }
    
    func checkNotificationPermissions(completion: @escaping (Bool) -> Void) {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                let authorized = settings.authorizationStatus == .authorized
                completion(authorized)
            }
        }
    }
    
    // MARK: - Notification Scheduling
    
    func scheduleDailyReminder() {
        guard settingsManager.notificationsEnabled && settingsManager.dailyReminders else {
            removeDailyReminder()
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "PR Review Reminder"
        
        let pendingPRs = getPendingPRCount()
        if settingsManager.smartNotifications && pendingPRs == 0 {
            return // Don't schedule if no pending PRs and smart notifications enabled
        }
        
        if settingsManager.includePRCount && pendingPRs > 0 {
            content.body = "You have \(pendingPRs) pull request\(pendingPRs == 1 ? "" : "s") to review"
        } else {
            content.body = "Time to review your pull requests"
        }
        
        content.sound = .default
        
        // Create date components for the daily time
        let calendar = Calendar.current
        let reminderTime = settingsManager.dailyReminderTime
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling daily reminder: \(error)")
            }
        }
    }
    
    func scheduleIntervalReminder() {
        guard settingsManager.notificationsEnabled && settingsManager.intervalReminders else {
            removeIntervalReminder()
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "PR Review Check-in"
        
        let pendingPRs = getPendingPRCount()
        if settingsManager.smartNotifications && pendingPRs == 0 {
            return // Don't schedule if no pending PRs and smart notifications enabled
        }
        
        if settingsManager.includePRCount && pendingPRs > 0 {
            content.body = "You have \(pendingPRs) pull request\(pendingPRs == 1 ? "" : "s") to review"
        } else {
            content.body = "Check your pull requests"
        }
        
        content.sound = .default
        
        // Schedule for every X hours
        let interval = TimeInterval(settingsManager.intervalHours * 3600) // Convert hours to seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
        let request = UNNotificationRequest(identifier: "intervalReminder", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling interval reminder: \(error)")
            }
        }
    }
    
    func removeDailyReminder() {
        center.removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
    }
    
    func removeIntervalReminder() {
        center.removePendingNotificationRequests(withIdentifiers: ["intervalReminder"])
    }
    
    func removeAllScheduledNotifications() {
        center.removeAllPendingNotificationRequests()
    }
    
    // MARK: - New PR Notifications
    
    func showNewPRNotification(pr: PullRequest) {
        guard settingsManager.notificationsEnabled && settingsManager.newPRNotifications else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "New PR Assigned"
        content.body = "\(pr.title) by \(pr.createdBy.displayName)"
        content.sound = .default
        
        // Add action to open the PR
        let openAction = UNNotificationAction(
            identifier: "OPEN_PR",
            title: "Open PR",
            options: [.foreground]
        )
        
        let category = UNNotificationCategory(
            identifier: "NEW_PR",
            actions: [openAction],
            intentIdentifiers: [],
            options: []
        )
        
        center.setNotificationCategories([category])
        content.categoryIdentifier = "NEW_PR"
        content.userInfo = ["prUrl": pr.webURL?.absoluteString ?? ""]
        
        let request = UNNotificationRequest(
            identifier: "newPR_\(pr.pullRequestId)",
            content: content,
            trigger: nil // Show immediately
        )
        
        center.add(request) { error in
            if let error = error {
                print("Error showing new PR notification: \(error)")
            }
        }
    }
    
    func showBatchNewPRNotification(count: Int) {
        guard settingsManager.notificationsEnabled && settingsManager.newPRNotifications else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "New Pull Requests"
        content.body = "You have \(count) new pull request\(count == 1 ? "" : "s") assigned to you"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "batchNewPRs_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        center.add(request) { error in
            if let error = error {
                print("Error showing batch PR notification: \(error)")
            }
        }
    }
    
    // MARK: - Smart Notification Logic
    
    private func getPendingPRCount() -> Int {
        // Get current PR count from AppDelegate
        return (NSApp.delegate as? AppDelegate)?.getPendingPRCount() ?? 0
    }
    
    // MARK: - Notification Management
    
    func updateNotificationSchedules() {
        scheduleDailyReminder()
        scheduleIntervalReminder()
    }
    
    func clearAllNotifications() {
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification actions
        if response.actionIdentifier == "OPEN_PR" {
            if let prUrlString = response.notification.request.content.userInfo["prUrl"] as? String,
               let url = URL(string: prUrlString) {
                NSWorkspace.shared.open(url)
            }
        }
        
        completionHandler()
    }
} 