import Foundation

class PRMenuItemViewModel {
    let pr: PullRequest
    var buildValidationState: PRStatusCheck.State? = nil
    var unresolvedCommentCount: Int = 0
    var isAnyCheckRunning: Bool = false
    var reviewersPolicyState: ReviewersPolicyState = .unknown
    var buildValidationExpired: Bool = false
    var buildFailedReason: String? = nil // Also handle for expired

    init(pr: PullRequest) {
        self.pr = pr
    }

    var failedOrExpired: Bool {
        return buildValidationExpired || (buildValidationState == .failed || buildValidationState == .error)
    }

    var unifiedStatus: PullRequest.PRUnifiedStatus {
        // 0. Expired build validation takes top precedence and is red
        if buildValidationExpired { return .buildExpired }
        // 1. If any check is failed/error, Build failed (red)
        if let s = buildValidationState, s == .failed || s == .error {
            return .buildFailed
        }
        // 2. If there are unresolved comments, Unresolved comments (red)
        if unresolvedCommentCount > 0 {
            return .unresolvedComments
        }
        // 3. If any check is running (pending) AND no failures, Checks running (blue)
        if let s = buildValidationState, s == .pending {
            return .checksRunning
        }
        // 4. If build succeeded and no unresolved comments, determine approval state via policy + votes
        if buildValidationState == .succeeded {
            let approvals = pr.reviewers.filter { $0.vote == .approved }.count
            switch reviewersPolicyState {
            case .rejected:
                return .waitingForReapproval
            case .queued:
                return .waitingForApproval
            case .approved, .unknown:
                if approvals < 2 { return .waitingForApproval }
                return .ready
            }
        }
        // 5. (fallback, default to running if still unknown)
        return .checksRunning
    }
}
