import UIKit

class MiniAppViewController: UIViewController {
    
    // Property to store parameters passed from Flutter
    var params: [String: Any]?
    
    @objc private func completeTask() {
        // Return data to Flutter
        let result: [String: Any] = [
            "status": "success",
            "data": ["message": "Task completed from iOS Native"]
        ]
        
        // Use bridge to send result back to Flutter
        MiniAppBridge.shared.finishWithResult(result)
        
        // Dismiss the view controller
        dismiss(animated: true)
    }
}
