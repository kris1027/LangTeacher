import Foundation

/// Every on disk location the app uses, derived from one root folder.
///
/// The app target picks the root (release or dev data folder); tests pass a
/// temporary folder. Packages never check the build type themselves.
public struct AppPaths: Sendable, Equatable {
    /// The data folder every other path is derived from.
    public let root: URL

    /// Creates the paths for a data folder. Nothing is created on disk until `prepareFolders()`.
    public init(root: URL) {
        self.root = root
    }

    /// The single SQLite file that holds everything the app remembers.
    public var database: URL {
        root.appending(path: "langteacher.sqlite", directoryHint: .notDirectory)
    }

    /// The empty folder every `claude` CLI call runs in, so lessons never touch your files.
    public var claudeWork: URL {
        root.appending(path: "claude-work", directoryHint: .isDirectory)
    }

    /// Creates the root and an empty `claude-work/`. Safe to call on every launch.
    public func prepareFolders() throws {
        try FileManager.default.createDirectory(at: claudeWork, withIntermediateDirectories: true)
    }
}
