import Foundation
import FirebaseCore

enum FirebaseConfigurator {
    static func configure() {
        guard FirebaseApp.app() == nil else { return }
        FirebaseApp.configure()
    }
}
