---
title: Use NavigationSplitView with Selection Binding for Sidebar
impact: HIGH
impactDescription: automatic iPhone stack collapse, iPad sidebar with detail
tags: flow, sidebar, split-view, ipad, adaptive
---

## Use NavigationSplitView with Selection Binding for Sidebar

NavigationSplitView with List(selection:) provides sidebar navigation that automatically adapts between iPad (persistent sidebar with detail pane) and iPhone (pushed navigation stack). Building a custom sidebar with HStack and conditional views breaks platform conventions, loses automatic adaptivity, and requires manual device detection that fragments as new device classes ship.

**Incorrect (custom sidebar with device-based layout):**

```swift
// BAD: Manual sidebar layout with device detection — breaks on new
// device classes, loses automatic iPhone stack collapse behavior
struct CustomSidebarView: View {
    @State private var selected: MenuItem?
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        // Manual layout that must be maintained for each size class —
        // no automatic adaptivity, no system-standard animations
        if sizeClass == .regular {
            HStack(spacing: 0) {
                List(MenuItem.allCases, id: \.self) { item in
                    Button(item.title) { selected = item }
                }
                .frame(width: 300)

                if let selected {
                    DetailView(item: selected)
                } else {
                    Text("Select an item")
                }
            }
        } else {
            // Completely separate navigation for iPhone
            NavigationStack {
                List(MenuItem.allCases, id: \.self) { item in
                    NavigationLink(item.title, value: item)
                }
            }
        }
    }
}
```

**Correct (NavigationSplitView with selection binding):**

```swift
// GOOD: NavigationSplitView adapts automatically — sidebar on iPad,
// pushed stack on iPhone, system-standard animations and gestures
enum MenuItem: String, CaseIterable, Identifiable {
    case inbox, drafts, sent, archive

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
    var icon: String {
        switch self {
        case .inbox: "tray"
        case .drafts: "doc"
        case .sent: "paperplane"
        case .archive: "archivebox"
        }
    }
}

@Equatable
struct MailView: View {
    @State private var selectedItem: MenuItem?
    @State private var columnVisibility =
        NavigationSplitViewVisibility.automatic

    var body: some View {
        // Two-column layout — iPad shows sidebar + detail side by side,
        // iPhone collapses into a standard navigation stack
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(MenuItem.allCases, selection: $selectedItem) { item in
                Label(item.title, systemImage: item.icon)
            }
            .navigationTitle("Mailboxes")
        } detail: {
            // Show detail or empty state — ContentUnavailableView
            // gives a polished placeholder on iPad's detail pane
            if let selectedItem {
                MessageListView(folder: selectedItem)
            } else {
                ContentUnavailableView(
                    "No Folder Selected",
                    systemImage: "tray",
                    description: Text("Choose a folder from the sidebar.")
                )
            }
        }
    }
}
```
