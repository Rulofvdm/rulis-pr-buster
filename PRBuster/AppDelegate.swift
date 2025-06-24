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
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = notificationManager
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateMenuBar(assigned: 0, approved: 0, open: 0)
        
        // Request notification permissions if enabled
        if settingsManager.notificationsEnabled {
            notificationManager.requestNotificationPermissions { granted in
                if granted {
                    print("Notification permissions granted")
                    self.notificationManager.updateNotificationSchedules()
                } else {
                    print("Notification permissions denied")
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

    func updateMenuBar(assigned: Int, approved: Int, open: Int) {
        if let button = statusItem?.button {
            button.title = "\(assigned) | \(approved)/\(open)"
        }
    }

    func updateMenuBarWithCurrentData() {
        let myUniqueName = settingsManager.azureEmail
        let assigned = pullRequests.count
        let openPRs = authoredPullRequests.filter { pr in
            pr.createdBy.uniqueName == myUniqueName
        }
        let open = openPRs.count
        let approved = openPRs.filter { pr in
            pr.isApproved
        }.count
        updateMenuBar(assigned: assigned, approved: approved, open: open)
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
            print("Skipping PR fetch: credentials not set.")
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
}
