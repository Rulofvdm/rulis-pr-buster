import Foundation

extension Notification.Name {
    static let patExpired = Notification.Name("patExpired")
}

class PullRequestService {
    static func fetchAssignedPRs(email: String, pat: String, completion: @escaping ([PullRequest]) -> Void) {
        guard !pat.isEmpty else {
            completion([])
            return
        }
        let organization = SettingsManager.shared.organization
        let project = SettingsManager.shared.project
        let userId = "me"
        let urlString = "https://dev.azure.com/\(organization)/\(project)/_apis/git/pullrequests?searchCriteria.reviewerId=\(userId)&status=active&api-version=7.1-preview.1"
        guard let url = URL(string: urlString) else { completion([]); return }
        var request = URLRequest(url: url)
        
        // Azure DevOps PAT authentication: empty username, PAT as password
        let authStr = ":\(pat)"
        let authData = authStr.data(using: .utf8)!
        let authValue = "Basic \(authData.base64EncodedString())"
        request.setValue(authValue, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                    // Authentication failed - PAT expired or invalid
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .patExpired, object: nil)
                    }
                    completion([])
                    return
                }
            }
            
            guard let data = data else {
                completion([])
                return
            }
            if data.isEmpty {
                completion([])
                return
            }
            do {
                let response = try JSONDecoder().decode(AzureDevOpsResponse<PullRequest>.self, from: data)
                let filtered = response.value.filter { pr in
                    pr.reviewers.contains { $0.uniqueName == email }
                }
                completion(filtered)
            } catch {
                completion([])
            }
        }
        task.resume()
    }

    static func fetchAuthoredPRs(email: String, pat: String, completion: @escaping ([PullRequest]) -> Void) {
        guard !pat.isEmpty else {
            completion([])
            return
        }
        let organization = SettingsManager.shared.organization
        let project = SettingsManager.shared.project
        let userId = "me"
        let urlString = "https://dev.azure.com/\(organization)/\(project)/_apis/git/pullrequests?searchCriteria.creatorId=\(userId)&status=active&api-version=7.1-preview.1"
        guard let url = URL(string: urlString) else { completion([]); return }
        var request = URLRequest(url: url)
        
        // Azure DevOps PAT authentication: empty username, PAT as password
        let authStr = ":\(pat)"
        let authData = authStr.data(using: .utf8)!
        let authValue = "Basic \(authData.base64EncodedString())"
        request.setValue(authValue, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                    // Authentication failed - PAT expired or invalid
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .patExpired, object: nil)
                    }
                    completion([])
                    return
                }
            }
            
            guard let data = data else {
                completion([])
                return
            }
            if data.isEmpty {
                completion([])
                return
            }
            do {
                let response = try JSONDecoder().decode(AzureDevOpsResponse<PullRequest>.self, from: data)
                completion(response.value)
            } catch {
                completion([])
            }
        }
        task.resume()
    }

    static func fetchUnresolvedCommentCount(repositoryId: String, pullRequestId: Int, pat: String, completion: @escaping (Int) -> Void) {
        let organization = SettingsManager.shared.organization
        let project = SettingsManager.shared.project
        let urlString = "https://dev.azure.com/\(organization)/\(project)/_apis/git/repositories/\(repositoryId)/pullRequests/\(pullRequestId)/threads?api-version=7.1"
        guard let url = URL(string: urlString) else { completion(0); return }
        var request = URLRequest(url: url)
        
        // Azure DevOps PAT authentication: empty username, PAT as password
        let authStr = ":\(pat)"
        let authData = authStr.data(using: .utf8)!
        let authValue = "Basic \(authData.base64EncodedString())"
        request.setValue(authValue, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(0)
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let threads = json?["value"] as? [[String: Any]] ?? []
                let unresolved = threads.filter { thread in
                    (thread["status"] as? String) == "active"
                }
                completion(unresolved.count)
            } catch {
                print("Error decoding unresolved threads: \(error)")
                completion(0)
            }
        }
        task.resume()
    }
}

// MARK: - Build Validation / Status Checks API

struct PRStatusCheck: Codable {
    let state: State
    let context: Context
    let description: String?
    let targetUrl: String?

    struct Context: Codable {
        let name: String
        let genre: String?
    }

    enum State: String, Codable {
        case error, failed, succeeded, pending, notApplicable
    }
}

struct AzureStatusesResponse: Codable {
    let value: [PRStatusCheck]
}

