import XCTest
import Cocoa
@testable import PRBuster

class SimpleTest: XCTestCase {
    
    func testBasicFunctionality() {
        // Test that the app can be instantiated
        let appDelegate = AppDelegate()
        XCTAssertNotNil(appDelegate, "AppDelegate should be created")
        
        // Test that settings manager works
        let settingsManager = SettingsManager.shared
        XCTAssertNotNil(settingsManager, "SettingsManager should be created")
        
        // Test that we can access settings (they might not be defaults if previously set)
        XCTAssertNotNil(settingsManager.azureEmail, "Email should be accessible")
        XCTAssertNotNil(settingsManager.azurePAT, "PAT should be accessible")
        XCTAssertNotNil(settingsManager.showAuthoredPRs, "showAuthoredPRs should be accessible")
        XCTAssertNotNil(settingsManager.showAssignedPRs, "showAssignedPRs should be accessible")
    }
    
    func testSettingsConfiguration() {
        let settingsManager = SettingsManager.shared
        
        // Store original values to restore later
        let originalEmail = settingsManager.azureEmail
        let originalPAT = settingsManager.azurePAT
        
        // Test setting values
        settingsManager.azureEmail = "test@example.com"
        settingsManager.azurePAT = "test-pat"
        
        XCTAssertTrue(settingsManager.isConfigured, "Should be configured with valid credentials")
        XCTAssertEqual(settingsManager.azureEmail, "test@example.com", "Email should be set")
        XCTAssertEqual(settingsManager.azurePAT, "test-pat", "PAT should be set")
        
        // Restore original values
        settingsManager.azureEmail = originalEmail
        settingsManager.azurePAT = originalPAT
    }
    
    func testPullRequestModels() {
        // Test that models can be created
        let user = User(
            id: "user-id",
            displayName: "Test User",
            uniqueName: "test@example.com",
            url: "https://dev.azure.com/user"
        )
        XCTAssertEqual(user.uniqueName, "test@example.com", "User uniqueName should be set")
        XCTAssertEqual(user.displayName, "Test User", "User displayName should be set")
        
        let reviewer = Reviewer(
            id: "reviewer-id",
            displayName: "Test Reviewer",
            uniqueName: "reviewer@example.com",
            vote: .noVote,
            url: "https://dev.azure.com/reviewer",
            isRequired: true
        )
        XCTAssertEqual(reviewer.uniqueName, "reviewer@example.com", "Reviewer uniqueName should be set")
        XCTAssertEqual(reviewer.displayName, "Test Reviewer", "Reviewer displayName should be set")
        XCTAssertFalse(reviewer.isApproved, "Reviewer should not be approved")
        
        // Test that we can create a basic PullRequest structure
        // Note: We can't easily create a full PullRequest without all required fields,
        // but we can test the individual components
        XCTAssertEqual(user.id, "user-id", "User ID should be set")
        XCTAssertEqual(reviewer.id, "reviewer-id", "Reviewer ID should be set")
        XCTAssertEqual(reviewer.vote, .noVote, "Reviewer vote should be noVote")
        XCTAssertTrue(reviewer.isRequired ?? false, "Reviewer should be required")
    }
    
    func testAppSettings() {
        let defaultSettings = AppSettings.default
        
        XCTAssertEqual(defaultSettings.azureEmail, "", "Default email should be empty")
        XCTAssertEqual(defaultSettings.azurePAT, "", "Default PAT should be empty")
        XCTAssertTrue(defaultSettings.showAuthoredPRs, "Default showAuthoredPRs should be true")
        XCTAssertTrue(defaultSettings.showAssignedPRs, "Default showAssignedPRs should be true")
        XCTAssertEqual(defaultSettings.refreshInterval, 60, "Default refresh interval should be 60")
        XCTAssertTrue(defaultSettings.autoRefreshEnabled, "Default auto refresh should be true")
        XCTAssertFalse(defaultSettings.notificationsEnabled, "Default notifications should be false")
        XCTAssertEqual(defaultSettings.organization, "jobjack", "Default organization should be jobjack")
        XCTAssertEqual(defaultSettings.project, "Platform", "Default project should be Platform")
    }
    
    func testReviewerVoteEnum() {
        // Test ReviewerVote enum values
        XCTAssertEqual(ReviewerVote.noVote.rawValue, 0, "NoVote should be 0")
        XCTAssertEqual(ReviewerVote.approved.rawValue, 10, "Approved should be 10")
        XCTAssertEqual(ReviewerVote.approvedWithSuggestions.rawValue, 5, "ApprovedWithSuggestions should be 5")
        XCTAssertEqual(ReviewerVote.waitingForAuthor.rawValue, -5, "WaitingForAuthor should be -5")
        XCTAssertEqual(ReviewerVote.rejected.rawValue, -10, "Rejected should be -10")
        
        // Test display names
        XCTAssertEqual(ReviewerVote.approved.displayName, "Approved", "Approved display name should be correct")
        XCTAssertEqual(ReviewerVote.rejected.displayName, "Rejected", "Rejected display name should be correct")
    }
    
