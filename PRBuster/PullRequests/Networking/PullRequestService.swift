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