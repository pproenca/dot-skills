---
title: Use NavigationStack for Hierarchical Navigation
impact: HIGH
impactDescription: type-safe value-based navigation with automatic back button support
tags: nav, navigation, swiftui, drill-down, list
---

## Use NavigationStack for Hierarchical Navigation

NavigationView is deprecated in iOS 16 and lacks type-safe destination routing. NavigationStack with `navigationDestination(for:)` provides value-based navigation that scales cleanly, supports programmatic control, and automatically manages the back button.

**Incorrect (using deprecated NavigationView with inline NavigationLink destinations):**

```swift
struct RecipeListView: View {
    let recipes: [Recipe]

    var body: some View {
        NavigationView { // deprecated in iOS 16
            List(recipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    RecipeRow(recipe: recipe)
                }
            }
            .navigationTitle("Recipes")
        }
        .navigationViewStyle(.stack)
    }
}
```

**Correct (using NavigationStack with value-based navigationDestination):**

```swift
struct RecipeListView: View {
    let recipes: [Recipe]

    var body: some View {
        NavigationStack { // replaces NavigationView
            List(recipes) { recipe in
                NavigationLink(value: recipe) { // pass value, not destination
                    RecipeRow(recipe: recipe)
                }
            }
            .navigationTitle("Recipes")
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
