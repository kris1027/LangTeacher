import Foundation
import os

/// One logger per module. Read them in Console.app or with
/// `log stream --predicate 'subsystem BEGINSWITH "com.verba"'`.
public enum Log {
    /// The bundle ID in the app; a fixed fallback under `swift test`.
    public static let subsystem = Bundle.main.bundleIdentifier ?? "com.verba.app"

    /// App launch and the composition root.
    public static let app = Logger(subsystem: subsystem, category: "app")
    /// The database and its migrations (Persistence).
    public static let store = Logger(subsystem: subsystem, category: "store")
    /// Calls to the `claude` CLI (ClaudeBridge).
    public static let bridge = Logger(subsystem: subsystem, category: "bridge")
    /// Screens and feature models (Features).
    public static let ui = Logger(subsystem: subsystem, category: "ui")
}
