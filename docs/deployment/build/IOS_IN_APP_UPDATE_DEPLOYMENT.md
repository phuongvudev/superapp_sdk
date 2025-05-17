# iOS Native In-App Updates

For iOS native applications, in-app updates can be implemented using the App Store's official update mechanism or custom solutions for enterprise distribution. Unlike JavaScript-based frameworks that can use CodePush, native iOS apps have limited options for in-app updates due to Apple's App Store policies.
This document provides a guide on implementing in-app update functionality for native iOS applications.

---

## Introduction

Unlike JavaScript-based frameworks that can use CodePush, native iOS apps have limited options for in-app updates due to Apple's App Store policies:

1. **App Store Updates** - Official solution using StoreKit
2. **Custom update notifications** - Implementing version checks to prompt users to update
3. **Enterprise distribution** - For apps distributed through Enterprise program

---

## App Store Updates with StoreKit

### Prerequisites
- Apple Developer account
- App published on the App Store
- StoreKit framework

### 1. **Add StoreKit Framework**

Add StoreKit to your project in Xcode:
- Select your project in the Project Navigator
- Select your target under "TARGETS"
- Select the "Build Phases" tab
- Expand "Link Binary with Libraries"
- Click "+" and select "StoreKit.framework"

### 2. **Implementation**

#### Check for App Updates (Swift)

```swift
import StoreKit

class UpdateManager {
    
    static let shared = UpdateManager()
    
    func checkForUpdates(completion: @escaping (Bool, String?) -> Void) {
        guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let bundleIdentifier = Bundle.main.bundleIdentifier else {
            completion(false, "Unable to determine current app version")
            return
        }
        
        // Get app information from App Store
        let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleIdentifier)")!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if let error = error {
                    throw error
                }
                
                guard let data = data else {
                    throw NSError(domain: "No data received", code: 0, userInfo: nil)
                }
                
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                guard let results = json?["results"] as? [[String: Any]], 
                      let appStoreVersion = results.first?["version"] as? String else {
                    throw NSError(domain: "App not found in App Store", code: 0, userInfo: nil)
                }
                
                let updateAvailable = self.isVersionNewer(currentVersion: currentVersion, storeVersion: appStoreVersion)
                
                DispatchQueue.main.async {
                    completion(updateAvailable, updateAvailable ? appStoreVersion : nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error.localizedDescription)
                }
            }
        }
        
        task.resume()
    }
    
    private func isVersionNewer(currentVersion: String, storeVersion: String) -> Bool {
        let currentComponents = currentVersion.split(separator: ".").map { Int($0) ?? 0 }
        let storeComponents = storeVersion.split(separator: ".").map { Int($0) ?? 0 }
        
        for i in 0..<max(currentComponents.count, storeComponents.count) {
            let currentComponent = i < currentComponents.count ? currentComponents[i] : 0
            let storeComponent = i < storeComponents.count ? storeComponents[i] : 0
            
            if storeComponent > currentComponent {
                return true
            } else if currentComponent > storeComponent {
                return false
            }
        }
        
        return false // Versions are equal
    }
    
    func openAppStore() {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return }
        
        let urlString = "itms-apps://itunes.apple.com/app/id\(bundleIdentifier)"
        if let url = URL(string: urlString) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
```

### 3. **Implement in ViewController**

```swift
class ViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkForAppUpdate()
    }
    
    func checkForAppUpdate() {
        UpdateManager.shared.checkForUpdates { [weak self] (updateAvailable, version) in
            guard let self = self else { return }
            
            if updateAvailable {
                self.showUpdateAlert(version: version ?? "")
            }
        }
    }
    
    func showUpdateAlert(version: String) {
        let alertController = UIAlertController(
            title: "Update Available",
            message: "A new version (\(version)) is available. Please update to continue using the app.",
            preferredStyle: .alert
        )
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { _ in
            UpdateManager.shared.openAppStore()
        }
        
        let cancelAction = UIAlertAction(title: "Later", style: .cancel, handler: nil)
        
        alertController.addAction(updateAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
}
```

