---
title: Integrate Search Using Searchable Modifier
impact: MEDIUM-HIGH
impactDescription: provides consistent search experience matching system apps
tags: nav, search, searchable, filtering
---

## Integrate Search Using Searchable Modifier

Use the `.searchable` modifier for search functionality. It provides the standard iOS search experience with proper placement in the navigation bar.

**Incorrect (custom search implementation):**

```swift
// Custom search bar that doesn't match system
VStack {
    HStack {
        Image(systemName: "magnifyingglass")
        TextField("Search...", text: $searchText)
    }
    .padding()
    .background(Color.gray.opacity(0.2))

    List(filteredItems) { item in
        Text(item.name)
    }
}
// Doesn't integrate with navigation bar
// Missing system behaviors like cancel button
```

**Correct (system searchable modifier):**

```swift
NavigationStack {
    List(filteredItems) { item in
        NavigationLink(value: item) {
            ItemRow(item: item)
        }
    }
    .navigationTitle("Items")
    .searchable(text: $searchText, prompt: "Search items")
}

// With search suggestions
.searchable(text: $searchText) {
    ForEach(suggestions) { suggestion in
        Text(suggestion.name)
            .searchCompletion(suggestion.name)
    }
}

// With search scopes
.searchable(text: $searchText) { }
.searchScopes($scope) {
    Text("All").tag(SearchScope.all)
    Text("Recent").tag(SearchScope.recent)
    Text("Favorites").tag(SearchScope.favorites)
}

// Computed filtered results
var filteredItems: [Item] {
    if searchText.isEmpty {
        return items
    }
    return items.filter {
        $0.name.localizedCaseInsensitiveContains(searchText)
    }
}
```

**Search best practices:**
- Place in navigation bar (automatic with `.searchable`)
- Show recent searches when field is empty
- Provide search suggestions as user types
- Use scopes to filter large datasets
- Show "No Results" state, not empty list

Reference: [Navigation and search - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/navigation-and-search)
