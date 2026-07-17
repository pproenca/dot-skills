---
title: Use zoom transitions when detail content originates from a tapped element
tags: motion, zoom-transition, matched-transition, navigation
---

## Use zoom transitions when detail content originates from a tapped element

The wrong default is a grid or card cell displaying artwork that pushes a detail screen led by the same artwork via the default slide — the image the user tapped teleports from its cell to a hero position instead of visibly becoming the detail view. Since iOS 18, SwiftUI ships the system pairing for exactly this: mark the cell with `.matchedTransitionSource(id:in:)` and give the destination `.navigationTransition(.zoom(sourceID:in:))`, and the tapped element zooms into the detail screen the way Photos and the App Store do. When the same prominent visual sits on both sides of a push, the slide transition is a missed system affordance, not a neutral choice.

**Evidence of violation:** a filmstrip of the recorded push in which the detail screen slides in from the trailing edge while the same image or artwork the user tapped leads the destination — the shared visual teleports from cell to hero position instead of visibly growing into it. Cite the tiles showing the slide and both sides in code: the cell's visual and the destination's leading visual rendering the same model data, with no `.matchedTransitionSource(id:in:)` on the cell paired with `.navigationTransition(.zoom(sourceID:in:))` on the destination, and no `matchedGeometryEffect` alternative. Code alone cannot FAIL this rule: the missing modifier pair on a shared-visual push is a **candidate** — when no recording covers the push, report it as N/A with the reason "recording evidence unavailable — candidate at file:line", never FAIL. PASS: the filmstrip shows the tapped cell growing into the detail screen, or the source/destination modifier pair is present — cite the tiles or both modifiers — or the destination shares no prominent visual with the tapped cell. N/A: navigation between textual or structurally different screens where no visual element carries across the push. N/A: the deployment target is below iOS 18 and no `matchedGeometryEffect` alternative is reasonable — the reviewer must cite the deployment target; absent that evidence, fail closed.

**Incorrect (the tapped recipe photo teleports — the detail slides in from the side carrying the same image):**

```swift
import SwiftUI

struct Recipe: Identifiable, Hashable {
    let id = UUID()
    var name = ""
    var imageName = ""
}

struct RecipeGridView: View {
    let recipes: [Recipe]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))]) {
                    ForEach(recipes) { recipe in
                        // ⚠️ Same photo leads the detail, but the push is a default slide
                        NavigationLink(value: recipe) {
                            Image(recipe.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 160)
                                .clipShape(.rect(cornerRadius: 16))
                        }
                    }
                }
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
    }
}

struct RecipeDetailView: View {
    let recipe: Recipe

    var body: some View {
        ScrollView {
            Image(recipe.imageName)
                .resizable()
                .scaledToFit()
            Text(recipe.name).font(.largeTitle.bold())
        }
    }
}
```

**Correct (the cell zooms into the detail, so the photo visibly becomes the hero):**

```swift
import SwiftUI

struct Recipe: Identifiable, Hashable {
    let id = UUID()
    var name = ""
    var imageName = ""
}

struct RecipeGridView: View {
    let recipes: [Recipe]
    @Namespace private var zoomNamespace

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))]) {
                    ForEach(recipes) { recipe in
                        NavigationLink(value: recipe) {
                            Image(recipe.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 160)
                                .clipShape(.rect(cornerRadius: 16))
                        }
                        .matchedTransitionSource(id: recipe.id, in: zoomNamespace)
                    }
                }
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
                    .navigationTransition(.zoom(sourceID: recipe.id, in: zoomNamespace))
            }
        }
    }
}

struct RecipeDetailView: View {
    let recipe: Recipe

    var body: some View {
        ScrollView {
            Image(recipe.imageName)
                .resizable()
                .scaledToFit()
            Text(recipe.name).font(.largeTitle.bold())
        }
    }
}
```

Reference: [NavigationTransition.zoom(sourceID:in:)](https://developer.apple.com/documentation/swiftui/navigationtransition/zoom(sourceid:in:)), [matchedTransitionSource(id:in:)](https://developer.apple.com/documentation/swiftui/view/matchedtransitionsource(id:in:))
