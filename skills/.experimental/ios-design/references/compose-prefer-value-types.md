---
title: Prefer Value Types for View Data
impact: HIGH
impactDescription: eliminates an entire class of shared-mutation bugs — value types reduce unintended cross-view side effects to 0, and SwiftUI diffing is 2-5x faster on structs vs class-backed models due to bitwise equality checks
tags: compose, value-types, struct, kocienda-creative-selection, state
---

## Prefer Value Types for View Data

Kocienda's creative selection demands pieces that can be composed without hidden side effects. Structs in Swift are value types — when you pass one to a child view, the child gets its own copy. Reference types (classes) share a single instance, meaning mutations in one view silently affect every other view holding a reference. This invisible coupling is the enemy of composition: you can't freely recombine pieces when changing one changes all the others.

**Incorrect (class shared by reference — silent mutation coupling):**

```swift
class RecipeData {
    var title: String
    var servings: Int
    var isFavorite: Bool
}

struct RecipeCard: View {
    let recipe: RecipeData

    var body: some View {
        // Mutating recipe.isFavorite here affects every other view
        // holding a reference to the same instance
    }
}
```

**Correct (struct copied by value — independent instances):**

```swift
struct Recipe: Identifiable {
    let id: UUID
    var title: String
    var servings: Int
    var isFavorite: Bool
}

struct RecipeCard: View {
    let recipe: Recipe  // Independent copy

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.title)
                .font(.headline)

            HStack {
                Label("\\(recipe.servings) servings", systemImage: "person.2")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(recipe.isFavorite ? .red : .secondary)
            }
        }
    }
}
```

**Value type hierarchy:**
- Model data (Recipe, User, Order) → `struct`
- State management that needs identity → `@Observable class` (explicit choice)
- View configuration (style, layout params) → `struct` or `enum`
- Pure data transfer → `struct`

**When to use reference types:** When you need shared mutable state across many views (the app's data model), use `@Observable class`. This is an explicit architectural choice — the sharing is intentional, not accidental.

Reference: [Choosing Between Structures and Classes - Apple](https://developer.apple.com/documentation/swift/choosing-between-structures-and-classes)
