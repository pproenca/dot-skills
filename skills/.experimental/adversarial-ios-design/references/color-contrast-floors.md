---
title: Meet the numeric contrast floors for text
tags: color, contrast, wcag, accessibility
---

## Meet the numeric contrast floors for text

The wrong default is eyeballing a light-gray caption on white or tinted text on a tinted card and shipping whatever reads on the author's display. Apple's floor is numeric, the same one Accessibility Inspector enforces: **4.5:1** for text up to 17 pt, **3:1** for text at 18 pt or larger or bold — and for custom pairs in Dark Mode, strive for 7:1 on small text. A pair that misses the floor is illegible to low-vision users and washes out in sunlight for everyone.

**Evidence of violation:** a custom foreground/background pair whose values are recoverable — literals in a theme definition or asset-catalog component values — with a computed WCAG ratio below 4.5:1 for text up to 17 pt, or below 3:1 for text at 18 pt+ or bold; cite the two values and the ratio. Screenshot fallback: when values are not in code but screenshots are provided, sample the center of a glyph stroke against the adjacent background and compute the same ratio. PASS: all computed custom pairs meet the floor (cite one representative computation), or the pairing is entirely system-defined — label colors on system backgrounds auto-pass because Apple maintains their variants. This rule computes only pairs where at least one side is a custom color with a recoverable value; a pairing composed solely of system-defined constants (`Color.gray` on `Color.white`, `.secondary` on a system background) is out of this rule's scope — its fitness is judged by `color-label-ladder` and `color-system-backgrounds`, and without a screenshot it is N/A here, not FAIL and not a computed PASS. N/A: neither recoverable values nor screenshots exist for the pair in question — state which pair could not be judged.

**Incorrect (2.32:1 — a caption that disappears for low-vision readers):**

```swift
import SwiftUI

enum RecipeTheme {
    static let cardBackground = Color(.displayP3, red: 1.0, green: 1.0, blue: 1.0)
    static let captionInk = Color(.displayP3, red: 0.67, green: 0.67, blue: 0.67) // ⚠️ #ABABAB on white = 2.32:1, floor is 4.5:1
}

struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading) {
            Text(recipe.title).font(.headline)
            Text("\(recipe.minutes) min · \(recipe.servings) servings")
                .font(.caption)
                .foregroundStyle(RecipeTheme.captionInk)
        }
        .padding()
        .background(RecipeTheme.cardBackground, in: .rect(cornerRadius: 16))
    }
}
```

**Correct (4.61:1 — same hierarchy, legible pair):**

```swift
import SwiftUI

enum RecipeTheme {
    static let cardBackground = Color(.displayP3, red: 1.0, green: 1.0, blue: 1.0)
    static let captionInk = Color(.displayP3, red: 0.46, green: 0.46, blue: 0.46) // #757575 on white = 4.61:1
}

struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading) {
            Text(recipe.title).font(.headline)
            Text("\(recipe.minutes) min · \(recipe.servings) servings")
                .font(.caption)
                .foregroundStyle(RecipeTheme.captionInk)
        }
        .padding()
        .background(RecipeTheme.cardBackground, in: .rect(cornerRadius: 16))
    }
}
```

Reference: [Human Interface Guidelines — Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility), [Human Interface Guidelines — Dark Mode](https://developer.apple.com/design/human-interface-guidelines/dark-mode)
