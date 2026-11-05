import SwiftUI

/// The Settings window. Empty until a slice adds its first setting.
public struct SettingsView: View {
    /// Creates the Settings window content.
    public init() {}

    /// The settings form.
    public var body: some View {
        Form {
            Text("No settings yet.")
                .foregroundStyle(.secondary)
        }
        .formStyle(.grouped)
        .frame(width: 420, height: 200)
    }
}

#Preview {
    SettingsView()
}
