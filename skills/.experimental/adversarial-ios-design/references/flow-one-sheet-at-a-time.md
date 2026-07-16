---
title: Present one sheet at a time from a context
tags: flow, sheets, modality, navigation
---

## Present one sheet at a time from a context

The wrong default for a multistep modal flow is stacking presentations — a sheet presenting another sheet for its next step. Each stacked card shrinks and dims the one beneath it, the dismiss gesture becomes ambiguous about which layer it targets, and the user's mental model of "where am I" collapses. The HIG is explicit: "Display only one sheet at a time from the main interface… If something people do within a sheet results in another sheet appearing, close the first sheet before displaying the new one." Steps of one flow belong to one sheet's internal `NavigationStack`; a genuinely separate modal waits for the first to dismiss.

**Evidence of violation:** a `.sheet` or `.fullScreenCover` modifier declared inside another sheet's content, presenting a *step of the same flow* (a picker, a detail form, a follow-up screen) while the outer sheet stays presented; or two sibling presentation booleans with no mutual exclusion that can be simultaneously true. Alerts and `confirmationDialog`s are not sheets and are exempt. PASS: multistep modal flows advance by pushing within a `NavigationStack` inside one sheet; a second modal is presented only after the first dismisses (an `onDismiss` chain or a single enum-driven `.sheet(item:)`). N/A: the target presents at most one sheet. Carve-out: a system-provided presentation the flow cannot embed (a share sheet, a photo picker) presented from within a sheet — the reviewer must cite the system component; absent that evidence, fail closed.

**Incorrect (the ingredient picker stacks a second card over the recipe form):**

```swift
import SwiftUI

struct NewRecipeSheet: View {
    @State private var recipe = RecipeDraft()
    @State private var isPickingIngredients = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Recipe name", text: $recipe.name)
                Button("Add Ingredients") { isPickingIngredients = true }
            }
            .navigationTitle("New Recipe")
            // ⚠️ A sheet presented from inside a presented sheet — two stacked cards
            .sheet(isPresented: $isPickingIngredients) {
                IngredientPicker(selection: $recipe.ingredients)
            }
        }
    }
}
```

**Correct (steps of one flow push inside the sheet's own stack):**

```swift
import SwiftUI

struct NewRecipeSheet: View {
    @State private var recipe = RecipeDraft()

    var body: some View {
        NavigationStack {
            Form {
                TextField("Recipe name", text: $recipe.name)
                NavigationLink("Add Ingredients") {
                    IngredientPicker(selection: $recipe.ingredients)
                }
            }
            .navigationTitle("New Recipe")
        }
    }
}
```

Reference: [HIG — Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets), [HIG — Modality](https://developer.apple.com/design/human-interface-guidelines/modality)
