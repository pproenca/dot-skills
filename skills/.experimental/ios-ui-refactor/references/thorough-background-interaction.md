---
title: Enable Background Interaction for Peek-Style Sheets
impact: HIGH
impactDescription: dimming and disabling the background behind small-detent sheets breaks spatial context and forces dismissal before interaction — enabling background interaction preserves the peek pattern
tags: thorough, sheets, detents, rams-8, rams-2, interaction
---

## Enable Background Interaction for Peek-Style Sheets

Rams' thoroughness extends to interaction design. A small-detent sheet that dims and blocks the map behind it has not been thought through — the sheet was designed to peek, but the implementation forces a full modal. Rams' #2: the product is useful when users can interact with the map while browsing results, as Apple Maps demonstrates.

**Incorrect (sheet dims and blocks background even at small detent):**

```swift
struct MapExplorerView: View {
    @State private var showResults = true
    @State private var selectedDetent: PresentationDetent = .fraction(0.25)

    var body: some View {
        Map()
            .sheet(isPresented: $showResults) {
                SearchResultsSheet()
                    .presentationDetents(
                        [.fraction(0.25), .medium, .large],
                        selection: $selectedDetent
                    )
                    .presentationDragIndicator(.visible)
                    // Default behavior: background is dimmed and
                    // non-interactive — user cannot tap the map
            }
    }
}
```

**Correct (background stays interactive up through medium detent):**

```swift
struct MapExplorerView: View {
    @State private var showResults = true
    @State private var selectedDetent: PresentationDetent = .fraction(0.25)

    var body: some View {
        Map()
            .sheet(isPresented: $showResults) {
                SearchResultsSheet()
                    .presentationDetents(
                        [.fraction(0.25), .medium, .large],
                        selection: $selectedDetent
                    )
                    .presentationDragIndicator(.visible)
                    .presentationBackgroundInteraction(
                        .enabled(upThrough: .medium)
                    )
                    .presentationCornerRadius(16)
            }
    }
}

struct SearchResultsSheet: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<10) { index in
                    Label("Result \(index + 1)",
                          systemImage: "mappin.circle.fill")
                }
            }
            .navigationTitle("Nearby")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
```

**How `upThrough` works:**
- `.enabled(upThrough: .fraction(0.25))` — background interactive only at the smallest detent. Dims at `.medium` and above.
- `.enabled(upThrough: .medium)` — background interactive at `.fraction(0.25)` and `.medium`. Dims only at `.large`.
- `.enabled` (no parameter) — background always interactive, even at `.large`. Use sparingly; at large detent the user may accidentally interact with hidden content.

**When NOT to use:** Confirmation sheets, payment flows, or any modal action where background interaction would cause data loss or confusion. If the sheet requires a decision before proceeding, the background should remain dimmed and non-interactive.

Reference: [Sheets - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/sheets), [presentationBackgroundInteraction - SwiftUI](https://developer.apple.com/documentation/swiftui/view/presentationbackgroundinteraction(_:))
