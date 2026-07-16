---
title: Title every pushed screen and sheet, never with the app name
tags: nav, navigation-title, orientation, sheets
---

## Title every pushed screen and sheet, never with the app name

The wrong default is shipping pushed destinations and sheets with an empty navigation bar, or stamping the app's name on interior screens. A missing title strands the user — the bar is where they look to confirm where they landed, and the next push writes an unlabeled entry into the Back button's history menu. The app name says nothing they don't already know. Every destination and every modal names its content or its task in a few words.

**Evidence of violation:** a `NavigationStack` destination or a sheet's root view with no `.navigationTitle` (and no toolbar title item); or `.navigationTitle` set to the app's own name on an interior screen. The absence is the violation — FAIL, not N/A. Carve-out: a screen whose content is its own identity — a full-screen photo, video, or poster-style detail whose hero content replaces the title by design — the reviewer must cite the full-bleed content and the deliberate title omission; absent that evidence, fail closed. PASS: every destination and sheet declares a concise content or task title — cite them. N/A: the target contains no pushed destinations or sheets.

**Incorrect (an untitled sheet and an app-name title strand the user):**

```swift
import SwiftUI

struct PortfolioListView: View {
    @State private var isAddingHolding = false

    var body: some View {
        List(sampleHoldings) { holding in
            NavigationLink(holding.ticker, value: holding)
        }
        // ⚠️ Interior screen titled with the app's name
        .navigationTitle("StockPilot")
        .navigationDestination(for: Holding.self) { holding in
            // ⚠️ Pushed detail has no title at all
            HoldingDetailView(holding: holding)
        }
        .sheet(isPresented: $isAddingHolding) {
            NavigationStack {
                AddHoldingForm()
            }
        }
    }
}
```

**Correct (each screen names its content or task):**

```swift
import SwiftUI

struct PortfolioListView: View {
    @State private var isAddingHolding = false

    var body: some View {
        List(sampleHoldings) { holding in
            NavigationLink(holding.ticker, value: holding)
        }
        .navigationTitle("Portfolio")
        .navigationDestination(for: Holding.self) { holding in
            HoldingDetailView(holding: holding)
                .navigationTitle(holding.ticker)
        }
        .sheet(isPresented: $isAddingHolding) {
            NavigationStack {
                AddHoldingForm()
                    .navigationTitle("New Holding")
            }
        }
    }
}
```

Reference: [HIG — Toolbars](https://developer.apple.com/design/human-interface-guidelines/toolbars), [HIG — Modality](https://developer.apple.com/design/human-interface-guidelines/modality)
