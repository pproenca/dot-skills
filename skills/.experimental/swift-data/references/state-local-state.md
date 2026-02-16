---
title: Use @State for View-Local Transient Data
impact: MEDIUM
impactDescription: prevents persisting UI-only state (search text, sheet visibility, selections)
tags: state, local, transient, swiftui
---

## Use @State for View-Local Transient Data

UI-only data such as search text, selected tab index, sheet presentation state, and toggle values belongs in `@State`, not in SwiftData models. Persisting transient UI state in `@Model` wastes storage, triggers unnecessary database writes on every keystroke, and complicates the data model with fields that have no business meaning.

**Incorrect (UI state stored in @Model — persisted to database):**

```swift
import SwiftData

@Model class UserPreferences {
    var searchText: String = "" // Stored in database, survives app restarts
    var isSheetPresented: Bool = false // Database write on every toggle
    var selectedTab: Int = 0

    init() {}
}
```

**Correct (@State for transient UI data — reset on view creation, never persisted):**

```swift
@Equatable
struct ContentView: View {
    @State private var searchText = ""
    @State private var isSheetPresented = false
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                FriendList()
                    .searchable(text: $searchText)
                    .sheet(isPresented: $isSheetPresented) {
                        AddFriendView()
                    }
            }
            .tabItem { Label("Friends", systemImage: "person.2") }
            .tag(0)
        }
    }
}
```

**When NOT to use:**
- User preferences that should persist across launches (e.g., preferred sort order, theme) may warrant storage — but prefer `@AppStorage` or `UserDefaults` over SwiftData for simple key-value settings

Reference: [Develop in Swift — Create, Update, and Delete Data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)
