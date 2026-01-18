import Foundation

enum Logger {
    static func info(_ message: String) {
        print("ℹ️ [INFO] \(message)")
    }

    static func error(_ message: String) {
        print("🛑 [ERROR] \(message)")
    }
}
