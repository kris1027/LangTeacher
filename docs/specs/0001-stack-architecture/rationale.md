# 0001. Rationale: native SwiftUI app on GRDB with a local Claude Code bridge

Decision record for [index.md](index.md). `/develop` builds from `index.md` and can skip this file.

## Context

> ⚠️ Premise note: the whole product rests on the Claude Code CLI, a tool built for coding, being used as a general model client. Its headless flags change between releases (the docs say `--bare` will become the default for `-p`, and bare mode skips subscription login and needs an API key), and it loads hooks, MCP servers, and `CLAUDE.md` from its environment unless told not to. This is not a reason to change course, because your scope deliberately chose "no server, no key". But it makes the bridge (spec 4) load bearing: it must pin flags, check the CLI version, and isolate every call. The deferred "API key in the Keychain" path is the escape hatch if the CLI ever stops fitting.

Verba is a personal macOS app that teaches any language with Claude as the teacher. There is no server and no account system: Claude is reached through the Claude Code CLI already installed and logged in on the Mac, and every lesson, answer, chat, learner record, review item, and notebook page is saved locally. It will grow across nine slices (lesson loop, goal and level, tutor chat, learner memory, spaced review, a printable notebook, several languages, spoken audio, speech input), and the scope requires that the saved data shape absorbs those slices without a breaking migration.

The forces: one developer working with AI agents, so the project files must be easy for an agent to edit; Mac only and personal, so distribution, signing, and store rules matter little today; heavy use of Apple platform features later (system voices, speech recognition, print to PDF); a child process (`claude`) that streams JSON back into a live UI, which is where concurrency bugs live; and the Beta rigor tier, so every feature gets real tests.

Not deciding this blocks everything: the data model, the bridge, and the design system specs all assume a language, a storage engine, and a module layout.

## Options considered

Compared as whole stacks.

### Option 1: Native SwiftUI + GRDB + XcodeGen

Swift 6 and SwiftUI for the app, GRDB over SQLite for storage, swift-subprocess for the CLI, a local Swift package for the logic, and XcodeGen for the project file.

