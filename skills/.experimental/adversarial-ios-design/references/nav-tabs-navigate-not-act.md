---
title: Keep tabs as destinations, never as action triggers
tags: nav, tab-bar, actions, toolbar
---

## Keep tabs as destinations, never as action triggers

The wrong default is a "Compose", "+", or "Camera" tab that fires an action — presenting a sheet, opening the camera — and bounces selection back to the previous tab. A tab that acts instead of navigating breaks the tab bar's contract: users expect every tab to be a place they can go and stay, and a selection that snaps back reads as a glitch. Actions on the current view belong in a toolbar; a tab hosts a persistent section.

**Evidence of violation:** an `onChange(of:)` on the tab selection (or a `Binding` setter wrapping it) that presents a sheet, opens a camera or composer, or performs any action and then restores the previous selection value; or a `Tab` whose content view is `EmptyView`, `Color.clear`, or an unpopulated placeholder because its only purpose is the selection side effect. PASS: every `Tab`'s content is a persistent section view, and create/compose actions live in `.toolbar` items or the tab bar's bottom accessory — cite the tab contents and the action's placement. N/A: no `TabView` in the target.

**Incorrect (a fake tab hijacks selection to present a sheet):**

```swift
import SwiftUI

struct InboxRootView: View {
    @State private var selection: MailSection = .inbox
    @State private var isComposing = false

    var body: some View {
        TabView(selection: $selection) {
            Tab("Inbox", systemImage: "tray", value: MailSection.inbox) {
                NavigationStack { MessageListView() }
            }
            // ⚠️ "Compose" is an action wearing a tab's clothes
            Tab("Compose", systemImage: "square.and.pencil", value: MailSection.compose) {
                Color.clear
            }
            Tab("Archive", systemImage: "archivebox", value: MailSection.archive) {
                NavigationStack { ArchiveListView() }
            }
        }
        .onChange(of: selection) { previous, current in
            if current == .compose {
                isComposing = true
                selection = previous
            }
        }
        .sheet(isPresented: $isComposing) { ComposeMessageView() }
    }
}
```

**Correct (compose is a toolbar action; every tab is a real place):**

```swift
import SwiftUI

struct InboxRootView: View {
    @State private var isComposing = false

    var body: some View {
        TabView {
            Tab("Inbox", systemImage: "tray") {
                NavigationStack {
                    MessageListView()
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                Button("Compose", systemImage: "square.and.pencil") {
                                    isComposing = true
                                }
                            }
                        }
                }
            }
            Tab("Archive", systemImage: "archivebox") {
                NavigationStack { ArchiveListView() }
            }
        }
        .sheet(isPresented: $isComposing) { ComposeMessageView() }
    }
}
```

Reference: [HIG — Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars)
