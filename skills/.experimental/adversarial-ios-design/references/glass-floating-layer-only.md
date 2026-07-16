---
title: Keep Liquid Glass in the floating functional layer
tags: glass, materials, liquid-glass, layering
---

## Keep Liquid Glass in the floating functional layer

The wrong default after adopting iOS 26 is decorating content with glass because it looks premium — `.glassEffect()` on cards, list rows, or backgrounds. Liquid Glass is the system's signature for the *functional* layer: the controls and navigation floating above content. Spreading it into the content plane erases that distinction, and stacking glass on glass compounds the refraction into visual noise Apple explicitly warns against. Content-layer differentiation belongs to the standard materials (`.regularMaterial`, `.thinMaterial`).

**Evidence of violation:** `.glassEffect(`, `GlassEffectContainer`, `.buttonStyle(.glass)`, or `.buttonStyle(.glassProminent)` applied to content-layer views — list rows, cards inside scrollable content, screen backgrounds, images; or a glass-styled element nested inside another glass element (glass-on-glass) — cite both elements. PASS: glass appears only on floating controls and navigation (toolbars, floating action clusters, overlays pinned above scroll content), with content-layer surfaces on standard materials or opaque fills — cite one representative placement. N/A: the target's minimum deployment is below iOS 26 or no glass API appears in the target.

**Incorrect (glass in the content layer, and a glass button inside a glass card):**

```swift
import SwiftUI

struct SleepSummaryCard: View {
    let night: SleepNight

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last Night").font(.headline)
            Text(night.duration, format: .units(allowed: [.hours, .minutes]))
                .font(.largeTitle.bold())
            Button("View Stages") { }
                .buttonStyle(.glass) // ⚠️ glass on glass — refraction stacks into noise
        }
        .padding()
        .glassEffect(in: .rect(cornerRadius: 20)) // ⚠️ glass on a scrolling content card
    }
}
```

**Correct (content on standard material; glass reserved for the floating layer):**

```swift
import SwiftUI

struct SleepSummaryCard: View {
    let night: SleepNight

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last Night").font(.headline)
            Text(night.duration, format: .units(allowed: [.hours, .minutes]))
                .font(.largeTitle.bold())
            Button("View Stages") { }
                .buttonStyle(.bordered)
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 20))
    }
}

struct SleepScreen: View {
    let nights: [SleepNight]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(nights) { SleepSummaryCard(night: $0) }
            }
            .padding(.horizontal, 18)
        }
        .overlay(alignment: .bottom) {
            Button("Start Wind Down", systemImage: "moon.zzz.fill") { }
                .buttonStyle(.glassProminent) // floating action layer — glass belongs here
                .padding(.bottom)
        }
    }
}
```

Reference: [Human Interface Guidelines — Materials](https://developer.apple.com/design/human-interface-guidelines/materials), [WWDC25 — Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/)
