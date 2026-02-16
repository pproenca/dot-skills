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
// COST: Duplicates navigation logic, state sync breaks on rotation
// Back-swipe gesture disappears, toolbar items render incorrectly
// NOTE: @StateObject is also legacy — replaced by @State with @Observable
struct MailboxView: View {
    @StateObject private var viewModel = MailboxViewModel()
    @Environment(\.horizontalSizeClass) private var sizeClass
    var body: some View {
        if sizeClass == .regular {
            HStack(spacing: 0) {
                NavigationStack {
                    MailSidebarView(folders: viewModel.folders, selection: $viewModel.selectedFolder)
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
                MailSidebarView(folders: viewModel.folders, selection: $viewModel.selectedFolder)
                    .navigationDestination(for: Folder.self) { MessageListView(folder: $0) }
            }
        }
    }
}
```

**Correct (NavigationSplitView with embedded detail NavigationStack):**

```swift
// BENEFIT: Automatic column layout, collapse, sidebar visibility
// iPhone becomes stack, iPad renders resizable sidebar
@Equatable
struct MailboxView: View {
    @State private var viewModel = MailboxViewModel()
    @State private var selectedFolder: Folder?
    @State private var selectedMessage: Message?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(viewModel.folders, selection: $selectedFolder) { folder in
                Label(folder.name, systemImage: folder.icon).badge(folder.unreadCount)
            }
            .navigationTitle("Mailboxes")
        } content: {
            if let folder = selectedFolder {
                List(folder.messages, selection: $selectedMessage) { message in
                    MessageRow(message: message)
                }
                .navigationTitle(folder.name)
            } else {
                ContentUnavailableView("No Folder Selected", systemImage: "folder")
            }
        } detail: {
            NavigationStack {
                if let message = selectedMessage {
                    MessageDetailView(message: message)
                        .navigationDestination(for: Attachment.self) {
                            AttachmentPreviewView(attachment: $0)
                        }
                } else {
                    ContentUnavailableView("No Message Selected", systemImage: "envelope")
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}
```
