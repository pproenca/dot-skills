---
title: Never feed measured geometry back into the measured view's own frame
tags: list, geometry, layout-loop, feedback
---

## Never feed measured geometry back into the measured view's own frame

The wrong default is using the value captured by a geometry observer as a layout constraint on the very view being measured. "This establishes a race condition where a state update triggers a layout pass that immediately invalidates the measurement that just occurred" — an infinite layout loop that repeatedly re-computes the same view tree within a render cycle. The source's rule is direct: "the output of a geometry observer must not serve as a layout constraint for its own source view"; geometry-driven state should influence distant nodes in the view tree or independent parameters such as presentation detents.

**Evidence of violation:** state written inside an `onGeometryChange` (or `GeometryReader`-based) `action:` is referenced in a `.frame`, `.padding`, or other size-affecting modifier on the same modifier chain as — or an ancestor of — the measured view. PASS: the geometry state drives distant nodes or independent parameters (presentation detents, a sibling overlay, a toolbar). N/A: no geometry observers in the target.

**Incorrect (each measurement invalidates itself in an infinite layout loop):**

```swift
import SwiftUI

struct Track {
    var imageURL: URL?
    var description: String
}

struct TrackImage: View {
    let url: URL?
    var body: some View {
        AsyncImage(url: url)
    }
}

struct TrackDescription: View {
    let description: String
    var body: some View {
        Text(description)
    }
}

struct TrackCard: View {
    let track: Track

    @State private var viewWidth: CGFloat = 0

    var body: some View {
        VStack {
            TrackImage(url: track.imageURL)

            TrackDescription(description: track.description)
        }
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newValue in
            self.viewWidth = newValue
        }
        // ⚠️ Creates an infinite layout loop
        .frame(width: viewWidth > 300 ? 250 : nil)
    }
}
```

**Correct (measurement drives an independent parameter, not its own layout):**

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
