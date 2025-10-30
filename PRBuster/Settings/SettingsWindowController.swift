import Cocoa

class SettingsWindowController: NSWindowController {
    static var shared: SettingsWindowController?
    let showAuthoredCheckbox = NSButton(checkboxWithTitle: "Show PRs I authored", target: nil, action: nil)
    let showAssignedCheckbox = NSButton(checkboxWithTitle: "Show PRs assigned to me", target: nil, action: nil)
    let autoRefreshCheckbox = NSButton(checkboxWithTitle: "Enable auto-refresh", target: nil, action: nil)
    let showShortTitlesCheckbox = NSButton(checkboxWithTitle: "Show only first 8 characters of titles", target: nil, action: nil)
    let refreshIntervalField = NSTextField(string: "")
    let emailField = NSTextField(string: "")
    let organizationField = NSTextField(string: "")
    let projectField = NSTextField(string: "")
    let patField = PasteableSecureTextField(string: "")
    let tokenValidationIcon = NSImageView()
    let tokenValidationTooltip = NSTextField(labelWithString: "")
    
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
        let orgRow = NSStackView(views: [NSTextField(labelWithString: "Organization:"), organizationField])
        orgRow.orientation = .horizontal
        orgRow.spacing = 8
        orgRow.alignment = .firstBaseline
        credentialsStack.addArrangedSubview(orgRow)
        let projRow = NSStackView(views: [NSTextField(labelWithString: "Project:"), projectField])
        projRow.orientation = .horizontal
        projRow.spacing = 8
        projRow.alignment = .firstBaseline
        credentialsStack.addArrangedSubview(projRow)
        // Token validation section - icon next to PAT field
        let patRowWithValidation = NSStackView(views: [NSTextField(labelWithString: "PAT/token:"), patField, tokenValidationIcon])
        patRowWithValidation.orientation = .horizontal
        patRowWithValidation.spacing = 8
        patRowWithValidation.alignment = .firstBaseline
        credentialsStack.addArrangedSubview(patRowWithValidation)
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
        displayStack.addArrangedSubview(showShortTitlesCheckbox)
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
        organizationField.stringValue = settingsManager.organization
        projectField.stringValue = settingsManager.project
        patField.stringValue = settingsManager.azurePAT
        showAuthoredCheckbox.state = settingsManager.showAuthoredPRs ? .on : .off
        showAssignedCheckbox.state = settingsManager.showAssignedPRs ? .on : .off
        autoRefreshCheckbox.state = settingsManager.autoRefreshEnabled ? .on : .off
        showShortTitlesCheckbox.state = settingsManager.showShortTitles ? .on : .off
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
        organizationField.target = self
        organizationField.action = #selector(textFieldChanged)
        projectField.target = self
        projectField.action = #selector(textFieldChanged)
        patField.target = self
        patField.action = #selector(textFieldChanged)
        showAuthoredCheckbox.target = self
        showAuthoredCheckbox.action = #selector(toggleChanged)
        showAssignedCheckbox.target = self
        showAssignedCheckbox.action = #selector(toggleChanged)
        autoRefreshCheckbox.target = self
        autoRefreshCheckbox.action = #selector(toggleChanged)
        showShortTitlesCheckbox.target = self
        showShortTitlesCheckbox.action = #selector(toggleChanged)
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
        
        // --- Setup token validation icon ---
        setupTokenValidationIcon()
        
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
        organizationField.isEditable = true
        organizationField.isSelectable = true
        projectField.isEditable = true
        projectField.isSelectable = true
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
        settingsManager.showShortTitles = showShortTitlesCheckbox.state == .on
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
        settingsManager.organization = organizationField.stringValue
        settingsManager.project = projectField.stringValue
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
    
