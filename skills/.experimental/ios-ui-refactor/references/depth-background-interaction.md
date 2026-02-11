---
title: Enable Background Interaction for Peek-Style Sheets
impact: HIGH
impactDescription: dimming and disabling the background behind small-detent sheets breaks spatial context and forces users to dismiss the sheet before interacting with the map, list, or content underneath — enabling background interaction preserves the peek-and-interact pattern used in Apple Maps
tags: depth, sheets, detents, interaction, background, maps
---

## Enable Background Interaction for Peek-Style Sheets

When a sheet sits at a small or medium detent, the content behind it is still visible and spatially relevant. Dimming that content and blocking interaction forces the user into a modal mindset even though the sheet was designed as a non-modal overlay. Apple Maps keeps the map fully interactive behind its search and results sheet — users pan, zoom, and tap pins while the sheet stays docked at a small detent. Without `.presentationBackgroundInteraction(.enabled(upThrough:))`, every sheet becomes a full interruption regardless of its size.

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
