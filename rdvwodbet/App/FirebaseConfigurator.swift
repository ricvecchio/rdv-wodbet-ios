import Foundation
import FirebaseCore

enum FirebaseConfigurator {
    static func configure() {
        // Certifique-se de adicionar o GoogleService-Info.plist ao projeto
        FirebaseApp.configure()
    }
}

