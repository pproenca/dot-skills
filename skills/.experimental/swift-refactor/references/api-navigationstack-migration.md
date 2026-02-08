---
title: Replace NavigationView with NavigationStack
impact: CRITICAL
impactDescription: enables programmatic navigation and state restoration
tags: api, navigation, navigationstack, deprecated, migration
---

## Replace NavigationView with NavigationStack

NavigationView was deprecated in iOS 16. It couples destination views directly to links, making programmatic navigation, deep linking, and state restoration impossible. NavigationStack decouples navigation targets from links using value-based routing and NavigationPath, enabling full programmatic control over the navigation stack.

**Incorrect (deprecated NavigationView with coupled destinations):**

```swift
struct RecipeListView: View {
    @State private var recipes: [Recipe] = []

    var body: some View {
        NavigationView {
            List(recipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    RecipeRow(recipe: recipe)
                }
            }
            .navigationTitle("Recipes")
        }
        // No way to programmatically push/pop views
        // No support for deep linking or state restoration
    }
}
```

**Correct (NavigationStack with value-based routing):**

```swift
struct RecipeListView: View {
    @State private var recipes: [Recipe] = []
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List(recipes) { recipe in
                NavigationLink(value: recipe) {
                    RecipeRow(recipe: recipe)
                }
            }
            .navigationTitle("Recipes")
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
        // Programmatic navigation: navigationPath.append(recipe)
        // Pop to root: navigationPath.removeLast(navigationPath.count)
    }
}
```

Reference: [Migrating to new navigation types](https://developer.apple.com/documentation/swiftui/migrating-to-new-navigation-types)
