---
title: Avoid Mixing Segue and Programmatic Navigation
impact: HIGH
impactDescription: eliminates inconsistent navigation behavior
tags: nav, segue, programmatic, consistency
---

## Avoid Mixing Segue and Programmatic Navigation

When a flow uses storyboard segues for forward navigation but programmatic calls for backward navigation (or vice versa), the navigation graph in Interface Builder becomes incomplete and misleading. Developers cannot trace the full flow visually, and UIKit may handle animations and lifecycle events differently between the two approaches.

**Incorrect (segues for push, manual code for pop within the same flow):**

```swift
// RecipeListViewController.swift
// Forward: uses storyboard segue
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowRecipeDetail",
       let detailVC = segue.destination as? RecipeDetailViewController {
        detailVC.recipe = selectedRecipe
    }
}

// RecipeDetailViewController.swift
@IBAction func editRecipe(_ sender: UIButton) {
    // Forward: switches to programmatic navigation mid-flow
    let storyboard = UIStoryboard(name: "Recipes", bundle: nil)
    let editVC = storyboard.instantiateViewController(
        withIdentifier: "RecipeEditViewController"
    ) as! RecipeEditViewController
    editVC.recipe = recipe
    navigationController?.pushViewController(editVC, animated: true)
}
```

**Correct (consistent segue-based navigation throughout the flow):**

```swift
// RecipeListViewController.swift
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowRecipeDetail",
       let detailVC = segue.destination as? RecipeDetailViewController {
        detailVC.recipe = selectedRecipe
    }
}

// RecipeDetailViewController.swift
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "EditRecipe",
       let editVC = segue.destination as? RecipeEditViewController {
        editVC.recipe = recipe
    }
}

// RecipeEditViewController.swift
@IBAction func unwindToRecipeDetail(_ segue: UIStoryboardSegue) {
    // Handle save/cancel result from edit flow
}
```

**Benefits:**
- The entire navigation flow is visible in Interface Builder's storyboard canvas
- Forward and backward transitions use matched animation contexts
- New team members can understand the full flow without reading every view controller
