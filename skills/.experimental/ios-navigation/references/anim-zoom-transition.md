---
title: Use Zoom Navigation Transition for Hero Animations (iOS 18+)
impact: HIGH
impactDescription: O(1) hero animation setup replaces 200+ lines of manual transition code
tags: anim, zoom, hero, navigation-transition, ios18
---

## Use Zoom Navigation Transition for Hero Animations (iOS 18+)

The `.navigationTransition(.zoom)` API provides first-class hero animations for navigation pushes. It automatically handles matching source and destination geometry, interactive back gestures, and accessibility reduce-motion fallbacks. Building equivalent behavior manually requires hundreds of lines of fragile transition code that breaks across OS updates.

**Incorrect (manual matchedGeometryEffect for navigation hero):**

```swift
// BAD: matchedGeometryEffect does NOT work across NavigationStack pushes.
// This produces broken, jumpy animations and ignores interactive pop gestures.
struct RecipeListView: View {
    @Namespace private var heroNamespace
    @State private var selectedRecipe: Recipe?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(recipes) { recipe in
                        NavigationLink(value: recipe) {
                            RecipeCard(recipe: recipe)
                                .matchedGeometryEffect(
                                    id: recipe.id,
                                    in: heroNamespace
                                ) // WRONG: this namespace is lost on push
                        }
                    }
                }
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
                    .matchedGeometryEffect(
                        id: recipe.id,
                        in: heroNamespace,
                        isSource: false
                    ) // WRONG: animation won't connect across navigation push
            }
        }
    }
}
```

**Correct (zoom navigation transition with matched source):**

```swift
@Equatable
struct RecipeListView: View {
    @Namespace private var zoomNamespace

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(recipes) { recipe in
                        NavigationLink(value: recipe) {
                            RecipeCard(recipe: recipe)
                        }
                        .matchedTransitionSource(
                            id: recipe.id,
                            in: zoomNamespace
                        )
                    }
                }
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
                    .navigationTransition(
                        .zoom(
                            sourceID: recipe.id,
                            in: zoomNamespace
                        )
                    )
            }
        }
    }
}
```
