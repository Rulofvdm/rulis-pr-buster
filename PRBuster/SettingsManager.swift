import Foundation

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var settings: AppSettings {
        didSet {
            saveSettings()
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let settingsKey = "AppSettings"
    
    private init() {
        // Initialize with default settings first, then load actual settings
        self.settings = AppSettings.default
        self.settings = loadSettings()
    }
    
    // MARK: - Settings Access
    
    var azureEmail: String {
        get { settings.azureEmail }
        set { settings.azureEmail = newValue }
    }
    
    var azurePAT: String {
        get { settings.azurePAT }
        set { settings.azurePAT = newValue }
    }
    
    var showAuthoredPRs: Bool {
        get { settings.showAuthoredPRs }
        set { settings.showAuthoredPRs = newValue }
    }
    
    var showAssignedPRs: Bool {
        get { settings.showAssignedPRs }
        set { settings.showAssignedPRs = newValue }
    }
    
    var refreshInterval: Int {
        get { settings.refreshInterval }
        set { settings.refreshInterval = newValue }
    }
    
    var autoRefreshEnabled: Bool {
        get { settings.autoRefreshEnabled }
        set { settings.autoRefreshEnabled = newValue }
    }
    
    // MARK: - Notification Settings
    
    var notificationsEnabled: Bool {
        get { settings.notificationsEnabled }
        set { settings.notificationsEnabled = newValue }
    }
    
    var newPRNotifications: Bool {
        get { settings.newPRNotifications }
        set { settings.newPRNotifications = newValue }
    }
    
    var dailyReminders: Bool {
        get { settings.dailyReminders }
        set { settings.dailyReminders = newValue }
    }
    
    var intervalReminders: Bool {
        get { settings.intervalReminders }
        set { settings.intervalReminders = newValue }
    }
    
    var dailyReminderTime: Date {
        get { settings.dailyReminderTime }
        set { settings.dailyReminderTime = newValue }
    }
    
    var intervalHours: Int {
        get { settings.intervalHours }
        set { settings.intervalHours = newValue }
    }
    
    var smartNotifications: Bool {
        get { settings.smartNotifications }
        set { settings.smartNotifications = newValue }
    }
    
    var includePRCount: Bool {
        get { settings.includePRCount }
        set { settings.includePRCount = newValue }
    }
    
    var organization: String {
        get { settings.organization }
        set { settings.organization = newValue }
    }
    
    var project: String {
        get { settings.project }
        set { settings.project = newValue }
    }
    
    var showShortTitles: Bool {
        get { settings.showShortTitles }
        set { settings.showShortTitles = newValue }
    }
    
    var isConfigured: Bool {
        !settings.azureEmail.isEmpty && !settings.azurePAT.isEmpty
    }
    
    // MARK: - Persistence
    
    private func loadSettings() -> AppSettings {
        guard let data = userDefaults.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            // Fallback to UserDefaults for backward compatibility
            return AppSettings(
                azureEmail: userDefaults.string(forKey: "azureEmail") ?? "",
                azurePAT: userDefaults.string(forKey: "azurePAT") ?? "",
                showAuthoredPRs: userDefaults.object(forKey: "showAuthoredPRs") as? Bool ?? true,
                showAssignedPRs: userDefaults.object(forKey: "showAssignedPRs") as? Bool ?? true,
                refreshInterval: userDefaults.object(forKey: "refreshInterval") as? Int ?? 60,
                autoRefreshEnabled: userDefaults.object(forKey: "autoRefreshEnabled") as? Bool ?? true,
                notificationsEnabled: userDefaults.object(forKey: "notificationsEnabled") as? Bool ?? false,
                newPRNotifications: userDefaults.object(forKey: "newPRNotifications") as? Bool ?? true,
                dailyReminders: userDefaults.object(forKey: "dailyReminders") as? Bool ?? true,
                intervalReminders: userDefaults.object(forKey: "intervalReminders") as? Bool ?? false,
                dailyReminderTime: userDefaults.object(forKey: "dailyReminderTime") as? Date ?? Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(),
                intervalHours: userDefaults.object(forKey: "intervalHours") as? Int ?? 4,
                smartNotifications: userDefaults.object(forKey: "smartNotifications") as? Bool ?? true,
                includePRCount: userDefaults.object(forKey: "includePRCount") as? Bool ?? true,
                organization: userDefaults.string(forKey: "organization") ?? "jobjack",
                project: userDefaults.string(forKey: "project") ?? "Platform",
                showShortTitles: userDefaults.object(forKey: "showShortTitles") as? Bool ?? false
            )
        }
        return settings
    }
    
    private func saveSettings() {
        do {
            let data = try JSONEncoder().encode(settings)
            userDefaults.set(data, forKey: settingsKey)
            
            // Also save to legacy keys for backward compatibility
            userDefaults.set(settings.azureEmail, forKey: "azureEmail")
            userDefaults.set(settings.azurePAT, forKey: "azurePAT")
            userDefaults.set(settings.showAuthoredPRs, forKey: "showAuthoredPRs")
            userDefaults.set(settings.showAssignedPRs, forKey: "showAssignedPRs")
            userDefaults.set(settings.refreshInterval, forKey: "refreshInterval")
            userDefaults.set(settings.autoRefreshEnabled, forKey: "autoRefreshEnabled")
            userDefaults.set(settings.organization, forKey: "organization")
            userDefaults.set(settings.project, forKey: "project")
            userDefaults.set(settings.showShortTitles, forKey: "showShortTitles")
            
            userDefaults.synchronize()
        } catch {
            print("Error saving settings: \(error)")
        }
    }
} 