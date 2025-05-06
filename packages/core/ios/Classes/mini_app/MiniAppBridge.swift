import Foundation

class MiniAppBridge {
    static let shared = MiniAppBridge()

    private var resultCallback: ((Any?) -> Void)?

    private init() {}

    func setResultCallback(_ callback: @escaping (Any?) -> Void) {
        self.resultCallback = callback
    }

    func finishWithResult(_ result: Any?) {
        resultCallback?(result)
        resultCallback = nil
    }
}