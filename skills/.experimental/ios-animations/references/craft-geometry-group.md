---
title: Use geometryGroup() to Isolate Layout Animation Propagation
impact: MEDIUM
impactDescription: prevents parent geometry changes from corrupting child animations — the fix for "my animation animates wrong"
tags: craft, geometryGroup, layout, isolation, propagation
---

## Use geometryGroup() to Isolate Layout Animation Propagation

When a parent view changes size or position and its children have their own animations, something unexpected happens: the parent's geometry change propagates into the children's coordinate space. A child that is supposed to scale in place instead scales while sliding because the parent is also moving. An icon that should bounce at its current position instead bounces while drifting to a new anchor point. This is the most common cause of "my animation goes to the wrong place" bugs in SwiftUI.

`.geometryGroup()` (iOS 17+) resolves the parent's geometry change before passing the resolved frame to children. Children receive their new position as a fait accompli — they do not see the parent's interpolation. This lets child animations run in their own local coordinate space, uncontaminated by parent motion.

**Incorrect (parent resize corrupts child animation position):**

```swift
struct ExpandableToolbar: View {
    @State private var isExpanded = false
    @State private var showBadge = false

    var body: some View {
        HStack(spacing: isExpanded ? 24 : 12) {
            Button(action: { showBadge.toggle() }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.title2)
                        .frame(width: 44, height: 44)

                    if showBadge {
                        Circle()
                            .fill(.red)
                            .frame(width: 10, height: 10)
                            // This badge is supposed to scale in from zero
                            // at its top-right position. But when the toolbar
                            // is also expanding (isExpanded changes), the badge
                            // scales in while drifting sideways because the parent
                            // HStack spacing is animating.
                            .transition(.scale)
                    }
                }
            }

            Button(action: {}) {
                Image(systemName: "gear")
                    .font(.title2)
                    .frame(width: 44, height: 44)
            }

            if isExpanded {
                Button(action: {}) {
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: Capsule())
        .animation(.smooth, value: isExpanded)
        .animation(.snappy, value: showBadge)
        .onTapGesture {
            isExpanded.toggle()
        }
    }
}
```

**Correct (geometryGroup isolates child from parent's geometry change):**

```swift
struct ExpandableToolbar: View {
    @State private var isExpanded = false
    @State private var showBadge = false

    var body: some View {
        HStack(spacing: isExpanded ? 24 : 12) {
            Button(action: { showBadge.toggle() }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.title2)
                        .frame(width: 44, height: 44)

                    if showBadge {
                        Circle()
                            .fill(.red)
                            .frame(width: 10, height: 10)
                            // Now the badge scales in at its final position,
                            // not along the parent's interpolation path.
                            .transition(.scale)
                    }
                }
            }

            Button(action: {}) {
                Image(systemName: "gear")
                    .font(.title2)
                    .frame(width: 44, height: 44)
            }

            if isExpanded {
                Button(action: {}) {
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: Capsule())
        // geometryGroup resolves the HStack's final geometry before
        // passing it to children. Child animations (badge scale) run
        // in the resolved coordinate space, not the interpolating one.
        .geometryGroup()
        .animation(.smooth, value: isExpanded)
        .animation(.snappy, value: showBadge)
        .onTapGesture {
            isExpanded.toggle()
        }
    }
}
```

**Common scenario — card resize with inner animated elements:**

```swift
struct ResizableCard: View {
    @State private var isLarge = false
    @State private var isHighlighted = false

    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.blue.gradient)
                    .frame(
                        width: isLarge ? 320 : 200,
                        height: isLarge ? 240 : 160
                    )

                // Star icon bounces independently of card resize
                Image(systemName: isHighlighted ? "star.fill" : "star")
                    .font(.title2)
                    .foregroundStyle(.yellow)
                    .scaleEffect(isHighlighted ? 1.2 : 1.0)
                    .animation(.bouncy, value: isHighlighted)
                    .padding(12)
            }
            // geometryGroup prevents the card's size animation from
            // pulling the star icon along an interpolation path
            .geometryGroup()
            .animation(.smooth(duration: 0.4), value: isLarge)

            HStack(spacing: 16) {
                Button("Resize") {
                    isLarge.toggle()
                }
                Button("Star") {
                    isHighlighted.toggle()
                }
            }
            .buttonStyle(.bordered)
        }
    }
}
```

**When to apply geometryGroup:**

| Symptom | Cause | Fix |
|---------|-------|-----|
| Child animates to wrong position | Parent size/position is also animating | `.geometryGroup()` on parent |
| Badge flies across screen during resize | Badge transition interpolates in parent's moving frame | `.geometryGroup()` on badge's container |
| Icon bounces while drifting sideways | Parent HStack spacing is animating | `.geometryGroup()` on HStack |
| Transition starts from wrong origin | Parent layout is not yet resolved when child appears | `.geometryGroup()` on parent |

**Where to place `.geometryGroup()`:**

Place it on the view whose geometry change you want to resolve before it reaches children. Typically this is the immediate parent of the elements whose animations are being corrupted.

```swift
// Place on the container whose size/position changes
VStack {
    // children with their own animations
}
.geometryGroup()  // <-- here, between container and its animation
.animation(.smooth, value: someState)
```

**Note:** `.geometryGroup()` has a small cost — it forces an extra layout resolution pass. Do not apply it everywhere preemptively. Add it when you observe the specific symptom of child animations following the wrong interpolation path.

Reference: [WWDC 2023 — Demystify SwiftUI performance](https://developer.apple.com/wwdc23/10160)
