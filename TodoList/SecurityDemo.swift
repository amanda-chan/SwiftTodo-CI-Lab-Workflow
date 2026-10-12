import Foundation

class SecurityDemo {
    func login(username: String, password: String) {
        // Intentionally insecure for CodeQL demonstration
        NSLog("User password: \(password)")
    }
}