extension PullRequestService {
    static func fetchStatusChecks(
        repositoryId: String, 
        pullRequestId: Int, 
        pat: String, 
        completion: @escaping ([PRStatusCheck]) -> Void
    ) {
        let organization = SettingsManager.shared.organization
        let project = SettingsManager.shared.project
        let urlString = "https://dev.azure.com/\(organization)/\(project)/_apis/git/repositories/\(repositoryId)/pullRequests/\(pullRequestId)/statuses?api-version=7.1"
        guard let url = URL(string: urlString) else { completion([]); return }
        var request = URLRequest(url: url)
        
        let authStr = ":\(pat)"
        let authData = authStr.data(using: .utf8)!
        let authValue = "Basic \(authData.base64EncodedString())"
        request.setValue(authValue, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion([])
                return
            }
            let debugString = String(data: data, encoding: .utf8) ?? "(non-utf8-data)"
            print("RAW Statuses response for PR \(pullRequestId):", debugString)
            // Attempt 1: decode { value: [...] }
            if let wrapped = try? JSONDecoder().decode(AzureStatusesResponse.self, from: data) {
                completion(wrapped.value)
                return
            }
            // Attempt 2: decode top-level array
            if let array = try? JSONDecoder().decode([PRStatusCheck].self, from: data) {
                completion(array)
                return
            }
            // Attempt 3: manual parse accepting flexible shapes/keys
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let list: [[String: Any]]
                if let dict = json as? [String: Any], let value = dict["value"] as? [[String: Any]] {
                    list = value
                } else if let arr = json as? [[String: Any]] {
                    list = arr
                } else {
                    completion([])
                    return
                }
                let mapped: [PRStatusCheck] = list.compactMap { item in
                    // Accept either 'state' or 'status'
                    guard let stateStr = (item["state"] as? String) ?? (item["status"] as? String) else { return nil }
                    let contextDict = item["context"] as? [String: Any]
                    let ctxName = (contextDict?["name"] as? String) ?? ""
                    let ctxGenre = contextDict?["genre"] as? String
                    let desc = item["description"] as? String
                    let targetUrl = item["targetUrl"] as? String
                    guard let state = PRStatusCheck.State(rawValue: stateStr.lowercased()) else { return nil }
                    return PRStatusCheck(state: state, context: PRStatusCheck.Context(name: ctxName, genre: ctxGenre), description: desc, targetUrl: targetUrl)
                }
                completion(mapped)
            } catch {
                print("Error decoding statuses: \(error)")
                completion([])
            }
        }
        task.resume()
    }
} 

// MARK: - Policy Evaluations (fallback for build validation)
struct PolicyEvaluationsResponse: Codable {
    let value: [PolicyEvaluation]
}

struct PolicyEvaluation: Codable {
    let status: String // e.g. approved, rejected, queued, running, notApplicable
}

extension PullRequestService {
    static func fetchPolicyEvaluations(
        projectId: String,
        pullRequestId: Int,
        pat: String,
        completion: @escaping (PRStatusCheck.State?) -> Void
    ) {
        let organization = SettingsManager.shared.organization
        let project = SettingsManager.shared.project
        let artifactId = "vstfs:///CodeReview/CodeReviewId/\(projectId)/\(pullRequestId)"
        let encodedArtifact = artifactId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? artifactId
        let urlString = "https://dev.azure.com/\(organization)/\(project)/_apis/policy/evaluations?artifactId=\(encodedArtifact)&api-version=7.1-preview"
        guard let url = URL(string: urlString) else { completion(nil); return }
        var request = URLRequest(url: url)
        let authStr = ":\(pat)"
        let authData = authStr.data(using: .utf8)!
        let authValue = "Basic \(authData.base64EncodedString())"
        request.setValue(authValue, forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { completion(nil); return }
            let debugString = String(data: data, encoding: .utf8) ?? "(non-utf8-data)"
            print("RAW Policies response for PR \(pullRequestId):", debugString)
            // Try wrapped { value: [...] }
            if let wrapped = try? JSONDecoder().decode(PolicyEvaluationsResponse.self, from: data) {
                let statuses = wrapped.value.map { $0.status.lowercased() }
                if statuses.contains("rejected") { completion(.failed); return }
                if statuses.contains("queued") || statuses.contains("running") { completion(.pending); return }
                if statuses.contains("approved") { completion(.succeeded); return }
                completion(nil); return
            }
            // Try top-level array
            if let arr = try? JSONDecoder().decode([PolicyEvaluation].self, from: data) {
                let statuses = arr.map { $0.status.lowercased() }
                if statuses.contains("rejected") { completion(.failed); return }
                if statuses.contains("queued") || statuses.contains("running") { completion(.pending); return }
                if statuses.contains("approved") { completion(.succeeded); return }
                completion(nil); return
            }
            // Manual fallback
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let list: [[String: Any]]
                if let dict = json as? [String: Any], let value = dict["value"] as? [[String: Any]] {
                    list = value
                } else if let arr = json as? [[String: Any]] {
                    list = arr
                } else {
                    completion(nil)
                    return
                }
                let statuses = list.compactMap { ($0["status"] as? String)?.lowercased() }
                if statuses.contains("rejected") { completion(.failed); return }
                if statuses.contains("queued") || statuses.contains("running") { completion(.pending); return }
                if statuses.contains("approved") { completion(.succeeded); return }
                completion(nil)
            } catch {
                print("Error decoding policy evaluations: \(error)")
                completion(nil)
            }
        }.resume()
    }
} 

