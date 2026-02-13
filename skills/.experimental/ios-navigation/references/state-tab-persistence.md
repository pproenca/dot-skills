---
title: Persist Selected Tab with SceneStorage
impact: MEDIUM
impactDescription: 1-line SceneStorage change persists tab selection across 100% of app relaunches
tags: state, tab-view, selection, scene-storage, persistence
---

## Persist Selected Tab with SceneStorage

Using `@State` for tab selection resets to the default tab on every app launch. Users who primarily work in a non-default tab (e.g., "Orders" instead of "Home") are forced to re-navigate every time. Use `@SceneStorage` to persist the selected tab per scene so the app restores the user's context on relaunch. Apply the same technique to `NavigationSplitView` sidebar selection.

**Incorrect (@State resets tab selection on every launch):**

```swift
struct MainTabView: View {
    // BAD: @State resets to "home" on every app launch
    // Users who live in "orders" tab sent back to "home" every time
    @State private var selectedTab = "home"
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { HomeView() }
                .tag("home")
                .tabItem { Label("Home", systemImage: "house") }
            NavigationStack { OrdersView() }
                .tag("orders")
                .tabItem { Label("Orders", systemImage: "bag") }
            NavigationStack { ProfileView() }
                .tag("profile")
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}

struct SidebarApp: View {
    // BAD: Sidebar selection lost on relaunch
    @State private var selectedSection: SidebarSection? = .inbox
    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selectedSection)
        } detail: {
            DetailView(section: selectedSection)
        }
    }
}
```

**Correct (@SceneStorage persists tab across launches):**

```swift
struct MainTabView: View {
    // @SceneStorage persists per scene, each iPad window independent
    @SceneStorage("selectedTab") private var selectedTab = "home"
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { HomeView() }
                .tag("home")
                .tabItem { Label("Home", systemImage: "house") }
            NavigationStack { OrdersView() }
                .tag("orders")
                .tabItem { Label("Orders", systemImage: "bag") }
            NavigationStack { ProfileView() }
                .tag("profile")
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}

struct SidebarApp: View {
    @SceneStorage("sidebarSection") private var selectedSection: String?
    var body: some View {
        NavigationSplitView {
            List(SidebarSection.allCases, selection: sidebarBinding) { section in
                Label(section.title, systemImage: section.icon).tag(section.rawValue)
            }
        } detail: {
            if let raw = selectedSection, let section = SidebarSection(rawValue: raw) {
                section.detailView
            } else {
                Text("Select a section").foregroundColor(.secondary)
            }
        }
    }
    private var sidebarBinding: Binding<String?> {
        Binding(get: { selectedSection }, set: { selectedSection = $0 })
    }
}

enum SidebarSection: String, CaseIterable, Identifiable {
    case inbox, sent, drafts, archive
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
    var icon: String { [.inbox: "tray", .sent: "paperplane", .drafts: "doc", .archive: "archivebox"][self]! }
    @ViewBuilder var detailView: some View {
        switch self {
        case .inbox: InboxView(); case .sent: SentView()
        case .drafts: DraftsView(); case .archive: ArchiveView()
        }
    }
}
```
