---
title: Avoid Mixing NavigationLink(destination:) with NavigationLink(value:)
impact: CRITICAL
impactDescription: causes double-pop bugs in 100% of mixed stacks — ghost entries corrupt NavigationPath, breaking programmatic navigation and deep links
tags: anti, navigation-link, migration, stack-corruption
---

## Avoid Mixing NavigationLink(destination:) with NavigationLink(value:)

Mixing the legacy `NavigationLink(destination:)` API with the modern `NavigationLink(value:)` API inside the same `NavigationStack` corrupts the stack's internal data model. The destination-based variant manages its own push/pop state outside the `NavigationPath`, so calling `path.removeLast()` may pop two screens instead of one, or leave ghost entries in the path. This is the single most common cause of "blank screen" bugs during incremental migration to `NavigationStack`.

**Incorrect (mixed link styles in the same stack):**

```swift
// BAD: Two link styles fighting over the same stack.
// destination-based links bypass NavigationPath entirely,
// causing removeLast() to double-pop or crash.
struct CatalogView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            List {
                // Legacy style — pushes outside the path
                NavigationLink(destination: CategoryDetailView(id: "shoes")) {
                    Text("Shoes")
                }

                // Modern style — pushes via the path
                NavigationLink(value: Category(id: "hats")) {
                    Text("Hats")
                }
            }
            .navigationDestination(for: Category.self) { cat in
                CategoryDetailView(id: cat.id)
            }
        }
    }
}
```

**Correct (all value-based links with a single destination registration):**

```swift
// GOOD: Every link pushes through NavigationPath.
// removeLast(), popToRoot, and deep-link append all work
// because there is a single source of truth for the stack.
@Equatable
struct CatalogView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            List {
                NavigationLink(value: Category(id: "shoes")) {
                    Text("Shoes")
                }

                NavigationLink(value: Category(id: "hats")) {
                    Text("Hats")
                }
            }
            .navigationDestination(for: Category.self) { category in
                CategoryDetailView(id: category.id)
            }
        }
    }
}
```
