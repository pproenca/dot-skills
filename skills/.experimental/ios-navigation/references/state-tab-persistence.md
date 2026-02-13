---
title: Persist Selected Tab with SceneStorage
impact: MEDIUM
impactDescription: restores user's last active tab on app relaunch
tags: state, tab-view, selection, scene-storage, persistence
---

## Persist Selected Tab with SceneStorage

Using `@State` for tab selection resets to the default tab on every app launch. Users who primarily work in a non-default tab (e.g., "Orders" instead of "Home") are forced to re-navigate every time. Use `@SceneStorage` to persist the selected tab per scene so the app restores the user's context on relaunch. Apply the same technique to `NavigationSplitView` sidebar selection.

**Incorrect (@State resets tab selection on every launch):**

```swift
struct MainTabView: View {
    // BAD: @State resets to "home" on every app launch and
    // on every scene recreation (e.g., background -> foreground
    // after memory pressure). Users who live in the "orders"
    // tab are sent back to "home" every time.
    @State private var selectedTab = "home"

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tag("home")
            .tabItem { Label("Home", systemImage: "house") }

            NavigationStack {
                OrdersView()
            }
            .tag("orders")
            .tabItem { Label("Orders", systemImage: "bag") }

            NavigationStack {
                ProfileView()
            }
            .tag("profile")
            .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}

// Same problem with NavigationSplitView sidebar:
struct SidebarApp: View {
    // BAD: Sidebar selection lost on relaunch.
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
    // @SceneStorage persists per scene. On relaunch, the user
    // returns to whichever tab they were on. Each iPad window
    // maintains its own selected tab independently.
    @SceneStorage("selectedTab") private var selectedTab = "home"

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tag("home")
            .tabItem { Label("Home", systemImage: "house") }

            NavigationStack {
                OrdersView()
            }
            .tag("orders")
            .tabItem { Label("Orders", systemImage: "bag") }

            NavigationStack {
                ProfileView()
            }
            .tag("profile")
            .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}

// NavigationSplitView sidebar selection with persistence:
struct SidebarApp: View {
    // Use RawRepresentable (String) so SceneStorage can serialize it.
    // SceneStorage supports String, Int, Double, Bool, URL, and Data.
    @SceneStorage("sidebarSection") private var selectedSection: String?

    var body: some View {
        NavigationSplitView {
            List(SidebarSection.allCases, selection: sidebarBinding) { section in
                Label(section.title, systemImage: section.icon)
                    .tag(section.rawValue)
            }
        } detail: {
            if let raw = selectedSection,
               let section = SidebarSection(rawValue: raw) {
                section.detailView
            } else {
                Text("Select a section")
                    .foregroundColor(.secondary)
            }
        }
    }

    // Bridge String? SceneStorage to SidebarSection? binding.
    private var sidebarBinding: Binding<String?> {
        Binding(
            get: { selectedSection },
            set: { selectedSection = $0 }
        )
    }
}

enum SidebarSection: String, CaseIterable, Identifiable {
    case inbox, sent, drafts, archive

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
    var icon: String {
        switch self {
        case .inbox: return "tray"
        case .sent: return "paperplane"
        case .drafts: return "doc"
        case .archive: return "archivebox"
        }
    }

    @ViewBuilder
    var detailView: some View {
        switch self {
        case .inbox: InboxView()
        case .sent: SentView()
        case .drafts: DraftsView()
        case .archive: ArchiveView()
        }
    }
}
```
