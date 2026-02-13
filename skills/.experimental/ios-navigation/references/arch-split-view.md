---
title: Use NavigationSplitView for Multi-Column Layouts
impact: HIGH
impactDescription: automatic adaptation between iPad sidebar and iPhone stack
tags: arch, swiftui, split-view, ipad, responsive, multi-column
---

## Use NavigationSplitView for Multi-Column Layouts

NavigationSplitView provides 2-column or 3-column layouts that automatically collapse into a single NavigationStack on compact-width devices. Attempting to replicate this behavior manually with GeometryReader and conditional NavigationStack layouts leads to state synchronization bugs, broken back-swipe gestures, and duplicated navigation logic. NavigationSplitView also integrates with sidebar visibility, column width preferences, and the system toolbar placement conventions that users expect on iPadOS and macOS Catalyst.

**Incorrect (manual layout switching with GeometryReader):**

```swift
// COST: Manual column detection duplicates navigation logic across
// two branches. State synchronization between the sidebar list and
// detail view breaks on rotation. Back-swipe gesture disappears on
// iPad because NavigationStack doesn't know about the sidebar column.
// Toolbar items render incorrectly without proper column context.
struct MailboxView: View {
    @StateObject private var viewModel = MailboxViewModel()
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        if sizeClass == .regular {
            HStack(spacing: 0) {
                NavigationStack {
                    MailSidebarView(
                        folders: viewModel.folders,
                        selection: $viewModel.selectedFolder
                    )
                    .frame(width: 320)
                }
                Divider()
                NavigationStack {
                    if let folder = viewModel.selectedFolder {
                        MessageListView(folder: folder)
                    } else {
                        Text("Select a folder")
                    }
                }
            }
        } else {
            NavigationStack {
                MailSidebarView(
                    folders: viewModel.folders,
                    selection: $viewModel.selectedFolder
                )
                // Duplicate destination registrations for compact layout
                .navigationDestination(for: Folder.self) { folder in
                    MessageListView(folder: folder)
                }
            }
        }
    }
}
```

**Correct (NavigationSplitView with embedded detail NavigationStack):**

```swift
// BENEFIT: NavigationSplitView handles column layout, collapse, and
// sidebar visibility automatically. On iPhone it becomes a stack. On
// iPad it renders a resizable sidebar. The detail column embeds its
// own NavigationStack for deep drill-down without breaking the split.
struct MailboxView: View {
    @StateObject private var viewModel = MailboxViewModel()
    @State private var selectedFolder: Folder?
    @State private var selectedMessage: Message?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar column
            List(viewModel.folders, selection: $selectedFolder) { folder in
                Label(folder.name, systemImage: folder.icon)
                    .badge(folder.unreadCount)
            }
            .navigationTitle("Mailboxes")
        } content: {
            // Content column (message list)
            if let folder = selectedFolder {
                List(folder.messages, selection: $selectedMessage) { message in
                    MessageRow(message: message)
                }
                .navigationTitle(folder.name)
            } else {
                ContentUnavailableView(
                    "No Folder Selected",
                    systemImage: "folder",
                    description: Text("Choose a folder from the sidebar.")
                )
            }
        } detail: {
            // Detail column with its own NavigationStack for drill-down
            NavigationStack {
                if let message = selectedMessage {
                    MessageDetailView(message: message)
                        .navigationDestination(for: Attachment.self) { attachment in
                            AttachmentPreviewView(attachment: attachment)
                        }
                } else {
                    ContentUnavailableView(
                        "No Message Selected",
                        systemImage: "envelope",
                        description: Text("Choose a message to read.")
                    )
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}
```
