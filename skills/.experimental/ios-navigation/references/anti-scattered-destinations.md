---
title: Avoid Scattering navigationDestination Across Views
impact: CRITICAL
impactDescription: causes O(n) destination lookup ambiguity, undefined behavior with 2+ registrations
tags: anti, destination, registration, undefined-behavior
---

## Avoid Scattering navigationDestination Across Views

When multiple child views register `.navigationDestination(for:)` for the same type, SwiftUI does not merge them -- it picks one non-deterministically. Which registration wins can change between app launches, view reloads, or even device rotations, leading to wrong destinations, blank screens, or outright crashes. The only safe pattern is a single registration per type, placed at or near the `NavigationStack` root.

**Incorrect (same type registered in multiple children):**

```swift
// BAD: Two children both claim Item.self destinations.
// SwiftUI silently picks one at random — tapping an item
// may show ChildViewA's detail OR ChildViewB's detail
// depending on render order. This is undefined behavior.
struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                ChildViewA()
                ChildViewB()
            }
        }
    }
}

struct ChildViewA: View {
    var body: some View {
        List(itemsA) { item in
            NavigationLink(value: item) { Text(item.name) }
        }
        .navigationDestination(for: Item.self) { item in
            ItemEditView(item: item) // Registration #1
        }
    }
}

struct ChildViewB: View {
    var body: some View {
        List(itemsB) { item in
            NavigationLink(value: item) { Text(item.name) }
        }
        .navigationDestination(for: Item.self) { item in
            ItemReadOnlyView(item: item) // Registration #2 — conflicts with #1
        }
    }
}
```

**Correct (single destination registration at the stack root):**

```swift
// GOOD: One registration per Hashable type at the stack root.
// Every NavigationLink(value: Item) resolves to the same,
// predictable destination regardless of where the link lives.
@Equatable
struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                ChildViewA()
                ChildViewB()
            }
            .navigationDestination(for: Item.self) { item in
                ItemDetailView(item: item)
            }
        }
    }
}

@Equatable
struct ChildViewA: View {
    var body: some View {
        List(itemsA) { item in
            NavigationLink(value: item) { Text(item.name) }
        }
    }
}

@Equatable
struct ChildViewB: View {
    var body: some View {
        List(itemsB) { item in
            NavigationLink(value: item) { Text(item.name) }
        }
    }
}
```
