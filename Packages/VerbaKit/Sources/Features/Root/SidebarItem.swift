/// The sections of the main window, one per slice as the app grows.
nonisolated public enum SidebarItem: String, CaseIterable, Identifiable, Hashable, Sendable {
    case home
    case lessons
    case chat
    case review
    case notebook

    /// The item itself, so `List` can identify rows.
    public var id: Self { self }

    /// The label shown in the sidebar and as the window title.
    public var title: String {
        switch self {
        case .home: "Home"
        case .lessons: "Lessons"
        case .chat: "Chat"
        case .review: "Review"
        case .notebook: "Notebook"
        }
    }

    /// The SF Symbol name shown next to the title.
    public var systemImage: String {
        switch self {
        case .home: "house"
        case .lessons: "book"
        case .chat: "bubble.left.and.bubble.right"
        case .review: "arrow.trianglehead.2.clockwise"
        case .notebook: "text.book.closed"
        }
    }
}
