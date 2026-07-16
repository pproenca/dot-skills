---
title: Style text and colors semantically, not with fixed sizes and hardcoded values
tags: access, dynamic-type, dark-mode, semantic-styling
---

## Style text and colors semantically, not with fixed sizes and hardcoded values

The wrong default is `.font(.system(size: 17))` and raw color literals. Hardcoded fonts and colors cannot adapt to their environment. Semantic styles describe the element's role instead — hierarchical options like `.secondary` for a foreground style or `.headline` for typography let SwiftUI resolve the final appearance from the user's current environment, so the interface stays legible and balanced when the user toggles Dark Mode, increases their text size, or enables high-contrast settings. Fixed values opt the interface out of all three.

**Evidence of violation:** `Font.system(size:)` (or `.font(.system(size:))`) with a numeric literal and no Dynamic-Type-relative mechanism; or `Color(red:green:blue:)` / hex-literal / `UIColor`-wrapped colors constructed inline in view code where a semantic style or asset-catalog color serves the same role. PASS: text styles (`.headline`, `.caption`), hierarchical styles (`.secondary`, `.tertiary`), system semantic colors, and asset-catalog colors (`Color("BrandPrimary")` or generated asset symbols like `.brandPrimary`) — asset-catalog colors adapt per appearance and contrast, so they satisfy this rule. PASS: `Font.system(size:)` wrapped in a Dynamic-Type-relative mechanism such as `@ScaledMetric` — the reviewer must cite the wrapper. N/A: colors that are part of genuinely decorative fixed artwork — the carve-out must be citable, e.g. an `Image(decorative:)` context or a comment; absent that evidence, fail closed.

**Incorrect (ignores Dynamic Type, Dark Mode, and contrast settings):**

```swift
import SwiftUI

struct EcosystemOverview: View {
    let name: String
    let details: String

    var body: some View {
        VStack(alignment: .leading) {
            // ⚠️ Fixed font and hardcoded color cannot adapt to the environment
            Text(name)
                .font(.system(size: 17, weight: .semibold))

            Text(details)
                .foregroundStyle(Color(red: 0.45, green: 0.45, blue: 0.47))
        }
    }
}
```

**Correct (roles resolve per environment — text size, appearance, contrast):**

```swift
import SwiftUI

struct EcosystemOverview: View {
    let name: String
    let details: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
                .font(.headline)

            Text(details)
                .foregroundStyle(.secondary)
        }
    }
}
```