    private func setupTokenValidationIcon() {
        // Configure the validation icon
        tokenValidationIcon.frame = NSRect(x: 0, y: 0, width: 16, height: 16)
        tokenValidationIcon.imageScaling = .scaleProportionallyUpOrDown
        
        // Start with neutral state
        setTokenValidationState(.neutral)
        
        // Set up real-time validation
        patField.target = self
        patField.action = #selector(patFieldChanged)
    }
    
    @objc private func patFieldChanged() {
        // Debounce the validation to avoid too many API calls
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(validateTokenRealTime), object: nil)
        perform(#selector(validateTokenRealTime), with: nil, afterDelay: 1.0)
    }
    
    @objc private func validateTokenRealTime() {
        let currentPAT = patField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Don't validate empty tokens
        if currentPAT.isEmpty {
            setTokenValidationState(.neutral)
            return
        }
        
        // Don't validate obviously invalid tokens (too short, not base64-like, etc.)
        if currentPAT.count < 10 {
            setTokenValidationState(.invalid, message: "Token is too short. Azure DevOps PATs are typically 52+ characters long. Please check if you copied the complete token.")
            return
        }
        
        if !isValidPATFormat(currentPAT) {
            setTokenValidationState(.invalid, message: "Token format appears invalid. Azure DevOps PATs should contain only letters, numbers, and the characters +/= (base64-like format). Please verify you copied the token correctly.")
            return
        }
        
        // Show loading state
        setTokenValidationState(.loading)
        
        // Update settings with current values
        settingsManager.azureEmail = emailField.stringValue
        settingsManager.organization = organizationField.stringValue
        settingsManager.project = projectField.stringValue
        settingsManager.azurePAT = currentPAT
        
        // Test the token with a more robust validation
        validateTokenWithAPI()
    }
    
    private func isValidPATFormat(_ pat: String) -> Bool {
        // Basic format validation - Azure DevOps PATs are typically base64-like
        // They should be at least 52 characters and contain valid base64 characters
        return pat.count >= 52 && pat.range(of: "^[A-Za-z0-9+/=]+$", options: .regularExpression) != nil
    }
    
