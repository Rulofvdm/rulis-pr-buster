import Foundation

struct AppSettings: Codable {
    var azureEmail: String
    var azurePAT: String
    var showAuthoredPRs: Bool
    var showAssignedPRs: Bool
    var refreshInterval: Int // in seconds, but UI will show minutes
    var autoRefreshEnabled: Bool
    
    // Notification settings
    var notificationsEnabled: Bool
    var newPRNotifications: Bool
    var dailyReminders: Bool
    var intervalReminders: Bool
    var dailyReminderTime: Date // Time of day for daily reminders
    var intervalHours: Int // Hours between interval reminders
    var smartNotifications: Bool // Only show when there are pending PRs
    var includePRCount: Bool // Include PR count in notifications
    
    // New fields for Azure DevOps organization and project
    var organization: String
    var project: String
    
    // Display settings
    var showShortTitles: Bool // Show only first 8 characters of PR titles
    var showTargetBranch: Bool // Show target branch in dropdown
    
    static let `default` = AppSettings(
        azureEmail: "",
        azurePAT: "",
        showAuthoredPRs: true,
        showAssignedPRs: true,
        refreshInterval: 60, // 1 minute default
        autoRefreshEnabled: true,
        notificationsEnabled: false,
        newPRNotifications: true,
        dailyReminders: true,
        intervalReminders: false,
        dailyReminderTime: Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(),
        intervalHours: 4,
        smartNotifications: true,
        includePRCount: true,
        organization: "jobjack", // Default value
        project: "Platform",    // Default value
        showShortTitles: false,  // Default to showing full titles
        showTargetBranch: true    // Default to showing target branch
    )
} 