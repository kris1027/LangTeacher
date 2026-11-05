import Core
import Foundation
import GRDB
import Testing

@testable import Persistence

struct AppDatabaseTests {
    /// Proof test: a real DatabasePool in a temporary folder migrates and runs in WAL mode.
    @Test func realPoolMigratesInWALMode() throws {
        let root = FileManager.default.temporaryDirectory
            .appending(path: "AppDatabaseTests-\(UUID().uuidString)", directoryHint: .isDirectory)
        defer { try? FileManager.default.removeItem(at: root) }
        let paths = AppPaths(root: root)
        try paths.prepareFolders()

        let database = try AppDatabase.open(at: paths.database)

        #expect(FileManager.default.fileExists(atPath: paths.database.path(percentEncoded: false)))
        let applied = try database.writer.read { db in
            try AppDatabase.migrator.appliedIdentifiers(db)
        }
        #expect(applied.contains("v0_scaffold"))
        let journalMode = try database.writer.read { db in
            try String.fetchOne(db, sql: "PRAGMA journal_mode")
        }
        #expect(journalMode == "wal")
    }

    @Test func reopeningAnExistingFileKeepsItsHistory() throws {
        let root = FileManager.default.temporaryDirectory
            .appending(path: "AppDatabaseTests-\(UUID().uuidString)", directoryHint: .isDirectory)
        defer { try? FileManager.default.removeItem(at: root) }
        let paths = AppPaths(root: root)
        try paths.prepareFolders()

        _ = try AppDatabase.open(at: paths.database)
        let reopened = try AppDatabase.open(at: paths.database)

        let completed = try reopened.writer.read { db in
            try AppDatabase.migrator.hasCompletedMigrations(db)
        }
        #expect(completed)
    }

    @Test func inMemoryDatabaseUsesTheSameMigrations() throws {
        let database = try AppDatabase.inMemory()
        let applied = try database.writer.read { db in
            try AppDatabase.migrator.appliedIdentifiers(db)
        }
        #expect(applied == ["v0_scaffold"])
    }
}
