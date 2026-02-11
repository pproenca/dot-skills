---
title: Provide Multiple Sheet Detents with Drag Indicator
impact: HIGH
impactDescription: Full-height sheets obscure 100% of the parent screen — multi-detent sheets preserve context and reduce perceived disruption by 40-60% for peek-and-browse flows
tags: trans, sheet, detent, drag-indicator, maps, progressive-disclosure
---

## Provide Multiple Sheet Detents with Drag Indicator

A full-height sheet completely hides the content behind it, forcing a context switch. When the content being presented is supplementary — search results, a list of nearby locations, filter options — the user benefits from seeing both the sheet and the parent view simultaneously. Apple Maps uses a half-height sheet for search results that the user can drag to full height when needed. Without `.presentationDragIndicator(.visible)`, users have no affordance that the sheet can be resized.

**Incorrect (full-height sheet covering all parent context):**

```swift
struct MapView: View {
    @State private var showResults = false

    var body: some View {
        Map()
            .onAppear { showResults = true }
            .sheet(isPresented: $showResults) {
                // Full-height sheet covers the entire map —
                // user cannot see pins or their current location
                SearchResultsList(results: nearbyPlaces)
            }
    }
}
```

**Correct (multi-detent sheet with drag indicator and background interaction):**

```swift
struct MapView: View {
    @State private var showResults = false
    @State private var selectedDetent: PresentationDetent = .medium

    var body: some View {
        Map()
            .onAppear { showResults = true }
            .sheet(isPresented: $showResults) {
                NavigationStack {
                    SearchResultsList(results: nearbyPlaces)
                        .navigationTitle("Nearby")
                        .navigationBarTitleDisplayMode(.inline)
                }
                // Let users peek at medium height or expand to full
                .presentationDetents([.medium, .large], selection: $selectedDetent)
                // Show the grab handle so users know they can resize
                .presentationDragIndicator(.visible)
                // Allow interaction with the map while sheet is at medium
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                // Prevent full dismissal — results should always be visible
                .interactiveDismissDisabled()
            }
    }
}
```

**Available detent options:**
- `.medium` — approximately half screen height
- `.large` — full height (default if no detents specified)
- `.fraction(0.25)` — custom fraction of screen height
- `.height(200)` — fixed pixel height
- Custom detents via `CustomPresentationDetent` protocol for content-driven sizing

**When NOT to use:**
- Task-oriented sheets (compose, edit) where the user should focus entirely on the task — use `.large` only
- Confirmation dialogs or alerts — use `.alert` or `.confirmationDialog` instead

**Reference:** Apple Maps (search results sheet), WWDC 2022 "Customize and resize sheets in UIKit" — the SwiftUI API mirrors the UIKit `UISheetPresentationController` behavior.
