---
title: Keep nested corner radii concentric with their container
tags: layout, corner-radius, concentric, geometry
---

## Keep nested corner radii concentric with their container

The wrong default is a grab-bag of unrelated radius literals — a `cornerRadius(12)` card holding a `cornerRadius(12)` thumbnail behind 16 points of padding — so the inner corner visibly overshoots the outer one and the nesting reads as misaligned. Concentric shapes share a corner center: the inner radius equals the outer radius minus the padding between them. Pill-shaped controls get this for free from `Capsule`, and the container-concentric APIs compute it automatically.

**Evidence of violation:** restricted to nested rounded shapes with literal values — a rounded shape inside another rounded shape where the inner corner radius is greater than or equal to the outer radius at the same corner despite nonzero padding between them (concentric arithmetic requires inner = outer − padding); or a pill-shaped control (radius equal to half its fixed height) built from a radius literal where `Capsule` expresses the intent. Cite both literals and the padding. PASS: `Capsule()` for pills; `ConcentricRectangle`/container-concentric corner APIs (iOS 26) or `.containerShape`-derived shapes; nested literals whose inner = outer − padding arithmetic checks out. N/A: no nested rounded shapes in the target, or radii computed from non-literal values the reviewer cannot evaluate — cite which. On deployment targets before iOS 26 the concentric APIs are unavailable; judge only the literal arithmetic there.

**Incorrect (inner corner overshoots its container and the nesting looks warped):**

```swift
import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(recipe.photoName)
                .resizable()
                .scaledToFill()
                .clipShape(.rect(cornerRadius: 16)) // ⚠️ inner 16 ≥ outer 16 across 12pt padding
            Text(recipe.title)
                .font(.headline)
        }
        .padding(12)
        .background(.secondary.opacity(0.15), in: .rect(cornerRadius: 16))
    }
}
```

**Correct (inner radius = outer radius − padding, so the corners share a center):**

```swift
import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(recipe.photoName)
                .resizable()
                .scaledToFill()
                .clipShape(.rect(cornerRadius: 4))
            Text(recipe.title)
                .font(.headline)
        }
        .padding(12)
        .background(.secondary.opacity(0.15), in: .rect(cornerRadius: 16))
    }
}
```

Reference: [WWDC25 — Get to know the new design system](https://developer.apple.com/videos/play/wwdc2025/356/)
