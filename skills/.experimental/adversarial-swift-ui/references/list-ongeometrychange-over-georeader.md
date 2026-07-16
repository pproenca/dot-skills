---
title: Measure views with onGeometryChange, not a wrapping GeometryReader
tags: list, geometry, measurement, layout-stability
---

## Measure views with onGeometryChange, not a wrapping GeometryReader

The wrong default is wrapping content in a `GeometryReader` solely to read its size or position into state. A wrapping container is a layout participant that "could inadvertently alter the very layout" it was meant to measure — `GeometryReader` claims all proposed space and changes its child's sizing behavior. The `onGeometryChange(for:of:action:)` modifier "acts as a silent observer rather than a layout participant": the measured view keeps its original size, the hierarchy stays stable, and the action fires only when the extracted value actually changes, letting SwiftUI skip unnecessary re-renders.

**Evidence of violation:** a `GeometryReader` whose proxy is used only to capture size/frame values into `@State` or a preference — not to position or size its children from the proxy. PASS: `.onGeometryChange(for:of:action:)` attached directly to the measured content. PASS (carve-out): a `GeometryReader` whose proxy values directly drive child layout math (a genuine layout participant) — the reviewer must cite the proxy-derived layout expression to claim this; a carve-out asserted without that evidence fails closed. N/A: no view measurement in the target, or the deployment target is below iOS 16/macOS 13 (the floor of the back-deployed `onGeometryChange`).

**Incorrect (the measuring container changes the measured layout):**

```swift
import SwiftUI

struct TrackDescriptionSheet: View {
    let description: String

    @State private var contentHeight: CGFloat = 0

    var body: some View {
        ScrollView {
            // ⚠️ A wrapping GeometryReader joins layout and alters what it measures
            GeometryReader { proxy in
                Text(description)
                    .fixedSize(horizontal: false, vertical: true)
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
import SwiftUI

struct TrackDescriptionSheet: View {
    let description: String

    @State private var contentHeight: CGFloat = 0

    var body: some View {
        ScrollView {
            Text(description)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.height
                } action: {
                    self.contentHeight = $0
                }
        }
        .presentationDetents([.height(contentHeight)])
    }
}
```
