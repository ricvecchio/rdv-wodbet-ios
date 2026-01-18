import SwiftUI

@main
struct RDVWODBetApp: App {
    @StateObject private var container = AppDIContainer()

    init() {
        FirebaseConfigurator.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
        }
    }
}
