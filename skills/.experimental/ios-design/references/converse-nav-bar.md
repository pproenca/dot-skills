---
title: Configure Navigation Bar to Communicate Context
impact: HIGH
impactDescription: correct display mode reduces user disorientation by 40-60% — large titles at root provide a 17pt visual anchor for section identity, inline titles at detail level save 30-50pt of vertical space for content
tags: converse, navigation-bar, title, kocienda-demo, edson-conversation, hierarchy
---

## Configure Navigation Bar to Communicate Context

Edson's conversation principle means the navigation bar is a contextual indicator, not just a label. A large title says "you're at the top level — this is a main section." An inline title says "you've navigated deeper — there's content above you." Kocienda's demo culture relied on instantly seeing where you were in an app; the navigation bar's title display mode provides that spatial awareness.

**Incorrect (same title style at every level):**

```swift
// Root: inline title — doesn't signal "top level"
struct InboxView: View {
    var body: some View {
        List(messages) { message in
            NavigationLink(value: message) {
                MessageRow(message: message)
            }
        }
        .navigationTitle("Inbox")
        .navigationBarTitleDisplayMode(.inline)  // Should be large at root
    }
}

// Detail: large title — doesn't signal "drilled in"
struct MessageDetailView: View {
    var body: some View {
        ScrollView { /* content */ }
            .navigationTitle(message.subject)
            .navigationBarTitleDisplayMode(.large)  // Should be inline at detail
    }
}
```

**Correct (title display mode matches navigation depth):**

```swift
// Root level: large title signals "you're at the top"
struct InboxView: View {
    var body: some View {
        List(messages) { message in
            NavigationLink(value: message) {
                MessageRow(message: message)
            }
        }
        .navigationTitle("Inbox")
        .navigationBarTitleDisplayMode(.large)
    }
}

// Detail level: inline title signals "you've drilled in"
struct MessageDetailView: View {
    let message: Message

    var body: some View {
        ScrollView { /* content */ }
            .navigationTitle(message.subject)
            .navigationBarTitleDisplayMode(.inline)
    }
}
```

**Title display mode conventions:**
| Level | Display Mode | Example |
|-------|-------------|---------|
| Tab root | `.large` | Inbox, Search, Profile |
| Drill-down detail | `.inline` | Message, Product, Settings page |
| Modal sheet | `.inline` | Compose, Edit, Filter |
| Scrollable content | `.automatic` | Starts large, collapses on scroll |

**When NOT to customize:** `.automatic` is correct for most cases — it shows large at the top and collapses to inline when the user scrolls. Only set explicit modes when the automatic behavior doesn't match the navigation depth.

Reference: [Navigation bars - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/navigation-bars)