struct PolicySummary {
    let buildState: PRStatusCheck.State?
    let reviewersState: ReviewersPolicyState
    let buildExpired: Bool
    let buildFailedReason: String?
}

extension PullRequestService {
    static func fetchPolicyEvaluationsSummary(
        projectId: String,
        pullRequestId: Int,
        pat: String,
        completion: @escaping (PolicySummary) -> Void
    ) {
        let organization = SettingsManager.shared.organization
        let project = SettingsManager.shared.project
        let artifactId = "vstfs:///CodeReview/CodeReviewId/\(projectId)/\(pullRequestId)"
        let encodedArtifact = artifactId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? artifactId
        let urlString = "https://dev.azure.com/\(organization)/\(project)/_apis/policy/evaluations?artifactId=\(encodedArtifact)&api-version=7.1-preview"
        guard let url = URL(string: urlString) else { completion(PolicySummary(buildState: nil, reviewersState: .unknown, buildExpired: false, buildFailedReason: nil)); return }
        var request = URLRequest(url: url)
        let authStr = ":\(pat)"
        let authData = authStr.data(using: .utf8)!
        let authValue = "Basic \(authData.base64EncodedString())"
        request.setValue(authValue, forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { completion(PolicySummary(buildState: nil, reviewersState: .unknown, buildExpired: false, buildFailedReason: nil)); return }
            let debugString = String(data: data, encoding: .utf8) ?? "(non-utf8-data)"
            print("RAW Policies response (summary) for PR \(pullRequestId):", debugString)
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let list: [[String: Any]]
                if let dict = json as? [String: Any], let value = dict["value"] as? [[String: Any]] {
                    list = value
                } else if let arr = json as? [[String: Any]] {
                    list = arr
                } else {
                    completion(PolicySummary(buildState: nil, reviewersState: .unknown, buildExpired: false, buildFailedReason: nil))
                    return
                }
                var buildState: PRStatusCheck.State? = nil
                var reviewersState: ReviewersPolicyState = .unknown
                var buildExpired = false
                var buildFailedReason: String? = nil
                for item in list {
                    var displayName: String? = nil
                    if let type = item["type"] as? [String: Any], let dn = type["displayName"] as? String { displayName = dn }
                    if displayName == nil, let cfg = item["configuration"] as? [String: Any], let t = cfg["type"] as? [String: Any], let dn = t["displayName"] as? String { displayName = dn }
                    let status = (item["status"] as? String)?.lowercased()
                    if let name = displayName, let statusStr = status {
                        if name == "Build" {
                            if statusStr == "approved" { buildState = .succeeded }
                            else if statusStr == "rejected" {
                                buildState = .failed
                                // Check for specific failure reason only when rejected
                                if let context = item["context"] as? [String: Any] {
                                    if let bop = context["buildOutputPreview"] as? [String: Any] {
                                        let job = (bop["jobName"] as? String)?.lowercased() ?? ""
                                        let task = (bop["taskName"] as? String)?.lowercased() ?? ""
                                        var errorsText = ""
                                        if let errors = bop["errors"] as? [[String: Any]] {
                                            errorsText = errors.compactMap { $0["message"] as? String }.joined(separator: "\n").lowercased()
                                        }
                                        if job.contains("branch behind check") || task.contains("branch behind check") || errorsText.contains("branch behind check") {
                                            buildFailedReason = "branch behind check"
                                        }
                                    }
                                }
                            }
                            else if statusStr == "queued" || statusStr == "running" { buildState = .pending }
                            if let context = item["context"] as? [String: Any] {
                                if let expired = context["isExpired"] as? Bool { buildExpired = expired }
                            }
                        } else if name == "Minimum number of reviewers" {
                            if statusStr == "queued" { reviewersState = .queued }
                            else if statusStr == "approved" { reviewersState = .approved }
                            else if statusStr == "rejected" { reviewersState = .rejected }
                        }
                    }
                }
                completion(PolicySummary(buildState: buildState, reviewersState: reviewersState, buildExpired: buildExpired, buildFailedReason: buildFailedReason))
            } catch {
                print("Error parsing policy summary: \(error)")
                completion(PolicySummary(buildState: nil, reviewersState: .unknown, buildExpired: false, buildFailedReason: nil))
            }
        }.resume()
    }
} 