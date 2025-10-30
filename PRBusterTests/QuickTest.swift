import XCTest
import Cocoa
@testable import PRBuster

class QuickTest: XCTestCase {
    
    func testBasicFunctionality() {
        // Test that the app can be instantiated
        let appDelegate = AppDelegate()
        XCTAssertNotNil(appDelegate, "AppDelegate should be created")
        
        // Test that settings manager works
        let settingsManager = SettingsManager.shared
        XCTAssertNotNil(settingsManager, "SettingsManager should be created")
        
        // Test default settings
        XCTAssertEqual(settingsManager.azureEmail, "", "Default email should be empty")
        XCTAssertEqual(settingsManager.azurePAT, "", "Default PAT should be empty")
        XCTAssertTrue(settingsManager.showAuthoredPRs, "Default showAuthoredPRs should be true")
        XCTAssertTrue(settingsManager.showAssignedPRs, "Default showAssignedPRs should be true")
    }
    
    func testSettingsConfiguration() {
        let settingsManager = SettingsManager.shared
        
        // Test configuration check
        XCTAssertFalse(settingsManager.isConfigured, "Should not be configured with empty credentials")
        
        // Test setting values
        settingsManager.azureEmail = "test@example.com"
        settingsManager.azurePAT = "test-pat"
        
        XCTAssertTrue(settingsManager.isConfigured, "Should be configured with valid credentials")
        XCTAssertEqual(settingsManager.azureEmail, "test@example.com", "Email should be set")
        XCTAssertEqual(settingsManager.azurePAT, "test-pat", "PAT should be set")
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
}
