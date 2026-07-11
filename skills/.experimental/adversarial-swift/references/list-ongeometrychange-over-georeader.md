---
title: Measure views with onGeometryChange, not a wrapping GeometryReader
tags: list, geometry, measurement, layout-stability
---

## Measure views with onGeometryChange, not a wrapping GeometryReader

The wrong default is wrapping content in a `GeometryReader` solely to read its size or position into state. A wrapping container is a layout participant that "could inadvertently alter the very layout" it was meant to measure — `GeometryReader` claims all proposed space and changes its child's sizing behavior. The `onGeometryChange(for:of:action:)` modifier "acts as a silent observer rather than a layout participant": the measured view keeps its original size, and the action fires only when the observed value actually changes.

**Evidence of violation:** a `GeometryReader` whose proxy is used only to capture size/frame values into `@State` or a preference — not to position or size its children from the proxy. PASS: `.onGeometryChange(for:of:action:)` attached directly to the measured content. PASS: a `GeometryReader` whose proxy values directly drive child layout math (a genuine layout participant) — the reviewer must cite the proxy-derived layout expression to claim this. N/A: no view measurement in the target, or the deployment target predates the iOS 16.4-era `onGeometryChange` backport.

**Incorrect (the measuring container changes the measured layout):**

```swift
struct TrackDescriptionSheet: View {
    let details: String

    @State private var contentHeight: CGFloat = 0

    var body: some View {
        ScrollView {
            GeometryReader { proxy in
                Text(details)
                    .padding()
                    .onAppear {
                        contentHeight = proxy.size.height
                    }
            }
        }
        .presentationDetents([.height(contentHeight)])
    }
}
```

**Correct (a silent observer reports size without joining layout):**

```swift
struct TrackDescriptionSheet: View {
    let details: String

    @State private var contentHeight: CGFloat = 0

    var body: some View {
        ScrollView {
            Text(details)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.height
                } action: {
                    contentHeight = $0
                }
        }
        .presentationDetents([.height(contentHeight)])
    }
}
```

Reference: expert SwiftUI reference (2026), “Adopting modern layout patterns”
