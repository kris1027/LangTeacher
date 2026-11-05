import Core
import Foundation
import Persistence

/// The composition root. It is the only place that knows the build type,
/// picks the data folder, and builds the real services that feature models
/// receive later.
final class AppEnvironment {
    let paths: AppPaths
    let database: AppDatabase

    private init(paths: AppPaths, database: AppDatabase) {
        self.paths = paths
        self.database = database
    }

    /// Creates the data folder, an empty `claude-work/`, and opens the
    /// migrated database. A failure here means the app cannot save anything,
    /// so it stops with a logged reason.
    static func launch() -> AppEnvironment {
        let paths = AppPaths(root: dataRoot)
        do {
            try paths.prepareFolders()
            let database = try AppDatabase.open(at: paths.database)
            Log.app.info("Data folder ready at \(paths.root.path(percentEncoded: false), privacy: .private)")
            return AppEnvironment(paths: paths, database: database)
        } catch {
            Log.app.fault("Launch failed: \(String(describing: error), privacy: .public)")
            fatalError("LangTeacher could not prepare its data folder: \(error)")
        }
    }

    /// Debug builds keep their data apart so development never touches real progress.
    /// `#if DEBUG` is reliable here (the app target), not inside the Swift package.
    private static var dataRoot: URL {
        #if DEBUG
        let folderName = "LangTeacher-Dev"
        #else
        let folderName = "LangTeacher"
        #endif
        return URL.applicationSupportDirectory.appending(path: folderName, directoryHint: .isDirectory)
    }
}
