import Cocoa

class SettingsWindowController: NSWindowController {
    static var shared: SettingsWindowController?
    let showAuthoredCheckbox = NSButton(checkboxWithTitle: "Show PRs I authored", target: nil, action: nil)
    let showAssignedCheckbox = NSButton(checkboxWithTitle: "Show PRs assigned to me", target: nil, action: nil)
    let autoRefreshCheckbox = NSButton(checkboxWithTitle: "Enable auto-refresh", target: nil, action: nil)
    let refreshIntervalField = NSTextField(string: "")
    let emailField = NSTextField(string: "")
    let patField = PasteableSecureTextField(string: "")
    
    // Notification controls
    let notificationsEnabledCheckbox = NSButton(checkboxWithTitle: "Enable notifications", target: nil, action: nil)
    let newPRNotificationsCheckbox = NSButton(checkboxWithTitle: "New PR assignments", target: nil, action: nil)
    let dailyRemindersCheckbox = NSButton(checkboxWithTitle: "Daily reminders", target: nil, action: nil)
    let intervalRemindersCheckbox = NSButton(checkboxWithTitle: "Interval reminders", target: nil, action: nil)
    let smartNotificationsCheckbox = NSButton(checkboxWithTitle: "Only when I have pending PRs", target: nil, action: nil)
    let includePRCountCheckbox = NSButton(checkboxWithTitle: "Include PR count", target: nil, action: nil)
    let dailyReminderTimePicker = NSDatePicker()
    let intervalHoursField = NSTextField(string: "")
    
    private let settingsManager = SettingsManager.shared
    
