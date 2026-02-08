---
title: Use NavigationSplitView for Multi-Column Layouts
impact: HIGH
impactDescription: automatic adaptation between sidebar and stack on iPhone vs iPad
tags: nav, split-view, ipad, adaptive, multi-column
---

## Use NavigationSplitView for Multi-Column Layouts

Manually checking `horizontalSizeClass` to switch between a sidebar layout and a stack layout is fragile: you must handle back-navigation, selection state, and animation transitions yourself, and every new size class combination multiplies the branching. `NavigationSplitView` provides a declarative multi-column layout that automatically collapses into a stack on compact-width devices (iPhone) and expands into two or three columns on regular-width devices (iPad), including proper back-navigation behavior with no additional code.

**Incorrect (manual size class switching between layouts):**

```swift
struct MailView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var selectedFolder: Folder?
    @State private var selectedMessage: Message?

    var body: some View {
        if sizeClass == .regular {
            HStack(spacing: 0) {
                FolderListView(selection: $selectedFolder)
                    .frame(width: 280)
                Divider()
                if let folder = selectedFolder {
                    MessageListView(folder: folder, selection: $selectedMessage)
                    Divider()
                    if let message = selectedMessage {
                        MessageDetailView(message: message)
                    }
                }
            }
            // Must manually handle back navigation, transitions,
            // and selection state synchronization
        } else {
            NavigationStack {
                FolderListView(selection: $selectedFolder)
            }
        }
    }
}
```

**Correct (NavigationSplitView with automatic adaptation):**

```swift
struct MailView: View {
    @State private var selectedFolder: Folder?
    @State private var selectedMessage: Message?

    var body: some View {
        NavigationSplitView {
            FolderListView(selection: $selectedFolder)
        } content: {
            if let folder = selectedFolder {
                MessageListView(folder: folder, selection: $selectedMessage)
            } else {
                Text("Select a folder")
            }
        } detail: {
            if let message = selectedMessage {
                MessageDetailView(message: message)
            } else {
                Text("Select a message")
            }
        }
        // Automatically collapses to stack on iPhone
        // Expands to three columns on iPad
        // Back navigation handled by SwiftUI
    }
}
```

Reference: [NavigationSplitView](https://developer.apple.com/documentation/swiftui/navigationsplitview)
