# PRBuster

A macOS menu bar app for managing Azure DevOps Pull Requests with notifications, reminders, and quick access to your PRs.

---

## Features
- **Menu Bar Integration:** See assigned and authored PRs at a glance.
- **Azure DevOps Integration:** Connects to your Azure DevOps organization and project using your email and Personal Access Token (PAT).
- **Notifications:**
  - New PR assignments
  - Daily and interval reminders
  - Smart notifications (only when you have pending PRs)
- **Quick Actions:**
  - Open all assigned or authored PRs in your browser
  - See PR status, reviewers, and unresolved comments
- **Customizable Settings:**
  - Organization, project, email, PAT
  - Display and refresh options
  - Notification preferences

---

## Screenshots
I don't have any yet, because I've been to lazy to make phony pr's to show off all the features.

---

## Getting Started

### Prerequisites
- macOS 12+
- Xcode 14+
- An Azure DevOps account with access to your organization/project
- A Personal Access Token (PAT) with appropriate permissions (Code: Read & Pull Request: Read & Write)

### Installation
1. **Grab the latest release in the right hand menu**

---

## Configuration

On first launch, open the Settings window (from the menu bar icon) and fill in:

- **Azure DevOps Email:** Your Azure DevOps account email.
- **Organization:** Your Azure DevOps organization name (e.g., `myorg`).
- **Project:** The project name within your organization (e.g., `MyProject`).
- **PAT/Token:** Your Azure DevOps Personal Access Token.

### Other Settings
- **Show PRs I authored / assigned to me:** Toggle which PRs appear in the menu.
- **Auto-refresh:** Enable/disable and set the refresh interval (in minutes).
- **Notifications:**
  - Enable/disable notifications
  - New PR assignments
  - Daily reminders (set time)
  - Interval reminders (set hours)
  - Smart notifications (only when you have pending PRs)
  - Include PR count in notifications

---

## Usage
- Click the menu bar icon to view your PRs.
- Click a PR to open it in your browser.
- Use "Open all assigned/authored PRs" for batch actions.
- Access Settings or Refresh from the menu.

---

## Security & Privacy
- **Credentials** are stored in your user defaults (not in the code or repo). _For higher security, consider using macOS Keychain in the future._
- No analytics or telemetry is collected.
- The app only requests network access and user-selected file read access.

---

## Development
- Written in Swift using Cocoa (AppKit).
- Main entry: `PRBuster/main.swift`, `AppDelegate.swift`.
- Settings: `Settings/SettingsWindowController.swift`, `SettingsManager.swift`, `AppSettings.swift`.
- PR logic: `PullRequests/` and `PullRequests/Networking/`.
- Notifications: `Notifications/NotificationManager.swift`.

---

## Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

---

## Troubleshooting
- If PRs do not appear, check your credentials and organization/project settings.
- Make sure your PAT has the correct permissions.
- For issues, open an issue on GitHub. 