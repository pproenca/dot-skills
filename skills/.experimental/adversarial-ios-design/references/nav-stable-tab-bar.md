---
title: Keep every tab present and the tab bar visible on pushes
tags: nav, tab-bar, visibility, empty-sections
---

## Keep every tab present and the tab bar visible on pushes

Two wrong defaults destabilize the tab bar. The first hides it on detail pushes "for immersion" — but when the bar disappears, people forget which area of the app they are in and lose the one-tap path to every other section. The second conditionally removes or disables a tab when its content is unavailable (logged out, empty), so the bar reshuffles under the user's fingers. The bar is the app's map; a map that redraws itself is worse than none. An unavailable section stays in the bar and explains itself inside the tab.

**Evidence of violation:** either shape — (1) `.toolbar(.hidden, for: .tabBar)` or `.toolbarVisibility(.hidden, for: .tabBar)` (or UIKit `hidesBottomBarWhenPushed = true`) on a pushed, non-modal destination; (2) a `Tab` wrapped in a runtime `if`/`guard` on session or content state, or a tab gated by `.disabled(...)`. PASS: the tab bar untouched on all pushed views, and all tabs unconditionally present, with unavailable sections rendering an explanatory view (`ContentUnavailableView` or equivalent) inside the tab — cite both. Carve-outs: a `.sheet`/`.fullScreenCover` covers the bar by definition, and `.tabBarMinimizeBehavior(.onScrollDown)` minimizes without removing it — cite the modifier to claim either; absent that evidence, fail closed. N/A: no `TabView` in the target.

**Incorrect (the bar vanishes on push and a tab vanishes on logout):**

```swift
import SwiftUI

struct RecipeRootView: View {
    @Environment(SessionStore.self) private var session

    var body: some View {
        TabView {
            Tab("Recipes", systemImage: "book") {
                NavigationStack {
                    RecipeListView()
                        .navigationDestination(for: Recipe.self) { recipe in
                            RecipeDetailView(recipe: recipe)
                                // ⚠️ Pushed detail hides the tab bar
                                .toolbar(.hidden, for: .tabBar)
                        }
                }
            }
            // ⚠️ The tab itself disappears when logged out
            if session.isLoggedIn {
                Tab("Meal Plans", systemImage: "calendar") {
                    NavigationStack { MealPlanListView() }
                }
            }
        }
    }
}
```

**Correct (bar stays put; the section explains its own unavailability):**

```swift
import SwiftUI

struct RecipeRootView: View {
    @Environment(SessionStore.self) private var session

    var body: some View {
        TabView {
            Tab("Recipes", systemImage: "book") {
                NavigationStack {
                    RecipeListView()
                        .navigationDestination(for: Recipe.self) { recipe in
                            RecipeDetailView(recipe: recipe)
                        }
                }
            }
            Tab("Meal Plans", systemImage: "calendar") {
                NavigationStack {
                    if session.isLoggedIn {
                        MealPlanListView()
                    } else {
                        ContentUnavailableView(
                            "Sign In to Plan Meals",
                            systemImage: "calendar.badge.exclamationmark",
                            description: Text("Meal plans sync across your devices once you sign in.")
                        )
                    }
                }
            }
        }
    }
}
```

Reference: [HIG — Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars)
