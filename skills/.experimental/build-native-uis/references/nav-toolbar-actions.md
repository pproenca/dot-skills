---
title: Place Actions in Toolbar for Consistent Placement
impact: HIGH
impactDescription: toolbar adapts placement per platform (iOS navigation bar, macOS toolbar)
tags: nav, toolbar, actions, navigation-bar, cross-platform
---

## Place Actions in Toolbar for Consistent Placement

Placing action buttons directly in the view body creates inconsistent positioning across devices and conflicts with scroll content. The `.toolbar` modifier places actions in the platform-appropriate location automatically -- the navigation bar on iOS, the window toolbar on macOS -- and respects system spacing and accessibility sizing.

**Incorrect (floating action buttons in the view body):**

```swift
struct DocumentListView: View {
    @State private var documents: [Document] = []

    var body: some View {
        NavigationStack {
            VStack {
                HStack { // manually placed buttons ignore platform conventions
                    Spacer()
                    Button { addDocument() } label: {
                        Image(systemName: "plus")
                    }
                    Button { toggleEditing() } label: {
                        Image(systemName: "pencil")
                    }
                }
                .padding(.horizontal)
                List(documents) { document in
                    Text(document.title)
                }
            }
            .navigationTitle("Documents")
        }
    }
}
```

**Correct (using toolbar with placement for platform-adaptive actions):**

```swift
struct DocumentListView: View {
    @State private var documents: [Document] = []

    var body: some View {
        NavigationStack {
            List(documents) { document in
                Text(document.title)
            }
            .navigationTitle("Documents")
            .toolbar {
                ToolbarItem(placement: .primaryAction) { // adapts to each platform
                    Button { addDocument() } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button { toggleEditing() } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
