# Persistence

## Overview

The infrastructure layer for everything the app remembers: one GRDB managed SQLite file at `<data folder>/langteacher.sqlite`. It implements the store protocols declared in `Core` and is the only module that imports GRDB.

## Key files

| File | Owns |
|---|---|
| `AppDatabase.swift` | Opens the `DatabasePool` (WAL), runs the `DatabaseMigrator` before any read, in memory variant for tests |
| `../../Tests/PersistenceTests/AppDatabaseTests.swift` | Migration proof against a real `DatabasePool` in a temp folder |

## Conventions

- GRDB types stay `internal`. Public API speaks `Core` value types; live reads bridge `ValueObservation` to `AsyncStream` here, so `Features` never sees GRDB.
- `AppDatabase` is opened once (by `AppEnvironment`) and is the only writer.
- Migrations only move forward: each schema change is a new, named migration appended after `v0_scaffold`. Never edit an applied migration; never use `eraseDatabaseOnSchemaChange`.
- The schema itself is owned by spec 3 (data model); follow it rather than inventing tables.
- Tests: most use `AppDatabase.inMemory()` (a `DatabaseQueue` with the same migrator); keep at least one test on a real `DatabasePool` in a temporary folder so WAL behavior is covered. Never touch the real or dev data folder.
- Log through `Log.store`; mark learner content `privacy: .private`.

## Gotchas

- `DatabasePool` needs a file path, not an in memory database; that is why tests split between `inMemory()` and a temp folder pool.
- `#if DEBUG` does not reliably reach package targets; the data folder is always passed in from the app.

## Agent skills

- [grdb](../../../../.agents/skills/grdb/): `johnrogers/claude-swift-engineering`, GRDB records, raw SQL, migrations, `ValueObservation`

## Related specs

- [0001 Stack & architecture](../../../../docs/specs/0001-stack-architecture/index.md)

_Drafted by /audit from the repo, worth a quick human pass. Edit freely: once a line stops matching this draft, later runs treat it as curated and will flag rather than overwrite it._
