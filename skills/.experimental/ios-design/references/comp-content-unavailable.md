---
title: Use ContentUnavailableView for Empty States
impact: HIGH
impactDescription: "eliminates custom empty state code; enables native iOS 17+ empty state matching Apple apps"
tags: comp, empty-state, content-unavailable, ios17, search
---

## Use ContentUnavailableView for Empty States

ContentUnavailableView (iOS 17+) provides a native empty state that matches Apple's own apps. Use it instead of custom empty state views.

**Incorrect (custom empty state without standard styling):**

```swift
struct SearchResults: View {
    let results: [Item]
    let query: String

    var body: some View {
        if results.isEmpty {
            VStack {
                Image(systemName: "magnifyingglass")
                    .font(.largeTitle)
                Text("No results for \"\(query)\"")
                Text("Try a different search term")
                    .foregroundStyle(.secondary)
            }
        } else {
            List(results) { item in
                ItemRow(item: item)
            }
        }
    }
}
```

**Correct (ContentUnavailableView for native styling):**

```swift
struct SearchResults: View {
    let results: [Item]
    let query: String

    var body: some View {
        List(results) { item in
            ItemRow(item: item)
        }
        .overlay {
            if results.isEmpty {
                ContentUnavailableView.search(text: query)
            }
        }
    }
}
```

**Custom empty states:**

```swift
// No content yet
ContentUnavailableView(
    "No Bookmarks",
    systemImage: "bookmark",
    description: Text("Save articles to read later.")
)

// With action button
ContentUnavailableView {
    Label("No Photos", systemImage: "photo")
} description: {
    Text("Your photo library is empty.")
} actions: {
    Button("Import Photos") { importPhotos() }
        .buttonStyle(.borderedProminent)
}
```

Reference: [ContentUnavailableView - Apple Documentation](https://developer.apple.com/documentation/swiftui/contentunavailableview)