    private func validateTokenWithAPI() {
        // Use a more specific API endpoint for validation
        let organization = settingsManager.organization
        let project = settingsManager.project
        let pat = settingsManager.azurePAT
        
        guard !organization.isEmpty && !project.isEmpty && !pat.isEmpty else {
            setTokenValidationState(.invalid, message: "Cannot validate token: Missing organization or project name. Please fill in both the 'Organization' and 'Project' fields before validating the token.")
            return
        }
        
        // Use a lightweight API call to validate the token - use the organization API which is more reliable
        let urlString = "https://dev.azure.com/\(organization)/_apis/projects?api-version=7.1-preview.1"
        guard let url = URL(string: urlString) else {
            setTokenValidationState(.invalid, message: "Invalid URL format. This usually means the organization or project name contains invalid characters. Please check that your organization and project names are correct and don't contain special characters.")
            return
        }
        
        var request = URLRequest(url: url)
        let authStr = ":\(pat)"
        let authData = authStr.data(using: .utf8)!
        let authValue = "Basic \(authData.base64EncodedString())"
        request.setValue(authValue, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        self.setTokenValidationState(.valid)
                    case 401:
                        self.setTokenValidationState(.invalid, message: "Authentication failed (401 Unauthorized): The token is invalid, expired, or doesn't have the required permissions. Please check that: 1) The token is correct and complete, 2) The token hasn't expired, 3) The token has 'Code (read)' and 'Work items (read)' permissions enabled.")
                    case 403:
                        self.setTokenValidationState(.invalid, message: "Access forbidden (403): The token is valid but doesn't have permission to access this project. Please ensure the token has 'Code (read)' and 'Work items (read)' permissions, and that you have access to the specified project.")
                    case 404:
                        self.setTokenValidationState(.invalid, message: "Project not found (404): The project '\(self.settingsManager.project)' doesn't exist in organization '\(self.settingsManager.organization)'. Please verify that both the organization and project names are spelled correctly.")
                    default:
                        self.setTokenValidationState(.invalid, message: "Authentication failed (HTTP \(httpResponse.statusCode)): The server returned an unexpected response. This might indicate a temporary issue with Azure DevOps or an incorrect organization/project configuration.")
                    }
                } else if let error = error {
                    self.setTokenValidationState(.invalid, message: "Network error: \(error.localizedDescription). Please check your internet connection and try again. If the problem persists, Azure DevOps might be temporarily unavailable.")
                } else {
                    self.setTokenValidationState(.invalid, message: "Unknown error: The validation request failed for an unknown reason. Please try again in a few moments.")
                }
            }
        }
        
        task.resume()
        
        // Set up timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let self = self else { return }
            if case .loading = self.currentValidationState {
                self.setTokenValidationState(.invalid, message: "Request timeout: The validation request took too long to complete. This could be due to: 1) Slow internet connection, 2) Azure DevOps being temporarily unavailable, 3) Network firewall blocking the request. Please check your internet connection and try again.")
            }
        }
    }
    
    private enum TokenValidationState {
        case neutral, loading, valid, invalid
    }
    
    private var currentValidationState: TokenValidationState = .neutral
    
    private func setTokenValidationState(_ state: TokenValidationState, message: String = "") {
        currentValidationState = state
        
        switch state {
        case .neutral:
            tokenValidationIcon.image = nil
            tokenValidationIcon.toolTip = ""
            
        case .loading:
            // Create a simple loading indicator
            let loadingImage = NSImage(size: NSSize(width: 16, height: 16))
            loadingImage.lockFocus()
            NSColor.systemBlue.set()
            NSBezierPath(ovalIn: NSRect(x: 2, y: 2, width: 12, height: 12)).stroke()
            loadingImage.unlockFocus()
            tokenValidationIcon.image = loadingImage
            tokenValidationIcon.toolTip = "Validating token with Azure DevOps..."
            
        case .valid:
            // Green checkmark
            let checkImage = NSImage(size: NSSize(width: 16, height: 16))
            checkImage.lockFocus()
            NSColor.systemGreen.set()
            let path = NSBezierPath()
            path.move(to: NSPoint(x: 4, y: 8))
            path.line(to: NSPoint(x: 7, y: 11))
            path.line(to: NSPoint(x: 12, y: 4))
            path.lineWidth = 2
            path.stroke()
            checkImage.unlockFocus()
            tokenValidationIcon.image = checkImage
            tokenValidationIcon.toolTip = "✅ Token is valid and working correctly!"
            
        case .invalid:
            // Red X
            let xImage = NSImage(size: NSSize(width: 16, height: 16))
            xImage.lockFocus()
            NSColor.systemRed.set()
            let path = NSBezierPath()
            path.move(to: NSPoint(x: 4, y: 4))
            path.line(to: NSPoint(x: 12, y: 12))
            path.move(to: NSPoint(x: 12, y: 4))
            path.line(to: NSPoint(x: 4, y: 12))
            path.lineWidth = 2
            path.stroke()
            xImage.unlockFocus()
            tokenValidationIcon.image = xImage
            let tooltipMessage = message.isEmpty ? "❌ Token is invalid" : "❌ " + message
            tokenValidationIcon.toolTip = tooltipMessage
        }
    }
    
}

extension SettingsWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        settingsManager.showAuthoredPRs = showAuthoredCheckbox.state == .on
        settingsManager.showAssignedPRs = showAssignedCheckbox.state == .on
        settingsManager.autoRefreshEnabled = autoRefreshCheckbox.state == .on
        settingsManager.showShortTitles = showShortTitlesCheckbox.state == .on
        if let intervalMinutes = Int(refreshIntervalField.stringValue) {
            settingsManager.refreshInterval = intervalMinutes * 60
        }
        settingsManager.azureEmail = emailField.stringValue
        settingsManager.organization = organizationField.stringValue
        settingsManager.project = projectField.stringValue
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
