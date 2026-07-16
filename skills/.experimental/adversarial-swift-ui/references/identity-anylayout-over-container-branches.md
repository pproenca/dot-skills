---
title: Switch layouts with AnyLayout instead of branching between containers
tags: identity, anylayout, adaptive-layout, size-class
---

## Switch layouts with AnyLayout instead of branching between containers

The wrong default is `if horizontalSizeClass == .regular { HStack { content } } else { VStack { content } }` with identical children in both branches. Each branch is a distinct structure, so every size-class or orientation change replaces the entire subtree: the children lose their structural identity, and internal state such as image loading progress is wiped mid-transition. With `AnyLayout`, the container changes its layout behavior while the subviews maintain a stable position in the hierarchy, so the framework performs a smooth layout transition instead of a complete replacement of the view tree.

**Evidence of violation:** an `if/else` on a runtime state or environment value (size class, orientation, a toggle) that switches between two layout container types (`HStack`/`VStack`/`Grid` and similar) wrapping the same child content. PASS: an `AnyLayout(HStackLayout())` / `AnyLayout(VStackLayout())` value selected by ternary and applied to one stable child list. N/A: the branches contain different children (a genuine structural change, which the reviewer must cite), no conditional container switching occurs in the target, or the deployment target is below iOS 16/macOS 13, where `AnyLayout` is unavailable — that is N/A, not FAIL.

**Incorrect (a size-class change replaces the whole subtree and resets every card's state):**

```swift
import SwiftUI

struct Bird: Identifiable {
    var id = UUID()
    var name: String
}

struct BirdCard: View {
    let bird: Bird

    var body: some View {
        Text(bird.name)
            .padding()
            .background(.thinMaterial)
    }
}

struct FeaturedBirdsView: View {
    let birds: [Bird]

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    var body: some View {
        // ⚠️ A size-class change replaces the whole subtree
        if horizontalSizeClass == .regular {
            HStack {
                ForEach(birds) { bird in
                    BirdCard(bird: bird)
                }
            }
        } else {
            VStack {
                ForEach(birds) { bird in
                    BirdCard(bird: bird)
                }
            }
        }
    }
}
```

**Correct (children keep identity and state across layout changes):**

```swift
import SwiftUI

struct Bird: Identifiable {
    var id = UUID()
    var name: String
}

struct BirdCard: View {
    let bird: Bird

    var body: some View {
        Text(bird.name)
            .padding()
            .background(.thinMaterial)
    }
}

struct FeaturedBirdsView: View {
    let birds: [Bird]

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    private var layout: AnyLayout {
        horizontalSizeClass == .regular
            ? AnyLayout(HStackLayout())
            : AnyLayout(VStackLayout())
    }

    var body: some View {
        layout {
            ForEach(birds) { bird in
                BirdCard(bird: bird)
            }
        }
    }
}
```
