---
title: Use Inspector for Trailing-Edge Detail Panels
impact: MEDIUM
impactDescription: Replaces custom overlay/sheet logic with a single modifier, saving 30-50 lines per detail panel and gaining automatic iPhone-to-iPad adaptive layout
tags: modern, layout, ipad, navigation
---

## Use Inspector for Trailing-Edge Detail Panels

Building a custom trailing-edge panel with sheets, overlays, or `HStack`-based sidebars requires manual width management, animation coordination, and separate iPhone/iPad code paths. The `.inspector()` modifier renders a trailing-edge panel natively on iPad (matching Keynote, Freeform, and Swift Playgrounds) and automatically falls back to a sheet on iPhone — zero conditional layout code required.

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