    func testPullRequestStatusEnum() {
        // Test PullRequestStatus enum values
        XCTAssertEqual(PullRequestStatus.active.rawValue, "active", "Active should be 'active'")
        XCTAssertEqual(PullRequestStatus.abandoned.rawValue, "abandoned", "Abandoned should be 'abandoned'")
        XCTAssertEqual(PullRequestStatus.completed.rawValue, "completed", "Completed should be 'completed'")
        XCTAssertEqual(PullRequestStatus.notSet.rawValue, "notSet", "NotSet should be 'notSet'")
        
        // Test display names
        XCTAssertEqual(PullRequestStatus.active.displayName, "Active", "Active display name should be correct")
        XCTAssertEqual(PullRequestStatus.completed.displayName, "Completed", "Completed display name should be correct")
    }
    
    // MARK: - New Features Tests
    
    func testShowShortTitlesSetting() {
        let settingsManager = SettingsManager.shared
        
        // Store original value
        let originalValue = settingsManager.showShortTitles
        
        // Test default value
        XCTAssertFalse(settingsManager.showShortTitles, "Default showShortTitles should be false")
        
        // Test setting to true
        settingsManager.showShortTitles = true
        XCTAssertTrue(settingsManager.showShortTitles, "showShortTitles should be true after setting")
        
        // Test setting to false
        settingsManager.showShortTitles = false
        XCTAssertFalse(settingsManager.showShortTitles, "showShortTitles should be false after setting")
        
        // Restore original value
        settingsManager.showShortTitles = originalValue
    }
    
    func testAppSettingsShowShortTitles() {
        let defaultSettings = AppSettings.default
        
        XCTAssertFalse(defaultSettings.showShortTitles, "Default showShortTitles should be false")
    }
    
    func testPullRequestTitleTruncation() {
        // Test that PullRequest models support title truncation
        let user = User(
            id: "user-id",
            displayName: "Test User",
            uniqueName: "test@example.com",
            url: "https://dev.azure.com/user"
        )
        
        let project = Project(
            id: "project-id",
            name: "Test Project",
            state: .wellFormed,
            visibility: .private
        )
        
        let repository = Repository(
            id: "repo-id",
            name: "test-repo",
            project: project
        )
        
        let pullRequest = PullRequest(
            id: 123,
            pullRequestId: 123,
            title: "This is a very long pull request title that should be truncated when showShortTitles is enabled",
            status: .active,
            createdBy: user,
            creationDate: Date(),
            targetRefName: "main",
            sourceRefName: "feature-branch",
            repository: repository,
            reviewers: [],
            url: "https://dev.azure.com/pr/123"
        )
        
        // Test with showShortTitles = false (default)
        let menuDataFull = pullRequest.toAssignedMenuItemData(myUniqueName: "test@example.com", showShortTitles: false)
        XCTAssertNotNil(menuDataFull, "Menu data should not be nil")
        XCTAssertEqual(menuDataFull?.title, "This is a very long pull request title that should be truncated when showShortTitles is enabled", "Full title should be preserved when showShortTitles is false")
        
        // Test with showShortTitles = true
        let menuDataShort = pullRequest.toAssignedMenuItemData(myUniqueName: "test@example.com", showShortTitles: true)
        XCTAssertNotNil(menuDataShort, "Menu data should not be nil")
        XCTAssertEqual(menuDataShort?.title, "This is ", "Title should be truncated to first 8 characters when showShortTitles is true")
    }
    
    func testProjectNameInMenuItemData() {
        let user = User(
            id: "user-id",
            displayName: "Test User",
            uniqueName: "test@example.com",
            url: "https://dev.azure.com/user"
        )
        
        let project = Project(
            id: "project-id",
            name: "Test Project",
            state: .wellFormed,
            visibility: .private
        )
        
        let repository = Repository(
            id: "repo-id",
            name: "test-repo",
            project: project
        )
        
        let pullRequest = PullRequest(
            id: 123,
            pullRequestId: 123,
            title: "Test PR",
            status: .active,
            createdBy: user,
            creationDate: Date(),
            targetRefName: "main",
            sourceRefName: "feature-branch",
            repository: repository,
            reviewers: [],
            url: "https://dev.azure.com/pr/123"
        )
        
        // Test that project name is included in menu item data
        let menuData = pullRequest.toAssignedMenuItemData(myUniqueName: "test@example.com")
        XCTAssertNotNil(menuData, "Menu data should not be nil")
        XCTAssertEqual(menuData?.projectName, "Test Project", "Project name should be included in menu item data")
    }
    
    func testPATExpiredNotification() {
        // Test that the patExpired notification name exists
        let notificationName = Notification.Name.patExpired
        XCTAssertEqual(notificationName.rawValue, "patExpired", "patExpired notification name should be correct")
    }
}
