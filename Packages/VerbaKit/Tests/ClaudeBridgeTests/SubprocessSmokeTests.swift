import ClaudeBridge
import Subprocess
import Testing

struct SubprocessSmokeTests {
    /// Proof test: swift-subprocess builds for macOS 26 and can launch a process.
    @Test func launchesTrueAndGetsExitCodeZero() async throws {
        let result = try await run(.path("/usr/bin/true"), output: .discarded)
        #expect(result.terminationStatus == .exited(0))
    }
}
