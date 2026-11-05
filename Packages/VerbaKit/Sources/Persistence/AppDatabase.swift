import Core
import Foundation
import GRDB

/// The one database the app opens. It runs every migration before any
/// screen reads, and it is the only writer.
public struct AppDatabase: Sendable {
    /// Kept internal so GRDB types never leave this module.
    let writer: any DatabaseWriter

    init(_ writer: any DatabaseWriter) throws {
        self.writer = writer
        try Self.migrator.migrate(writer)
    }

    /// Opens (or creates) the database file as a `DatabasePool` in WAL mode.
    public static func open(at url: URL) throws -> AppDatabase {
        let pool = try DatabasePool(path: url.path(percentEncoded: false))
        let database = try AppDatabase(pool)
        Log.store.info("Database open, migrations applied")
        return database
    }

    /// An in memory database with the same migrations, for tests.
    public static func inMemory() throws -> AppDatabase {
        try AppDatabase(DatabaseQueue())
    }

    /// Migrations only move forward: each schema change is a new, named
    /// migration, and an applied migration is never edited.
    static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        // Permanent no op so the file exists with a migration history.
        // The data model (spec 3) appends its migrations after this one.
        migrator.registerMigration("v0_scaffold") { _ in }

        return migrator
    }
}