**Pros**:
- Native frameworks for every later slice (voices, speech, print), with no plugins (basis: build on the platform's own frameworks before adding bridges).
- Relational storage with explicit versioned migrations fits a model that grows over nine slices (basis: relational database as the default; forward only migrations).
- Package level tests run without the app (basis: Swift Testing as Apple's current default).
- A text project file agents can edit (basis: XcodeGen `project.yml`).

**Cons**:
- Mac only.
- More storage code than SwiftData (records and SQL migrations by hand).
- Two non Apple dependencies (GRDB, XcodeGen) plus swift-subprocess.

### Option 2: All Apple: SwiftUI + SwiftData + a plain Xcode project

The same UI, but SwiftData for storage and an ordinary `.xcodeproj` using Xcode 16+ synchronized folders, with Foundation `Process` for the CLI. Zero third party dependencies.

**Pros**:
- The least code for models (`@Model` classes, `@Query` in views).
- No extra tools to install.

**Cons**:
- SwiftData migrations are fragile: community reports show staged migration crashes unless the very first schema is wrapped in `VersionedSchema`, and complex queries (review scheduling, mixing topics) are weaker than SQL.
- `project.pbxproj` is still a file agents edit poorly, even with synchronized folders.
- Foundation `Process` needs hand written pipe and cancellation glue under strict concurrency.

### Option 3: Tauri (Rust core + web UI) + SQLite

A web UI in the system WebView, a Rust core that runs the CLI and owns a SQLite file.

**Pros**:
- Could later run on Windows and Linux.
- Web UI tooling for the book like lesson pages.

**Cons**:
- Two languages (Rust and TypeScript) for one developer.
- System voices, speech recognition, and native print need plugins or custom bridges.
- Not native in look and behavior, which your scope asks for.

### Option 4: Electron (TypeScript) + SQLite

Node for the CLI and storage, Chromium for the UI.

**Pros**:
- The easiest subprocess and JSON streaming of all (Node).
- One language, very familiar tooling.

**Cons**:
- Ships a full browser runtime; a heavy app for a personal tool.
- macOS speech and print need extra work; not native.

## Rationale

Option 1 wins on the forces that will hurt most later. The data must survive nine slices of growth without a breaking migration, and that points to SQLite with migrations you write and version yourself, which GRDB does well. SwiftData would save code on day one, but its migration story is the riskiest part of this stack, and the review and memory slices need real queries. GRDB's `ValueObservation` gives the same "screen updates on save" feel that `@Query` offers.

The app is Mac only and leans on Apple frameworks later (voices in Slice 8, speech in Slice 9, print to PDF in Slice 6), so a native SwiftUI app avoids bridges that Options 3 and 4 would need. For one developer working with agents, a text defined project (XcodeGen) and a package that `swift test` can run without the app matter more than having zero dependencies. Swift 6 strict concurrency, swift-subprocess, and the "only `ClaudeBridge` launches processes" rule all target the one risky seam: a child process streaming into a live UI.

Turning off the App Sandbox and signing ad hoc are the honest choices for a personal app that must run a binary from your PATH. Safety moves from the OS to the bridge: an empty work folder, tools off, MCP off. The engineer chose `com.verba.app` as the bundle ID over a handle based one; that is fine for local use, and the only cost is a possible clash if the app is ever distributed under someone else's domain.

## References

**Project sources**:
- `docs/scope/scope.md`: the product summary (no server, Claude through the CLI, data on the Mac), the teaching principles (the app shuffles quiz options), feature 1's done line, the Beta tier, and Tracer Bullet.
- Installed skills: `swiftui-pro` (feature based folders, no third party frameworks without asking, Swift 6.4), `grdb` (DatabasePool vs DatabaseQueue, migrations in order), `swift-concurrency`, `swift-testing-pro`.

**Practices & standards**:
- Relational database as the default for relational data.
- Forward only, versioned schema migrations.
- Monolith first: one app, split into modules, not processes.
- Least privilege for child processes (empty working folder, tools off).
- Composition root dependency injection (services built once, passed in).

**Links** (checked during the landscape check on 2026-11-05):
- Claude Code headless mode: https://code.claude.com/docs/en/headless
- Claude Code CLI reference: https://code.claude.com/docs/en/cli-reference
- GRDB.swift releases: https://github.com/groue/GRDB.swift/releases
- SQLiteData (Point-Free) releases: https://github.com/pointfreeco/sqlite-data/releases
- swift-subprocess: https://github.com/swiftlang/swift-subprocess
- XcodeGen releases: https://github.com/yonaskolb/XcodeGen/releases
- Tuist docs: https://docs.tuist.dev
- Xcode support and versions: https://developer.apple.com/support/xcode/
- Adding tests to an Xcode project: https://developer.apple.com/documentation/xcode/adding-tests-to-your-xcode-project
- SwiftData and VersionedSchema pitfall: https://mertbulan.com/never-use-swiftdata-without-versionedschema/

### Landscape check (2026-11-05)

- Xcode 27 shipped Sep 2026 with Swift 6.4 and the macOS 27 SDK; 27.1 shipped Oct 15 2026. Hosts need macOS Tahoe 26.6+ on Apple silicon.
- GRDB 7.12.0 is the latest release; it needs Swift 6.1+.
- SQLiteData 1.12.1 (Point-Free, built on GRDB) is the runner up storage layer, mainly for its CloudKit sync, if iCloud sync is ever undeferred.
- swift-subprocess 1.0.2 is stable and needs the Swift 6.2+ toolchain; its minimum macOS was not confirmed.
- XcodeGen 2.46.0 appears to be the latest; Tuist 4.x is active but heavier.
- Claude Code headless: `claude -p` with `--output-format json|stream-json`; `--json-schema` returns validated output in `structured_output`; stream-json needs `--verbose`; `--bare` is recommended for scripts and will become the `-p` default, but it skips OAuth and keychain login and needs `ANTHROPIC_API_KEY`.
