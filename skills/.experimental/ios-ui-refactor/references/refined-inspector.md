---
title: Use Inspector for Trailing-Edge Detail Panels
impact: MEDIUM
impactDescription: replaces custom overlay/sheet logic with a single modifier, saving 30-50 lines per detail panel and gaining automatic iPhone-to-iPad adaptive layout
tags: refined, layout, ipad, edson-prototype, rams-1, navigation
---

## Use Inspector for Trailing-Edge Detail Panels

There is a moment of recognition when you realize your custom HStack-sidebar-with-manual-width-management is a rough draft of what Apple's `.inspector()` modifier already does in one line. The first implementation is rarely the final one — and `.inspector()` is Apple's own iteration on the trailing-edge detail panel, replacing 50+ lines of conditional size-class logic with a single modifier that adapts between iPhone sheet and iPad side panel automatically.

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

**When NOT to apply:** Primary navigation hierarchies where `NavigationSplitView` is the correct pattern, and iPhone-only apps where a sheet or push navigation is more natural than a trailing panel the user cannot see simultaneously with the main content.

Reference: WWDC 2023 — "Inspectors in SwiftUI: Discover the details"
