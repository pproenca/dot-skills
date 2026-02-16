---
title: Use ContentUnavailableView for Empty and Error States
impact: HIGH
impactDescription: blank screens with no guidance cause 40-50% of users to leave the screen — ContentUnavailableView provides consistent system-style messaging with actionable guidance
tags: product, empty-state, content-unavailable, edson-product-marketing, kocienda-demo
---

## Use ContentUnavailableView for Empty and Error States

Edson's "the product is the marketing" means empty states are still the product — a blank screen with nothing to show is a missed opportunity to guide the user. When the inbox is empty, the search returns no results, or the network fails, `ContentUnavailableView` (iOS 17+) provides a consistent, system-style message with an icon, title, description, and optional action. Kocienda's demo culture meant that even the "nothing to show" state had to be intentional and helpful.

**Incorrect (blank screen with no guidance):**

```swift
struct BookmarksView: View {
    let bookmarks: [Bookmark]

    var body: some View {
        if bookmarks.isEmpty {
            Text("No bookmarks")
            // No icon, no guidance, no action — user is stuck
        } else {
            List(bookmarks) { bookmark in
                BookmarkRow(bookmark: bookmark)
            }
        }
    }
}
```

**Correct (ContentUnavailableView with guidance and action):**

```swift
struct BookmarksView: View {
    let bookmarks: [Bookmark]

    var body: some View {
        Group {
            if bookmarks.isEmpty {
                ContentUnavailableView {
                    Label("No Bookmarks", systemImage: "bookmark")
                } description: {
                    Text("Articles you bookmark will appear here for quick access.")
                } actions: {
                    Button("Browse Articles") {
                        navigateToFeed()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                List(bookmarks) { bookmark in
                    BookmarkRow(bookmark: bookmark)
                }
            }
        }
        .navigationTitle("Bookmarks")
    }
}
```

**Built-in search empty state:**

```swift
struct SearchableListView: View {
    @State private var searchText = ""

    var body: some View {
        List(filteredItems) { item in
            ItemRow(item: item)
        }
        .searchable(text: $searchText)
        .overlay {
            if filteredItems.isEmpty && !searchText.isEmpty {
                ContentUnavailableView.search(text: searchText)
                // System-provided "No Results for 'query'" with standard styling
            }
        }
    }
}
```

**Empty state categories:**
| State | Icon | Message Pattern |
|-------|------|----------------|
| First use (empty) | Feature icon | "No [items] yet. [How to add them]." |
| Search no results | `magnifyingglass` | "No results for '[query]'" |
| Network error | `wifi.slash` | "No connection. Check your network." + Retry button |
| Permission denied | `lock.fill` | "Access required. [Go to Settings]." |

**When NOT to use ContentUnavailableView:** When the list is loading (show a placeholder instead), or when the empty state is temporary and will resolve in seconds (show a progress indicator).

Reference: [ContentUnavailableView - Apple Documentation](https://developer.apple.com/documentation/swiftui/contentunavailableview)
