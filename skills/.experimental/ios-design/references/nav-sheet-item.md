---
title: Use Item Binding for Sheet Presentation
impact: HIGH
impactDescription: prevents modal state bugs and simplifies data passing
tags: nav, sheet, modal, binding, presentation
---

## Use Item Binding for Sheet Presentation

Use `.sheet(item:)` instead of `.sheet(isPresented:)` when the sheet needs data. This ensures the data exists when the sheet appears.

**Incorrect (boolean + separate state):**

```swift
struct RecipeList: View {
    @State private var recipes: [Recipe] = []
    @State private var showingDetail = false
    @State private var selectedRecipe: Recipe?  // Can be nil when sheet opens

    var body: some View {
        List(recipes) { recipe in
            Button(recipe.name) {
                selectedRecipe = recipe
                showingDetail = true
            }
        }
        .sheet(isPresented: $showingDetail) {
            if let recipe = selectedRecipe {  // Force unwrap risk
                RecipeDetail(recipe: recipe)
            }
        }
    }
}
```

**Correct (item binding):**

```swift
struct RecipeList: View {
    @State private var recipes: [Recipe] = []
    @State private var selectedRecipe: Recipe?  // Single source of truth

    var body: some View {
        List(recipes) { recipe in
            Button(recipe.name) {
                selectedRecipe = recipe  // Setting triggers sheet
            }
        }
        .sheet(item: $selectedRecipe) { recipe in
            // recipe is guaranteed non-nil
            RecipeDetail(recipe: recipe)
        }
    }
}
```

**Make your model Identifiable:**

```swift
struct Recipe: Identifiable {
    let id: UUID
    var name: String
    var ingredients: [Ingredient]
}
```

**Multiple sheet types:**

```swift
struct ContentView: View {
    @State private var activeSheet: SheetType?

    var body: some View {
        Button("Edit") { activeSheet = .edit(item) }
        Button("Share") { activeSheet = .share(item) }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .edit(let item):
                    EditView(item: item)
                case .share(let item):
                    ShareView(item: item)
                }
            }
    }
}

enum SheetType: Identifiable {
    case edit(Item)
    case share(Item)

    var id: String {
        switch self {
        case .edit(let item): return "edit-\(item.id)"
        case .share(let item): return "share-\(item.id)"
        }
    }
}
```

Reference: [SwiftUI Sheet Documentation](https://developer.apple.com/documentation/swiftui/view/sheet(item:ondismiss:content:))
