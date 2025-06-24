import Cocoa

class MenuBuilder {
    static func buildMenu(
        pullRequests: [PullRequest],
        authoredPullRequests: [PullRequest],
        settingsManager: SettingsManager,
        openSettings: Selector,
        refreshPRs: Selector,
        statusItem: NSStatusItem?,
        target: AnyObject?,
        errorMessage: String? = nil
    ) -> NSMenu {
        let menu = NSMenu()
        let myUniqueName = settingsManager.azureEmail
        let showAuthored = settingsManager.showAuthoredPRs
        let showAssigned = settingsManager.showAssignedPRs
        
        // Show error message if present
        if let errorMessage = errorMessage {
            let errorItem = NSMenuItem(title: errorMessage, action: nil, keyEquivalent: "")
            errorItem.isEnabled = false
            menu.addItem(errorItem)
            menu.addItem(NSMenuItem.separator())
        }
        
        // Check if credentials are configured
        if !settingsManager.isConfigured {
            menu.addItem(withTitle: "Please configure settings", action: nil, keyEquivalent: "")
            menu.addItem(NSMenuItem.separator())
            let settingsItem = NSMenuItem(title: "Settings...", action: openSettings, keyEquivalent: ",")
            settingsItem.target = target
            menu.addItem(settingsItem)
            menu.addItem(NSMenuItem.separator())
            menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
            statusItem?.menu = menu
            return menu
        }
        
        // Section 1: PRs assigned to me
        if showAssigned {
            if pullRequests.isEmpty {
                menu.addItem(withTitle: "No PRs assigned", action: nil, keyEquivalent: "")
            } else {
                menu.addItem(withTitle: "Assigned to me", action: nil, keyEquivalent: "")
                // Add 'Open all assigned PRs' action
                let openAllAssignedItem = NSMenuItem(title: "Open all assigned PRs", action: nil, keyEquivalent: "")
                openAllAssignedItem.setAccessibilityLabel("Open all assigned PRs")
                openAllAssignedItem.attributedTitle = NSAttributedString(string: "Open all assigned PRs", attributes: [.font: NSFont.boldSystemFont(ofSize: 13)])
                let openAllSelector = #selector(MenuBuilder.openAllAssignedPRs(_:))
                openAllAssignedItem.action = openAllSelector
                openAllAssignedItem.target = MenuBuilder.shared
                menu.addItem(openAllAssignedItem)
                for pr in pullRequests {
                    guard let menuData = pr.toAssignedMenuItemData(myUniqueName: myUniqueName) else { continue }
                    let prView = PRMenuItemView(data: menuData) {
                        NSWorkspace.shared.open(menuData.url)
                    }
                    prView.translatesAutoresizingMaskIntoConstraints = false
                    prView.heightAnchor.constraint(equalToConstant: 24).isActive = true
                    let item = NSMenuItem()
                    item.view = prView
                    menu.addItem(item)
                }
            }
        }
        menu.addItem(NSMenuItem.separator())
        // Section 2: PRs authored by me
        if showAuthored {
            let authoredPRs = authoredPullRequests.filter { pr in
                pr.createdBy.uniqueName == myUniqueName
            }
            if authoredPRs.isEmpty {
                menu.addItem(withTitle: "No PRs authored by me", action: nil, keyEquivalent: "")
            } else {
                menu.addItem(withTitle: "My Open PRs", action: nil, keyEquivalent: "")
                // Add 'Open all authored PRs' action
                let openAllAuthoredItem = NSMenuItem(title: "Open all authored PRs", action: nil, keyEquivalent: "")
                openAllAuthoredItem.setAccessibilityLabel("Open all authored PRs")
                openAllAuthoredItem.attributedTitle = NSAttributedString(string: "Open all authored PRs", attributes: [.font: NSFont.boldSystemFont(ofSize: 13)])
                let openAllAuthoredSelector = #selector(MenuBuilder.openAllAuthoredPRs(_:))
                openAllAuthoredItem.action = openAllAuthoredSelector
                openAllAuthoredItem.target = MenuBuilder.shared
                menu.addItem(openAllAuthoredItem)
                for pr in authoredPRs {
                    let menuData = pr.toAuthoredMenuItemData()
                    let prView = PRMenuItemView(data: menuData) {
                        NSWorkspace.shared.open(menuData.url)
                    }
                    prView.translatesAutoresizingMaskIntoConstraints = false
                    prView.heightAnchor.constraint(equalToConstant: 24).isActive = true
                    let item = NSMenuItem()
                    item.view = prView
                    menu.addItem(item)

                    // Fetch unresolved comment count and update menu item if needed
                    PullRequestService.fetchUnresolvedCommentCount(repositoryId: pr.repository.id, pullRequestId: pr.pullRequestId, pat: settingsManager.azurePAT) { count in
                        if count > 0 {
                            DispatchQueue.main.async {
                                prView.setUnresolvedCommentsCount(count)
                            }
                        }
                    }
                }
            }
        }
        menu.addItem(NSMenuItem.separator())
        let settingsItem = NSMenuItem(title: "Settings...", action: openSettings, keyEquivalent: ",")
        settingsItem.target = target
        menu.addItem(settingsItem)
        menu.addItem(withTitle: "Refresh", action: refreshPRs, keyEquivalent: "r")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusItem?.menu = menu
        return menu
    }

    // Add a shared instance for selector target
    static let shared = MenuBuilder()

    @objc func openAllAssignedPRs(_ sender: NSMenuItem) {
        guard let menu = sender.menu else { return }
        var urls: [URL] = []
        for item in menu.items {
            if let prView = item.view as? PRMenuItemView {
                urls.append(prView.url)
            }
        }
        if urls.isEmpty, let appDelegate = NSApp.delegate as? AppDelegate {
            for pr in appDelegate.pullRequests {
                if let url = pr.webURL {
                    NSWorkspace.shared.open(url)
                }
            }
        } else {
            for url in urls {
                NSWorkspace.shared.open(url)
            }
        }
    }

    @objc func openAllAuthoredPRs(_ sender: NSMenuItem) {
        guard let menu = sender.menu else { return }
        var urls: [URL] = []
        var foundAuthoredSection = false
        for item in menu.items {
            if item.title == "My Open PRs" {
                foundAuthoredSection = true
                continue
            }
            if foundAuthoredSection {
                if let prView = item.view as? PRMenuItemView {
                    urls.append(prView.url)
                } else if item.isSeparatorItem || item.title == "Settings..." || item.title == "Refresh" || item.title == "Quit" {
                    break
                }
            }
        }
        if urls.isEmpty, let appDelegate = NSApp.delegate as? AppDelegate {
            for pr in appDelegate.authoredPullRequests {
                if let url = pr.webURL {
                    NSWorkspace.shared.open(url)
                }
            }
        } else {
            for url in urls {
                NSWorkspace.shared.open(url)
            }
        }
    }
} 