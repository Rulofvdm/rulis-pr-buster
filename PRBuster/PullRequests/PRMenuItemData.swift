import Foundation

struct PRMenuItemData {
    let approval: String
    let approvalColor: String
    let reviewerType: ReviewerType
    let title: String
    let author: String
    let branch: String
    let reviewersStatus: String?
    let url: URL
    let isOverdue: Bool
    let projectName: String
    let statusText: String
    let statusColor: String
    
    enum ReviewerType: String {
        case required = "R"
        case optional = "O"
        case author = "A"
    }
} 