---
title: Use LazyView Wrapper for Pre-iOS 16 Destination Loading
impact: LOW-MEDIUM
impactDescription: defers O(n) destination construction to O(1) on-tap for pre-iOS 16
tags: perf, lazy-view, legacy, navigation-view
---

## Use LazyView Wrapper for Pre-iOS 16 Destination Loading

For codebases still targeting iOS 15 or earlier using `NavigationView` with `NavigationLink(destination:)`, all destinations are eagerly constructed at list render time. Since `NavigationLink(value:)` requires iOS 16+, use a `LazyView` wrapper to defer destination construction until the user actually taps the link. This is a bridge pattern — migrate to `NavigationStack` when your minimum deployment target reaches iOS 16.

**Incorrect (eager destination construction in NavigationView):**

```swift
// iOS 15 target — NavigationStack not available.
struct LegacyRecipeListView: View {
    let recipes: [Recipe] // 200 recipes

    var body: some View {
        NavigationView {
            List(recipes) { recipe in
                // BAD: RecipeDetailView is constructed for ALL 200 rows
                // when the list renders. Each detail view allocates a
                // view model, image loader, and nutrition calculator.
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    RecipeRowView(recipe: recipe)
                }
            }
            .navigationTitle("Recipes")
        }
    }
}

struct RecipeDetailView: View {
    @StateObject private var viewModel: RecipeDetailViewModel

    init(recipe: Recipe) {
        // Runs 200 times at list render time.
        _viewModel = StateObject(wrappedValue: RecipeDetailViewModel(recipe: recipe))
    }

    var body: some View {
        ScrollView { /* heavy content */ }
            .task { await viewModel.loadNutrition() }
    }
}
```

**Correct (LazyView wrapper defers construction):**

```swift
// Generic wrapper that defers view construction until body is called.
// SwiftUI evaluates NavigationLink's destination label eagerly,
// but LazyView's body (which builds the real view) is called
// only when SwiftUI actually displays the destination.
struct LazyView<Content: View>: View {
    let build: () -> Content

    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: some View {
        // Construction happens HERE — on navigation, not at list render.
        build()
    }
}

// iOS 15 target — using LazyView as a bridge.
struct LegacyRecipeListView: View {
    let recipes: [Recipe] // 200 recipes

    var body: some View {
        NavigationView {
            List(recipes) { recipe in
                // LazyView captures the construction in a closure.
                // The closure executes only when the user taps this row.
                // Cost at render: 200 lightweight closures vs 200 full view graphs.
                NavigationLink(destination: LazyView(RecipeDetailView(recipe: recipe))) {
                    RecipeRowView(recipe: recipe)
                }
            }
            .navigationTitle("Recipes")
        }
    }
}

// TODO: When minimum target reaches iOS 16, migrate to:
// NavigationStack + NavigationLink(value:) + .navigationDestination(for:)
// and remove LazyView entirely.
```
