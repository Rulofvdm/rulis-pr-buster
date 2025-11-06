import Cocoa
import Foundation
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var pullRequests: [PullRequest] = []
    var authoredPullRequests: [PullRequest] = []
    private let settingsManager = SettingsManager.shared
    private let notificationManager = NotificationManager.shared
    private var refreshTimer: Timer?
    
    // Track previous PR state for new PR detection
    private var previousAssignedPRIds: Set<Int> = []
    var errorMessage: String? = nil

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure app doesn't appear in dock
        NSApp.setActivationPolicy(.accessory)
        
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = notificationManager
        
        // Listen for PAT expiration notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePATExpired),
            name: .patExpired,
            object: nil
        )
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateMenuBar(assigned: 0, approved: 0, open: 0, notApproved: 0, hasOverdue: false, authoredApproved: 0, totalAuthored: 0)
        
        // Request notification permissions if enabled
        if settingsManager.notificationsEnabled {
            notificationManager.requestNotificationPermissions { granted in
                if granted {
                    self.notificationManager.updateNotificationSchedules()
                }
            }
        }
        
        // Only fetch PRs if credentials are present
        if settingsManager.isConfigured && !settingsManager.azureEmail.isEmpty && !settingsManager.azurePAT.isEmpty {
            startAppLogic()
        } else {
            buildMenu() // Show menu with 'Please configure settings' message
        }
    }

    private func startAppLogic() {
        PullRequestService.fetchAssignedPRs(email: settingsManager.azureEmail, pat: settingsManager.azurePAT) { [weak self] prs in
            DispatchQueue.main.async {
                if prs.isEmpty && self?.settingsManager.isConfigured == true {
                    self?.errorMessage = "Failed to fetch assigned PRs. Check your credentials."
                } else {
                    self?.errorMessage = nil
                }
                self?.pullRequests = prs
                self?.checkForNewPRs(prs)
                PullRequestService.fetchAuthoredPRs(email: self?.settingsManager.azureEmail ?? "", pat: self?.settingsManager.azurePAT ?? "") { authoredPRs in
                    DispatchQueue.main.async {
                        if authoredPRs.isEmpty && self?.settingsManager.isConfigured == true {
                            self?.errorMessage = "Failed to fetch PRs. Check your credentials."
                        }
                        self?.authoredPullRequests = authoredPRs
                        self?.updateMenuBarWithCurrentData()
                        self?.buildMenu()
                        self?.startRefreshTimer()
                        self?.updateNotificationSchedules()
                    }
                }
            }
        }
    }

    func updateMenuBar(assigned: Int, approved: Int, open: Int, notApproved: Int = 0, hasOverdue: Bool = false, authoredApproved: Int = 0, totalAuthored: Int = 0) {
        if let button = statusItem?.button {
            let title = "\(notApproved)/\(assigned) \(authoredApproved)/\(totalAuthored)"
            button.title = title
            
            // Make text red if there are overdue PRs that haven't been approved
            if hasOverdue && notApproved > 0 {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: NSColor.systemRed
                ]
                button.attributedTitle = NSAttributedString(string: title, attributes: attributes)
            } else {
                button.attributedTitle = NSAttributedString(string: title)
            }
        }
    }

    func updateMenuBarWithCurrentData() {
        let myUniqueName = settingsManager.azureEmail
        let assigned = pullRequests.count
        
        // Calculate not approved PRs (PRs assigned to me that I haven't approved)
        let notApproved = pullRequests.filter { pr in
            guard let me = pr.reviewers.first(where: { $0.uniqueName == myUniqueName }) else { return false }
            return !me.isApproved
        }.count
        
        // Check if any of the PRs assigned to me are overdue AND I haven't approved them
        let hasOverdue = pullRequests.filter { pr in
            guard let me = pr.reviewers.first(where: { $0.uniqueName == myUniqueName }) else { return false }
            // Only consider it overdue if: assigned to me + overdue + I haven't approved it
            return !me.isApproved && pr.isOverdue
        }.count > 0
        
        // Calculate authored PRs statistics
        let authoredPRs = authoredPullRequests.filter { pr in
            pr.createdBy.uniqueName == myUniqueName
        }
        let totalAuthored = authoredPRs.count
        let authoredApproved = authoredPRs.filter { pr in
            pr.isApproved
        }.count
        
        updateMenuBar(assigned: assigned, approved: 0, open: 0, notApproved: notApproved, hasOverdue: hasOverdue, authoredApproved: authoredApproved, totalAuthored: totalAuthored)
    }

    func buildMenu() {
        statusItem?.menu = nil // Defensive: clear any existing menu before setting a new one
        let menu = MenuBuilder.buildMenu(
            pullRequests: pullRequests,
            authoredPullRequests: authoredPullRequests,
            settingsManager: settingsManager,
            openSettings: #selector(openSettings),
            refreshPRs: #selector(refreshPRs),
            statusItem: statusItem,
            target: self,
            errorMessage: errorMessage
        )
        statusItem?.menu = menu
    }

    @objc func refreshPRs() {
        // Only fetch PRs if credentials are present
        guard settingsManager.isConfigured, !settingsManager.azureEmail.isEmpty, !settingsManager.azurePAT.isEmpty else {
            return
        }
        PullRequestService.fetchAssignedPRs(email: settingsManager.azureEmail, pat: settingsManager.azurePAT) { [weak self] prs in
            DispatchQueue.main.async {
                if prs.isEmpty && self?.settingsManager.isConfigured == true {
                    self?.errorMessage = "Failed to fetch assigned PRs. Check your credentials."
                } else {
                    self?.errorMessage = nil
                }
                self?.pullRequests = prs
                self?.checkForNewPRs(prs)
                PullRequestService.fetchAuthoredPRs(email: self?.settingsManager.azureEmail ?? "", pat: self?.settingsManager.azurePAT ?? "") { authoredPRs in
                    DispatchQueue.main.async {
                        if authoredPRs.isEmpty && self?.settingsManager.isConfigured == true {
                            self?.errorMessage = "Failed to fetch PRs. Check your credentials."
                        }
                        self?.authoredPullRequests = authoredPRs
                        self?.updateMenuBarWithCurrentData()
                        self?.buildMenu()
                        self?.updateNotificationSchedules()
                    }
                }
            }
        }
    }

    @objc func openSettings() {
        if let existing = SettingsWindowController.shared {
            existing.showWindow(nil)
            existing.window?.makeKeyAndOrderFront(nil)
        } else {
            let settingsWC = SettingsWindowController(window: nil)
            SettingsWindowController.shared = settingsWC
            settingsWC.showWindow(nil)
            settingsWC.window?.makeKeyAndOrderFront(nil)
        }
        NSApp.activate(ignoringOtherApps: true)
        stopRefreshTimer()
    }

    func startRefreshTimer() {
        // Only start timer if settings are configured and auto-refresh is enabled
        guard settingsManager.isConfigured && settingsManager.autoRefreshEnabled else { 
            stopRefreshTimer()
            return 
        }
        
        // Invalidate existing timer if any
        refreshTimer?.invalidate()
        
        // Start new timer with current interval
        let interval = TimeInterval(settingsManager.refreshInterval)
        refreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.refreshPRs()
        }
    }
    
    private func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    // MARK: - Notification Integration
    
    private func checkForNewPRs(_ newPRs: [PullRequest]) {
        let currentPRIds = Set(newPRs.map { $0.pullRequestId })
        let newPRIds = currentPRIds.subtracting(previousAssignedPRIds)
        
        if !newPRIds.isEmpty {
            let newPRs = newPRs.filter { newPRIds.contains($0.pullRequestId) }
            
            if newPRs.count == 1 {
                // Show individual notification for single new PR
                notificationManager.showNewPRNotification(pr: newPRs[0])
            } else {
                // Show batch notification for multiple new PRs
                notificationManager.showBatchNewPRNotification(count: newPRs.count)
            }
        }
        
        previousAssignedPRIds = currentPRIds
    }
    
    private func updateNotificationSchedules() {
        // Update notification schedules when PR data changes
        notificationManager.updateNotificationSchedules()
    }
    
    // MARK: - Public Interface for NotificationManager
    
    func getPendingPRCount() -> Int {
        return pullRequests.count
    }
    
    @objc private func handlePATExpired() {
        let organization = settingsManager.organization
        let renewURL = "https://dev.azure.com/\(organization)/_usersSettings/tokens"
        
        errorMessage = """
        PAT/Token has expired or is invalid.
        
        Please renew your token:
        \(renewURL)
        
        Required permissions:
        • Code → Read
        • Work Items → Read
        """
        
        buildMenu()
    }
}
