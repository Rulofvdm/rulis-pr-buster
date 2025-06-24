import Foundation

// MARK: - Azure DevOps API Response Models
struct AzureDevOpsResponse<T: Codable>: Codable {
    let count: Int
    let value: [T]
}

// MARK: - Pull Request Models
struct PullRequest: Codable, Identifiable {
    let id: Int
    let pullRequestId: Int
    let title: String
    let status: PullRequestStatus
    let createdBy: User
    let creationDate: Date
    let targetRefName: String
    let sourceRefName: String
    let repository: Repository
    let reviewers: [Reviewer]
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case id = "pullRequestId"
        case title
        case status
        case createdBy
        case creationDate
        case targetRefName
        case sourceRefName
        case repository
        case reviewers
        case url
    }
}

enum PullRequestStatus: String, Codable {
    case active = "active"
    case abandoned = "abandoned"
    case completed = "completed"
    case notSet = "notSet"
    
    var displayName: String {
        switch self {
        case .active: return "Active"
        case .abandoned: return "Abandoned"
        case .completed: return "Completed"
        case .notSet: return "Not Set"
        }
    }
}

// MARK: - User Models
struct User: Codable {
    let id: String
    let displayName: String
    let uniqueName: String
    let url: String
}

// MARK: - Reviewer Models
struct Reviewer: Codable, Identifiable {
    let id: String
    let displayName: String
    let uniqueName: String
    let vote: ReviewerVote
    let url: String?
    let isRequired: Bool?
}

enum ReviewerVote: Int, Codable {
    case noVote = 0
    case approved = 10
    case approvedWithSuggestions = 5
    case waitingForAuthor = -5
    case rejected = -10
    
    var displayName: String {
        switch self {
        case .noVote: return "No Vote"
        case .approved: return "Approved"
        case .approvedWithSuggestions: return "Approved with Suggestions"
        case .waitingForAuthor: return "Waiting for Author"
        case .rejected: return "Rejected"
        }
    }
}

// MARK: - Repository Models
struct Repository: Codable {
    let id: String
    let name: String
    let project: Project
}

struct Project: Codable {
    let id: String
    let name: String
    let state: ProjectState
    let visibility: ProjectVisibility
}

enum ProjectState: String, Codable {
    case deleting = "deleting"
    case new = "new"
    case wellFormed = "wellFormed"
    case createPending = "createPending"
    case all = "all"
    case unchanged = "unchanged"
    case deleted = "deleted"
}

enum ProjectVisibility: String, Codable {
    case `private` = "private"
    case `public` = "public"
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try? container.decode(String.self)
        self = ProjectVisibility(rawValue: value ?? "") ?? .unknown
    }
}

// MARK: - Extensions for Convenience
extension PullRequest {
    var shortTargetBranch: String {
        targetRefName.components(separatedBy: "/").last ?? targetRefName
    }
    
    var approvalCount: Int {
        reviewers.filter { $0.vote == .approved }.count
    }
    
    var isApproved: Bool {
        approvalCount >= 2
    }
    
    var webURL: URL? {
        URL(string: "https://dev.azure.com/jobjack/\(repository.project.name)/_git/\(repository.name)/pullrequest/\(pullRequestId)")
    }
    
    // Convert to menu item data for assigned PRs
    func toAssignedMenuItemData(myUniqueName: String) -> PRMenuItemData? {
        guard let me = reviewers.first(where: { $0.uniqueName == myUniqueName }) else { return nil }
        
        let reviewerType: PRMenuItemData.ReviewerType = me.isRequired ?? false ? .required : .optional
        let approval = me.isApproved ? "✓" : "Ⅹ"
        let approvalColor = me.isApproved ? "green" : "red"
        
        return PRMenuItemData(
            approval: approval,
            approvalColor: approvalColor,
            reviewerType: reviewerType,
            title: title,
            author: createdBy.displayName,
            branch: shortTargetBranch,
            reviewersStatus: nil,
            url: webURL ?? URL(string: "https://dev.azure.com")!
        )
    }
    
    // Convert to menu item data for authored PRs
    func toAuthoredMenuItemData() -> PRMenuItemData {
        let approval = "\(approvalCount) ✓"
        let approvalColor = isApproved ? "green" : "red"
        
        let reviewersStatus = reviewers.map { reviewer in
            let status = reviewer.isApproved ? "✓" : "Ⅹ"
            return "\(reviewer.displayName) \(status)"
        }.joined(separator: " ")
        
        return PRMenuItemData(
            approval: approval,
            approvalColor: approvalColor,
            reviewerType: .author,
            title: title,
            author: createdBy.displayName,
            branch: shortTargetBranch,
            reviewersStatus: reviewersStatus,
            url: webURL ?? URL(string: "https://dev.azure.com")!
        )
    }
}

extension Reviewer {
    var isApproved: Bool {
        vote == .approved
    }
}

// MARK: - Date Decoding
extension PullRequest {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        pullRequestId = id // Since id maps to "pullRequestId", they're the same
        title = try container.decode(String.self, forKey: .title)
        status = try container.decode(PullRequestStatus.self, forKey: .status)
        createdBy = try container.decode(User.self, forKey: .createdBy)
        repository = try container.decode(Repository.self, forKey: .repository)
        reviewers = try container.decode([Reviewer].self, forKey: .reviewers)
        url = try container.decode(String.self, forKey: .url)
        targetRefName = try container.decode(String.self, forKey: .targetRefName)
        sourceRefName = try container.decode(String.self, forKey: .sourceRefName)
        
        // Handle date decoding with custom formatter
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let creationDateString = try container.decode(String.self, forKey: .creationDate)
        creationDate = dateFormatter.date(from: creationDateString) ?? Date()
    }
} 