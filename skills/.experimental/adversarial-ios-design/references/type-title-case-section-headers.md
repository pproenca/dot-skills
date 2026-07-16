---
title: Use title-style capitalization in section headers
tags: type, section-headers, capitalization, lists
---

## Use title-style capitalization in section headers

The wrong default is pre-iOS 26 muscle memory: `Text("RECENT ACTIVITY")` or `.textCase(.uppercase)` on section headers. The system convention flipped with the new design system — lists, tables, and forms now optimize legibility with title-style capitalization. On a standard `Section` header the system re-renders the text title-style regardless, so the uppercase code is dead weight Apple explicitly says to update; on custom header views and all-caps string literals outside standard containers, the caps actually render and look a generation old next to every system screen. Write headers in title style and let `.textCase` stay at its default.

**Evidence of violation:** `.textCase(.uppercase)` applied to a section header or list header content; or an all-caps string literal ("RECENT ACTIVITY", "YOUR PLANTS") supplied as a `Section` header or custom header label — cite the modifier or literal. PASS: title-style capitalization ("Recent Activity"); `.textCase(nil)` or the default left untouched. A legitimately all-caps token — an acronym or trademarked name ("FAQ", "VAT") — may be claimed with the token cited; absent that evidence, fail closed. N/A: the deployment target predates iOS 26, where the platform convention for grouped headers was still uppercase; or the target has no section headers.

**Incorrect (uppercase headers fight the iOS 26 convention — dead code on standard sections, shouting on custom ones):**

```swift
import SwiftUI

struct PortfolioView: View {
    let holdings: [Holding]

    var body: some View {
        List {
            Section("RECENT ACTIVITY") { // ⚠️ all-caps header against the systemwide convention
                ForEach(holdings) { holding in
                    HoldingRow(holding: holding)
                }
            }
        }
    }
}
```

**Correct (title-style capitalization matches every system screen):**

```swift
import SwiftUI

struct PortfolioView: View {
    let holdings: [Holding]

    var body: some View {
        List {
            Section("Recent Activity") {
                ForEach(holdings) { holding in
                    HoldingRow(holding: holding)
                }
            }
        }
    }
}
```

Reference: [Adopting Liquid Glass](https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass)
