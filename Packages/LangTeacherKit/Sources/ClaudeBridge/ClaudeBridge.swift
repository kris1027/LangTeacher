import Core
import Subprocess

// The only module that launches a process or builds a prompt.
//
// The client itself (CLI flags, finding `claude` outside your shell PATH,
// structured replies, streaming, failure messages) is designed in spec 4
// (Claude Code bridge). The scaffold only proves this module links Core and
// swift-subprocess; see ClaudeBridgeTests.
