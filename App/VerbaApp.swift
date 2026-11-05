import Features
import SwiftUI

@main
struct VerbaApp: App {
    /// Built once at launch: prepares the data folder and opens the database
    /// before any screen reads from it.
    private let environment = AppEnvironment.launch()

    var body: some Scene {
        WindowGroup {
            RootView()
        }

        Settings {
            SettingsView()
        }
    }
}
