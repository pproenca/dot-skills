---
title: Provide Multiple Sheet Detents with Drag Indicator
impact: HIGH
impactDescription: full-height sheets obscure 100% of the parent screen — multi-detent sheets preserve context and substantially reduce perceived disruption
tags: refined, sheet, detent, edson-prototype, rams-3, progressive-disclosure
---

## Provide Multiple Sheet Detents with Drag Indicator

A full-height sheet over a map is like putting a poster over a window — you lose the context you came to see. Multi-detent sheets let users peek at half height and expand on demand, preserving the spatial relationship between content and context. This is the difference between an interface that trusts the user to control how much they see and one that hijacks the entire screen for every interaction. Apple Maps iterated this pattern to perfection: results at medium height, full detail when you pull up, map always visible underneath.

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

**Exceptional (the creative leap) — a sheet that feels like a physical drawer:**

```swift
struct ExploreMapView: View {
    @State private var showResults = false
    @State private var selectedDetent: PresentationDetent = .fraction(0.25)
    @State private var searchText = ""

    var body: some View {
        Map(interactionModes: .all)
            .onAppear { showResults = true }
            .sheet(isPresented: $showResults) {
                NavigationStack {
                    VStack(spacing: 0) {
                        TextField("Search places...", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        SearchResultsList(results: nearbyPlaces)
                    }
                    .navigationTitle("Explore")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .presentationDetents(
                    [.fraction(0.25), .medium, .large],
                    selection: $selectedDetent
                )
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                .presentationCornerRadius(20)
                .presentationBackground(.thinMaterial)
                .interactiveDismissDisabled()
                .onChange(of: searchText) {
                    if !searchText.isEmpty {
                        selectedDetent = .medium
                    }
                }
            }
    }
}
```

Three detents instead of two changes the entire feel: the small peek shows just the search bar, a gentle invitation; pulling to medium reveals results while the map stays alive underneath for panning and tapping pins; pulling to large is a full commitment to browsing. The `.thinMaterial` background lets the map bleed through at every height, so the sheet never feels like a wall -- it feels like a frosted-glass drawer sliding over a workbench. And the `onChange` that programmatically bumps the detent when the user types is the kind of detail that makes it feel like the interface is paying attention to you, not the other way around.

**Available detent options:**
- `.medium` — approximately half screen height
- `.large` — full height (default if no detents specified)
- `.fraction(0.25)` — custom fraction of screen height
- `.height(200)` — fixed pixel height
- Custom detents via `CustomPresentationDetent` protocol for content-driven sizing

**When NOT to apply:** Task-oriented sheets (compose, edit) where the user should focus entirely on the task and `.large` is the only appropriate detent, and confirmation dialogs or alerts where `.alert` or `.confirmationDialog` is the correct pattern.

**Reference:** Apple Maps (search results sheet), WWDC 2022 "Customize and resize sheets in UIKit" — the SwiftUI API mirrors the UIKit `UISheetPresentationController` behavior.
