---
title: Use searchable for Built-In Search
impact: MEDIUM-HIGH
impactDescription: system-standard search bar with automatic placement and keyboard handling
tags: list, searchable, filtering, search-bar, navigation
---

## Use searchable for Built-In Search

The `.searchable` modifier gives you a system-standard search bar that integrates with NavigationStack, handles keyboard dismissal, and follows platform conventions automatically. Building a custom TextField for search requires manually managing placement, styling, and focus behavior, and the result will look and feel inconsistent with the rest of iOS.

**Incorrect (custom TextField for search):**

```swift
struct ContactsView: View {
    @State private var searchText = ""
    let contacts = ["Alice", "Bob", "Charlie", "Diana", "Edward"]

    var filteredContacts: [String] {
        searchText.isEmpty ? contacts : contacts.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search contacts...", text: $searchText) // manual search field outside list
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                List(filteredContacts, id: \.self) { contact in
                    Text(contact)
                }
            }
            .navigationTitle("Contacts")
        }
    }
}
```

**Correct (using .searchable modifier):**

```swift
struct ContactsView: View {
    @State private var searchText = ""
    let contacts = ["Alice", "Bob", "Charlie", "Diana", "Edward"]

    var filteredContacts: [String] {
        searchText.isEmpty ? contacts : contacts.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(filteredContacts, id: \.self) { contact in
                Text(contact)
            }
            .navigationTitle("Contacts")
            .searchable(text: $searchText) // system search bar with automatic placement
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
