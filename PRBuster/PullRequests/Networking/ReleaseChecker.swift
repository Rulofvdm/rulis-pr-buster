import Foundation

struct GitHubRelease: Codable {
    let tagName: String
    let htmlUrl: String
    let publishedAt: String
    
    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case htmlUrl = "html_url"
        case publishedAt = "published_at"
    }
}

class ReleaseChecker {
    private static let repositoryOwner = "Rulofvdm"
    private static let repositoryName = "rulis-pr-buster"
    private static let releasesURL = "https://api.github.com/repos/\(repositoryOwner)/\(repositoryName)/releases/latest"
    private static let lastCheckedVersionKey = "lastCheckedReleaseVersion"
    private static let lastCheckDateKey = "lastReleaseCheckDate"
    
    // Get current app version from Info.plist
    static var currentVersion: String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "1.0"
        }
        return version
    }
    
    // Check if a new release is available
    static func checkForNewRelease(completion: @escaping (GitHubRelease?) -> Void) {
        // Check if we've already checked recently (within last hour) to avoid too frequent checks
        if let lastCheckDate = UserDefaults.standard.object(forKey: lastCheckDateKey) as? Date {
            let timeSinceLastCheck = Date().timeIntervalSince(lastCheckDate)
            if timeSinceLastCheck < 3600 { // 1 hour
                // Return cached result if available
                if let lastVersion = UserDefaults.standard.string(forKey: lastCheckedVersionKey) {
                    if lastVersion != currentVersion {
                        // We know there's a new version, but fetch fresh data
                        fetchLatestRelease(completion: completion)
                        return
                    } else {
                        // No new version since last check
                        completion(nil)
                        return
                    }
                }
            }
        }
        
        fetchLatestRelease(completion: completion)
    }
    
    private static func fetchLatestRelease(completion: @escaping (GitHubRelease?) -> Void) {
        guard let url = URL(string: releasesURL) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Update last check date
            UserDefaults.standard.set(Date(), forKey: lastCheckDateKey)
            
            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completion(nil)
                return
            }
            
            do {
                let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
                
                // Compare versions
                if isNewerVersion(release.tagName, than: currentVersion) {
                    // Store the latest version we found
                    UserDefaults.standard.set(release.tagName, forKey: lastCheckedVersionKey)
                    completion(release)
                } else {
                    // No new version
                    UserDefaults.standard.set(currentVersion, forKey: lastCheckedVersionKey)
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
    
    // Simple version comparison (handles semantic versioning like "1.0.0", "1.1", etc.)
    private static func isNewerVersion(_ version1: String, than version2: String) -> Bool {
        // Remove 'v' prefix if present
        let v1 = version1.replacingOccurrences(of: "v", with: "", options: .caseInsensitive)
        let v2 = version2.replacingOccurrences(of: "v", with: "", options: .caseInsensitive)
        
        let components1 = v1.split(separator: ".").compactMap { Int($0) }
        let components2 = v2.split(separator: ".").compactMap { Int($0) }
        
        let maxLength = max(components1.count, components2.count)
        
        for i in 0..<maxLength {
            let part1 = i < components1.count ? components1[i] : 0
            let part2 = i < components2.count ? components2[i] : 0
            
            if part1 > part2 {
                return true
            } else if part1 < part2 {
                return false
            }
        }
        
        return false // Versions are equal
    }
    
    // Get releases page URL
    static var releasesPageURL: URL? {
        return URL(string: "https://github.com/\(repositoryOwner)/\(repositoryName)/releases")
    }
    
    // Clear cache (useful for debugging/testing)
    static func clearCache() {
        UserDefaults.standard.removeObject(forKey: lastCheckedVersionKey)
        UserDefaults.standard.removeObject(forKey: lastCheckDateKey)
    }
}

