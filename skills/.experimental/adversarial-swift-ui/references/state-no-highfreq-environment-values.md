---
title: Keep high-frequency values out of EnvironmentValues entries
tags: state, environment, scroll-offset, observable
---

## Keep high-frequency values out of EnvironmentValues entries

The wrong default is publishing a rapidly changing value — a scroll offset, timer tick, gesture position, or sensor reading — as an `@Entry` on `EnvironmentValues`. `EnvironmentValues` is a single large struct, so any update to one of its properties forces SwiftUI to run a dependency comparison for every view that reads *any* part of the environment, even views that never touch the changing entry. The bodies of unrelated views won't re-run, but in a deep hierarchy the cumulative per-frame comparison overhead alone causes dropped frames. Wrapping the value in an `@Observable` class passed through the environment avoids this: the reference stays the same while its properties mutate, so the framework compares a pointer and tracks reads per property.

**Evidence of violation:** a custom `@Entry` environment value written from a high-frequency handler — `onScrollGeometryChange`, `onGeometryChange`, `DragGesture.onChanged`, a `Timer`, or a `TimelineView`-driven update — via `.environment(\.key, state)`. PASS: high-frequency data carried in an `@Observable` class instance placed in the environment; one-shot or low-frequency configuration values (theme color, feature flags) as `@Entry`. N/A: no custom environment entries in the target.

**Incorrect (every scroll frame forces environment comparisons across the hierarchy):**

```swift
import SwiftUI

extension EnvironmentValues {
    // ⚠️ High-frequency updates in EnvironmentValues
    @Entry var scrollOffset: Double = 0
}

struct HabitatsView: View {
    @State private var offset: Double = 0

    var body: some View {
        NavigationStack {
            HabitatGallery()
                .onScrollGeometryChange(for: Double.self) { geo in
                    geo.contentOffset.y
                } action: { oldValue, newValue in
                    offset = newValue
                }
                .environment(\.scrollOffset, offset)
        }
    }
}

struct HabitatGallery: View {
    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    var body: some View {
        // gallery implementation ...
        ScrollView {
            Text(reduceMotion ? "Static gallery" : "Animated gallery")
        }
    }
}
```

**Correct (the environment holds a stable reference; properties mutate behind it):**

```swift
import SwiftUI

@Observable class ScrollOffsetProvider {
    var offset: Double = 0
}

struct HabitatsView: View {
    @State private var scrollOffset = ScrollOffsetProvider()

    var body: some View {
        NavigationStack {
            HabitatGallery()
                .onScrollGeometryChange(for: Double.self) { geo in
                    geo.contentOffset.y
                } action: { oldValue, newValue in
                    scrollOffset.offset = newValue
                }
                .environment(scrollOffset)
        }
    }
}

struct HabitatGallery: View {
    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    var body: some View {
        // gallery implementation ...
        ScrollView {
            Text(reduceMotion ? "Static gallery" : "Animated gallery")
        }
    }
}
```
