---
title: Minimize State Scope to Reduce Re-Renders
impact: HIGH
impactDescription: state owned too high in the hierarchy causes every descendant to re-evaluate when it changes — moving state to the narrowest owner reduces body evaluations by 40-70%
tags: craft, state, scope, performance, kocienda-craft, re-render
---

## Minimize State Scope to Reduce Re-Renders

Kocienda's craft applies at the architectural level: when state lives higher in the hierarchy than it needs to, every view between the owner and the consumer re-evaluates unnecessarily. The iPhone keyboard team optimized every touch handler to avoid unnecessary work — the same discipline applies to SwiftUI state. A `@State` property should live in the view that uses it, not in a parent that happens to be convenient. Moving state to the narrowest possible scope is the single most impactful performance optimization in SwiftUI.

**Incorrect (state hoisted too high — entire list re-renders on toggle):**

```swift
struct RecipeListView: View {
    @State private var expandedRecipeID: Recipe.ID?  // Owned at list level

    var body: some View {
        // EVERY RecipeRow re-evaluates when expandedRecipeID changes
        List(recipes) { recipe in
            RecipeRow(
                recipe: recipe,
                isExpanded: expandedRecipeID == recipe.id,
                onToggle: { expandedRecipeID = recipe.id }
            )
        }
    }
}
```

**Correct (state scoped to the row that uses it):**

```swift
struct RecipeListView: View {
    var body: some View {
        List(recipes) { recipe in
            RecipeRow(recipe: recipe)
        }
    }
}

struct RecipeRow: View {
    let recipe: Recipe
    @State private var isExpanded = false  // Owned by the row

    var body: some View {
        VStack(alignment: .leading) {
            Text(recipe.title)
                .font(.headline)

            if isExpanded {
                Text(recipe.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .onTapGesture { isExpanded.toggle() }
    }
}
```

**Scope checklist:**
- Does only one view read this state? → `@State private` in that view
- Does a parent and child share this state? → `@State` in parent, `@Binding` in child
- Does one child among many siblings need it? → `@State` in the child, not the parent
- Do many distant views need it? → `@Environment` at the appropriate ancestor

**When state MUST be hoisted:** When the parent needs to coordinate between children (e.g., "only one row expanded at a time"), the parent must own the state. But this is the exception, not the default.

Reference: [Managing user interface state - Apple](https://developer.apple.com/documentation/swiftui/managing-user-interface-state)