    override init(window: NSWindow?) {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 420, height: 600),
                              styleMask: [.titled, .closable],
                              backing: .buffered, defer: false)
        window.title = "Settings"
        window.center()
        super.init(window: window)
        let contentView = window.contentView!
        
        // Main vertical stack
        let mainStack = NSStackView()
        mainStack.orientation = .vertical
        mainStack.spacing = 24
        mainStack.edgeInsets = NSEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.alignment = .leading
        contentView.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
        
        // --- Credentials Section ---
        let credentialsStack = NSStackView()
        credentialsStack.orientation = .vertical
        credentialsStack.spacing = 8
        credentialsStack.alignment = .leading
        let credentialsLabel = NSTextField(labelWithString: "Credentials")
        credentialsLabel.font = .boldSystemFont(ofSize: 14)
        credentialsStack.addArrangedSubview(credentialsLabel)
        let emailRow = NSStackView(views: [NSTextField(labelWithString: "Azure DevOps email:"), emailField])
        emailRow.orientation = .horizontal
        emailRow.spacing = 8
        emailRow.alignment = .firstBaseline
        credentialsStack.addArrangedSubview(emailRow)
        let patRow = NSStackView(views: [NSTextField(labelWithString: "PAT/token:"), patField])
        patRow.orientation = .horizontal
        patRow.spacing = 8
        patRow.alignment = .firstBaseline
        credentialsStack.addArrangedSubview(patRow)
        mainStack.addArrangedSubview(credentialsStack)
        
        // --- Display Section ---
        let displayStack = NSStackView()
        displayStack.orientation = .vertical
        displayStack.spacing = 8
        displayStack.alignment = .leading
        let displayLabel = NSTextField(labelWithString: "Display")
        displayLabel.font = .boldSystemFont(ofSize: 14)
        displayStack.addArrangedSubview(displayLabel)
        displayStack.addArrangedSubview(showAuthoredCheckbox)
        displayStack.addArrangedSubview(showAssignedCheckbox)
        displayStack.addArrangedSubview(autoRefreshCheckbox)
        let refreshRow = NSStackView(views: [NSTextField(labelWithString: "Refresh interval (minutes):"), refreshIntervalField])
        refreshRow.orientation = .horizontal
        refreshRow.spacing = 8
        refreshRow.alignment = .firstBaseline
        displayStack.addArrangedSubview(refreshRow)
        mainStack.addArrangedSubview(displayStack)
        
        // --- Notifications Section ---
        let notificationsStack = NSStackView()
        notificationsStack.orientation = .vertical
        notificationsStack.spacing = 8
        notificationsStack.alignment = .leading
        let notificationsLabel = NSTextField(labelWithString: "Notifications")
        notificationsLabel.font = .boldSystemFont(ofSize: 14)
        notificationsStack.addArrangedSubview(notificationsLabel)
        notificationsStack.addArrangedSubview(notificationsEnabledCheckbox)
        notificationsStack.addArrangedSubview(newPRNotificationsCheckbox)
        notificationsStack.addArrangedSubview(dailyRemindersCheckbox)
        let dailyTimeRow = NSStackView(views: [NSTextField(labelWithString: "Daily reminder time:"), dailyReminderTimePicker])
        dailyTimeRow.orientation = .horizontal
        dailyTimeRow.spacing = 8
        dailyTimeRow.alignment = .firstBaseline
        notificationsStack.addArrangedSubview(dailyTimeRow)
        notificationsStack.addArrangedSubview(intervalRemindersCheckbox)
        let intervalRow = NSStackView(views: [NSTextField(labelWithString: "Interval (hours):"), intervalHoursField])
        intervalRow.orientation = .horizontal
        intervalRow.spacing = 8
        intervalRow.alignment = .firstBaseline
        notificationsStack.addArrangedSubview(intervalRow)
        notificationsStack.addArrangedSubview(smartNotificationsCheckbox)
        notificationsStack.addArrangedSubview(includePRCountCheckbox)
        mainStack.addArrangedSubview(notificationsStack)
        
        // --- Initial Values and Targets ---
        emailField.stringValue = settingsManager.azureEmail
        patField.stringValue = settingsManager.azurePAT
        showAuthoredCheckbox.state = settingsManager.showAuthoredPRs ? .on : .off
        showAssignedCheckbox.state = settingsManager.showAssignedPRs ? .on : .off
        autoRefreshCheckbox.state = settingsManager.autoRefreshEnabled ? .on : .off
        refreshIntervalField.stringValue = "\(settingsManager.refreshInterval / 60)"
        notificationsEnabledCheckbox.state = settingsManager.notificationsEnabled ? .on : .off
        newPRNotificationsCheckbox.state = settingsManager.newPRNotifications ? .on : .off
        dailyRemindersCheckbox.state = settingsManager.dailyReminders ? .on : .off
        intervalRemindersCheckbox.state = settingsManager.intervalReminders ? .on : .off
        smartNotificationsCheckbox.state = settingsManager.smartNotifications ? .on : .off
        includePRCountCheckbox.state = settingsManager.includePRCount ? .on : .off
        dailyReminderTimePicker.dateValue = settingsManager.dailyReminderTime
        intervalHoursField.stringValue = "\(settingsManager.intervalHours)"
        
        // --- Targets ---
        emailField.target = self
        emailField.action = #selector(textFieldChanged)
        patField.target = self
        patField.action = #selector(textFieldChanged)
        showAuthoredCheckbox.target = self
        showAuthoredCheckbox.action = #selector(toggleChanged)
        showAssignedCheckbox.target = self
        showAssignedCheckbox.action = #selector(toggleChanged)
        autoRefreshCheckbox.target = self
        autoRefreshCheckbox.action = #selector(toggleChanged)
        refreshIntervalField.target = self
        refreshIntervalField.action = #selector(textFieldChanged)
        notificationsEnabledCheckbox.target = self
        notificationsEnabledCheckbox.action = #selector(notificationToggleChanged)
        newPRNotificationsCheckbox.target = self
        newPRNotificationsCheckbox.action = #selector(notificationToggleChanged)
        dailyRemindersCheckbox.target = self
        dailyRemindersCheckbox.action = #selector(notificationToggleChanged)
        intervalRemindersCheckbox.target = self
        intervalRemindersCheckbox.action = #selector(notificationToggleChanged)
        smartNotificationsCheckbox.target = self
        smartNotificationsCheckbox.action = #selector(notificationToggleChanged)
        includePRCountCheckbox.target = self
        includePRCountCheckbox.action = #selector(notificationToggleChanged)
        dailyReminderTimePicker.target = self
        dailyReminderTimePicker.action = #selector(timePickerChanged)
        intervalHoursField.target = self
        intervalHoursField.action = #selector(intervalHoursChanged)
        
        // --- Enable/disable fields ---
        refreshIntervalField.isEnabled = autoRefreshCheckbox.state == .on
        newPRNotificationsCheckbox.isEnabled = notificationsEnabledCheckbox.state == .on
        dailyRemindersCheckbox.isEnabled = notificationsEnabledCheckbox.state == .on
        intervalRemindersCheckbox.isEnabled = notificationsEnabledCheckbox.state == .on
        smartNotificationsCheckbox.isEnabled = notificationsEnabledCheckbox.state == .on
        includePRCountCheckbox.isEnabled = notificationsEnabledCheckbox.state == .on
        dailyReminderTimePicker.isEnabled = notificationsEnabledCheckbox.state == .on && dailyRemindersCheckbox.state == .on
        intervalHoursField.isEnabled = notificationsEnabledCheckbox.state == .on && intervalRemindersCheckbox.state == .on
        
        // --- Text field editability ---
        emailField.isEditable = true
        emailField.isSelectable = true
        patField.isEditable = true
        patField.isSelectable = true
        refreshIntervalField.isEditable = true
        refreshIntervalField.isSelectable = true
        intervalHoursField.isEditable = true
        intervalHoursField.isSelectable = true
        
        // Set window delegate to handle closing
        window.delegate = self
        
        dailyReminderTimePicker.datePickerElements = .hourMinute
        dailyReminderTimePicker.datePickerMode = .single
        
        refreshIntervalField.widthAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        intervalHoursField.widthAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        emailField.widthAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
        patField.widthAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @objc func toggleChanged() {
        settingsManager.showAuthoredPRs = showAuthoredCheckbox.state == .on
        settingsManager.showAssignedPRs = showAssignedCheckbox.state == .on
        settingsManager.autoRefreshEnabled = autoRefreshCheckbox.state == .on
        refreshIntervalField.isEnabled = autoRefreshCheckbox.state == .on
        (NSApp.delegate as? AppDelegate)?.buildMenu()
        (NSApp.delegate as? AppDelegate)?.startRefreshTimer()
    }
    
    @objc func notificationToggleChanged() {
        settingsManager.notificationsEnabled = notificationsEnabledCheckbox.state == .on
        settingsManager.newPRNotifications = newPRNotificationsCheckbox.state == .on
        settingsManager.dailyReminders = dailyRemindersCheckbox.state == .on
        settingsManager.intervalReminders = intervalRemindersCheckbox.state == .on
        settingsManager.smartNotifications = smartNotificationsCheckbox.state == .on
        settingsManager.includePRCount = includePRCountCheckbox.state == .on
        newPRNotificationsCheckbox.isEnabled = notificationsEnabledCheckbox.state == .on
        dailyRemindersCheckbox.isEnabled = notificationsEnabledCheckbox.state == .on
        intervalRemindersCheckbox.isEnabled = notificationsEnabledCheckbox.state == .on
        smartNotificationsCheckbox.isEnabled = notificationsEnabledCheckbox.state == .on
        includePRCountCheckbox.isEnabled = notificationsEnabledCheckbox.state == .on
        dailyReminderTimePicker.isEnabled = notificationsEnabledCheckbox.state == .on && dailyRemindersCheckbox.state == .on
        intervalHoursField.isEnabled = notificationsEnabledCheckbox.state == .on && intervalRemindersCheckbox.state == .on
        if notificationsEnabledCheckbox.state == .on {
            NotificationManager.shared.requestNotificationPermissions { granted in
                if granted {
                    DispatchQueue.main.async {
                        NotificationManager.shared.updateNotificationSchedules()
                    }
                }
            }
        } else {
            NotificationManager.shared.clearAllNotifications()
        }
        (NSApp.delegate as? AppDelegate)?.buildMenu()
    }
    
    @objc func timePickerChanged() {
        settingsManager.dailyReminderTime = dailyReminderTimePicker.dateValue
        if settingsManager.notificationsEnabled {
            NotificationManager.shared.updateNotificationSchedules()
        }
    }
    
    @objc func textFieldChanged() {
        if let intervalMinutes = Int(refreshIntervalField.stringValue) {
            settingsManager.refreshInterval = intervalMinutes * 60
        }
        settingsManager.azureEmail = emailField.stringValue
        settingsManager.azurePAT = patField.stringValue
        (NSApp.delegate as? AppDelegate)?.buildMenu()
        // Only start refresh timer if credentials are present
        if !settingsManager.azureEmail.isEmpty && !settingsManager.azurePAT.isEmpty {
            (NSApp.delegate as? AppDelegate)?.startRefreshTimer()
        }
    }
    
    @objc func intervalHoursChanged() {
        if let intervalHours = Int(intervalHoursField.stringValue) {
            settingsManager.intervalHours = intervalHours
        }
        (NSApp.delegate as? AppDelegate)?.buildMenu()
        (NSApp.delegate as? AppDelegate)?.startRefreshTimer()
    }
    
    override func cancelOperation(_ sender: Any?) {
        self.close()
    }
}

