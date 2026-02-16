---
title: Use Inspector for Trailing-Edge Detail Panels
impact: MEDIUM
impactDescription: replaces custom overlay/sheet logic with a single modifier, saving 30-50 lines per detail panel and gaining automatic iPhone-to-iPad adaptive layout
tags: refined, layout, ipad, edson-prototype, rams-1, navigation
---

## Use Inspector for Trailing-Edge Detail Panels

Edson's Design Out Loud recognizes that the first implementation (custom HStack sidebar with manual width management) is rarely the final one. The .inspector() modifier is Apple's refined answer — one modifier replaces 50+ lines of conditional layout code. Rams' innovation: a solution that adapts between iPhone and iPad automatically is better than one that requires manual code paths.

**Incorrect (custom overlay for a detail panel on iPad):**

```swift
struct EditorView: View {
    @State private var showSettings = false
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        HStack(spacing: 0) {
            CanvasView()
                .frame(maxWidth: .infinity)

            if sizeClass == .regular && showSettings {
                SettingsPanel()
                    .frame(width: 320)
                    .transition(.move(edge: .trailing))
            }
        }
        .sheet(isPresented: sizeClass == .compact ? $showSettings : .constant(false)) {
            SettingsPanel()
        }
        .toolbar {
            Button("Settings", systemImage: "gear") {
                withAnimation { showSettings.toggle() }
            }
        }
    }
}
```

**Correct (inspector modifier with automatic adaptive behavior):**

```swift
struct EditorView: View {
    @State private var showSettings = false

    var body: some View {
        CanvasView()
            .inspector(isPresented: $showSettings) {
                SettingsPanel()
                    .inspectorColumnWidth(min: 280, ideal: 320, max: 400)
            }
            .toolbar {
                Button("Settings", systemImage: "gear") {
                    showSettings.toggle()
                }
            }
    }
}
```

Use `.inspector()` for contextual detail panels — property inspectors, filters, settings, and metadata views shown alongside primary content. Do not use it for primary navigation flows; use `NavigationSplitView` for master-detail navigation instead. The inspector is best suited for non-blocking, supplementary information that the user toggles on and off while working with the main content.

Reference: WWDC 2023 — "Inspectors in SwiftUI: Discover the details"