---

## Custom Update Solution

For apps that need more control over update notifications:

### 1. **Create a Version Check API**

Create a REST API endpoint that returns version information:

```json
{
  "latestVersion": "1.2.0",
  "minSupportedVersion": "1.0.0",
  "releaseNotes": "Bug fixes and performance improvements"
}
```

### 2. **Implement Version Checking**

```swift
class AppVersionChecker {
    
    enum UpdateStatus {
        case upToDate
        case updateAvailable(version: String, notes: String?)
        case updateRequired(version: String, notes: String?)
        case error(message: String)
    }
    
    static let shared = AppVersionChecker()
    private let apiURL = URL(string: "https://your-api.com/version-check")!
    
    func checkForUpdates(completion: @escaping (UpdateStatus) -> Void) {
        let task = URLSession.shared.dataTask(with: apiURL) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.error(message: error.localizedDescription))
                    return
                }
                
                guard let data = data else {
                    completion(.error(message: "No data received"))
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let latestVersion = json["latestVersion"] as? String,
                       let minSupportedVersion = json["minSupportedVersion"] as? String {
                        
                        let releaseNotes = json["releaseNotes"] as? String
                        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
                        
                        if self.isVersionNewer(currentVersion: currentVersion, targetVersion: minSupportedVersion) {
                            // Current version is below minimum supported
                            completion(.updateRequired(version: latestVersion, notes: releaseNotes))
                        } else if self.isVersionNewer(currentVersion: currentVersion, targetVersion: latestVersion) {
                            // Update available but not required
                            completion(.updateAvailable(version: latestVersion, notes: releaseNotes))
                        } else {
                            // App is up to date
                            completion(.upToDate)
                        }
                    } else {
                        completion(.error(message: "Invalid server response"))
                    }
                } catch {
                    completion(.error(message: "Failed to parse server response"))
                }
            }
        }
        
        task.resume()
    }
    
    private func isVersionNewer(currentVersion: String, targetVersion: String) -> Bool {
        let currentComponents = currentVersion.split(separator: ".").map { Int($0) ?? 0 }
        let targetComponents = targetVersion.split(separator: ".").map { Int($0) ?? 0 }
        
        for i in 0..<max(currentComponents.count, targetComponents.count) {
            let currentComponent = i < currentComponents.count ? currentComponents[i] : 0
            let targetComponent = i < targetComponents.count ? targetComponents[i] : 0
            
            if targetComponent > currentComponent {
                return true
            } else if currentComponent > targetComponent {
                return false
            }
        }
        
        return false
    }
}
```

### 3. **Handling Update Flow**

```swift
class UpdateCoordinator {
    
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func checkAndPromptForUpdate() {
        AppVersionChecker.shared.checkForUpdates { [weak self] status in
            guard let self = self, let viewController = self.viewController else { return }
            
            switch status {
            case .upToDate:
                // No action needed
                break
                
            case .updateAvailable(let version, let notes):
                self.showUpdateAvailableAlert(version: version, notes: notes)
                
            case .updateRequired(let version, let notes):
                self.showRequiredUpdateAlert(version: version, notes: notes)
                
            case .error(let message):
                print("Error checking for updates: \(message)")
            }
        }
    }
    
    private func showUpdateAvailableAlert(version: String, notes: String?) {
        let message = "A new version (\(version)) is available.\n\n\(notes ?? "")"
        let alert = UIAlertController(title: "Update Available", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Update", style: .default) { _ in
            self.openAppStore()
        })
        
        alert.addAction(UIAlertAction(title: "Later", style: .cancel))
        
        viewController?.present(alert, animated: true)
    }
    
    private func showRequiredUpdateAlert(version: String, notes: String?) {
        let message = "This version of the app is no longer supported. Please update to version \(version) to continue.\n\n\(notes ?? "")"
        let alert = UIAlertController(title: "Update Required", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Update", style: .default) { _ in
            self.openAppStore()
        })
        
        viewController?.present(alert, animated: true)
    }
    
    private func openAppStore() {
        guard let appId = Bundle.main.object(forInfoDictionaryKey: "AppStoreID") as? String else {
            // Fallback to using bundle ID
            if let bundleId = Bundle.main.bundleIdentifier,
               let url = URL(string: "itms-apps://itunes.apple.com/app/id\(bundleId)") {
                UIApplication.shared.open(url)
            }
            return
        }
        
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appId)") {
            UIApplication.shared.open(url)
        }
    }
}
```

