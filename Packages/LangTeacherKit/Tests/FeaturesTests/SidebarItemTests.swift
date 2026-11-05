import Features
import Testing

struct SidebarItemTests {
    @Test func sidebarListsTheCourseSectionsInOrder() {
        #expect(SidebarItem.allCases.map(\.title) == ["Home", "Lessons", "Chat", "Review", "Notebook"])
    }

    @Test(arguments: SidebarItem.allCases)
    func everySectionHasATitleAndIcon(item: SidebarItem) {
        #expect(!item.title.isEmpty)
        #expect(!item.systemImage.isEmpty)
    }
}