extension SettingsWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        settingsManager.showAuthoredPRs = showAuthoredCheckbox.state == .on
        settingsManager.showAssignedPRs = showAssignedCheckbox.state == .on
        settingsManager.autoRefreshEnabled = autoRefreshCheckbox.state == .on
        if let intervalMinutes = Int(refreshIntervalField.stringValue) {
            settingsManager.refreshInterval = intervalMinutes * 60
        }
        settingsManager.azureEmail = emailField.stringValue
        settingsManager.azurePAT = patField.stringValue
        settingsManager.notificationsEnabled = notificationsEnabledCheckbox.state == .on
        settingsManager.newPRNotifications = newPRNotificationsCheckbox.state == .on
        settingsManager.dailyReminders = dailyRemindersCheckbox.state == .on
        settingsManager.intervalReminders = intervalRemindersCheckbox.state == .on
        settingsManager.smartNotifications = smartNotificationsCheckbox.state == .on
        settingsManager.includePRCount = includePRCountCheckbox.state == .on
        settingsManager.dailyReminderTime = dailyReminderTimePicker.dateValue
        if let intervalHours = Int(intervalHoursField.stringValue) {
            settingsManager.intervalHours = intervalHours
        }
        (NSApp.delegate as? AppDelegate)?.buildMenu()
        // Only start refresh timer if credentials are present
        if !settingsManager.azureEmail.isEmpty && !settingsManager.azurePAT.isEmpty {
            (NSApp.delegate as? AppDelegate)?.startRefreshTimer()
        }
        SettingsWindowController.shared = nil
        // If shown modally, stop the modal session
        NSApp.stopModal()
    }
} 