---

## Enterprise Distribution

For enterprise apps distributed outside the App Store:

### 1. **Implement an Enterprise App Update Service**

```swift
class EnterpriseUpdateService {
    
    struct UpdateInfo {
        let version: String
        let buildNumber: Int
        let downloadURL: URL
        let releaseNotes: String?
        let forcedUpdate: Bool
    }
    
    static let shared = EnterpriseUpdateService()
    private let apiURL = URL(string: "https://your-enterprise-server.com/update-info")!
    
    func checkForUpdates(completion: @escaping (Result<UpdateInfo?, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: apiURL) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    let error = NSError(domain: "EnterpriseUpdateService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    completion(.failure(error))
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let version = json["version"] as? String,
                       let buildNumber = json["buildNumber"] as? Int,
                       let downloadURLString = json["downloadURL"] as? String,
                       let downloadURL = URL(string: downloadURLString) {
                        
                        let releaseNotes = json["releaseNotes"] as? String
                        let forcedUpdate = json["forcedUpdate"] as? Bool ?? false
                        
                        // Compare with current version
                        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
                        let currentBuild = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0") ?? 0
                        
                        if self.isVersionNewer(currentVersion: currentVersion, targetVersion: version) ||
                           buildNumber > currentBuild {
                            
                            let updateInfo = UpdateInfo(
                                version: version,
                                buildNumber: buildNumber,
                                downloadURL: downloadURL,
                                releaseNotes: releaseNotes,
                                forcedUpdate: forcedUpdate
                            )
                            
                            completion(.success(updateInfo))
                        } else {
                            // App is up to date
                            completion(.success(nil))
                        }
                    } else {
                        let error = NSError(domain: "EnterpriseUpdateService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])
                        completion(.failure(error))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    private func isVersionNewer(currentVersion: String, targetVersion: String) -> Bool {
        // Implementation same as previous examples
        let currentComponents = currentVersion.split(separator: ".").map { Int($0) ?? 0 }
        let targetComponents = targetVersion.split(separator: ".").map { Int($0) ?? 0 }
        
        for i in 0..<max(currentComponents.count, targetComponents.count) {
            let currentComponent = i < currentComponents.count ? currentComponents[i] : 0
            let targetComponent = i < targetComponents.count ? targetComponents[i] : 0
            
            if targetComponent > currentComponent {
                return true
            } else if currentComponent > targetComponent {
                return false
            }
        }
        
        return false
    }
}
```

---

## Best Practices

- **Version Strategy**: Use semantic versioning (MAJOR.MINOR.PATCH)
- **Update Prompts**: Don't show update prompts too frequently
- **Required Updates**: Only require updates for critical security issues or major API changes
- **Staged Rollouts**: Use TestFlight for testing updates before App Store release
- **User Experience**: Explain why updates are needed and benefits they provide
- **Update Timing**: Consider prompting for updates when users naturally exit your app's flow
- **App Store Optimization**: Keep App Store listing current to encourage updates

---

## Troubleshooting

- **App Store Connect Issues**: Ensure your application is approved and live in the App Store
- **Version Comparison**: Double-check your version comparison logic
- **Network Errors**: Include error handling for offline situations
- **Enterprise Distribution**: Ensure your enterprise certificate is valid and not expired
- **Universal Links**: If your app uses Universal Links, verify they work after updates

For more details, refer to the [App Store Distribution Documentation](https://developer.apple.com/app-store/review/guidelines/).