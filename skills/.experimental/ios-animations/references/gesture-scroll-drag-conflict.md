---
title: Resolve Scroll and Drag Gesture Conflicts
impact: HIGH
impactDescription: Unresolved gesture conflicts cause scroll views inside draggable containers to become completely non-interactive. Proper gesture isolation restores 100% of scroll functionality while maintaining sheet/drawer drag behavior.
tags: gesture, scroll, drag, conflict, priority, simultaneous
---

## Resolve Scroll and Drag Gesture Conflicts

Bottom sheets, drawers, and pull-to-refresh overlays all share a structural problem: a `DragGesture` on the container and a `ScrollView` inside it both want vertical touch events. By default, SwiftUI gives priority to the outermost gesture, which means the inner `ScrollView` stops scrolling entirely. The fix depends on the interaction model, but the core technique is axis locking: detect the initial drag direction, then commit to either scrolling or dragging for the rest of the gesture.

**Incorrect (DragGesture on parent steals all touches from ScrollView):**

```swift
struct BrokenSheet: View {
    @State private var sheetOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(.secondary)
                .frame(width: 36, height: 5)
                .padding(.vertical, 8)

            // This ScrollView will never scroll because the parent
            // DragGesture captures all vertical touch events first
            ScrollView {
                ForEach(0..<30) { index in
                    Text("Row \(index)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    Divider()
                }
            }
        }
        .frame(height: 500)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .offset(y: sheetOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    sheetOffset = value.translation.height
                }
                .onEnded { _ in
                    withAnimation(.smooth) {
                        sheetOffset = 0
                    }
                }
        )
    }
}
```

**Correct (drag handle owns the gesture; scroll content scrolls freely):**

```swift
@Equatable
struct SheetWithScrollableContent: View {
    @State private var sheetOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            // Only the handle area captures the drag gesture
            SheetHandle()
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            sheetOffset = value.translation.height
                        }
                        .onEnded { _ in
                            withAnimation(.smooth) {
                                sheetOffset = 0
                            }
                        }
                )

            // ScrollView is outside the gesture scope — scrolls normally
            ScrollView {
                ForEach(0..<30) { index in
                    Text("Row \(index)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(Spacing.md)
                    Divider()
                }
            }
        }
        .frame(height: 500)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Radius.lg))
        .offset(y: sheetOffset)
    }
}

@Equatable
struct SheetHandle: View {
    var body: some View {
        Rectangle()
            .fill(.clear)
            .frame(height: 44)
            .overlay {
                Capsule()
                    .fill(.secondary)
                    .frame(width: 36, height: 5)
            }
            .contentShape(Rectangle())
    }
}
```

**Advanced: axis locking for horizontal drag on a vertical ScrollView:**

```swift
@Equatable
struct HorizontalSwipeableList: View {
    var body: some View {
        ScrollView {
            ForEach(0..<20) { index in
                SwipeableRow(title: "Item \(index)")
            }
        }
    }
}

@Equatable
struct SwipeableRow: View {
    let title: String

    @State private var offsetX: CGFloat = 0
    @State private var lockedAxis: Axis?

    private let lockThreshold: CGFloat = 10

    var body: some View {
        HStack {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Spacing.md)
        }
        .background(.background)
        .offset(x: offsetX)
        .simultaneousGesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    // Lock axis based on initial movement direction
                    if lockedAxis == nil {
                        let dx = abs(value.translation.width)
                        let dy = abs(value.translation.height)

                        if dx > lockThreshold || dy > lockThreshold {
                            lockedAxis = dx > dy ? .horizontal : .vertical
                        }
                    }

                    // Only apply horizontal offset if we locked to horizontal
                    if lockedAxis == .horizontal {
                        offsetX = value.translation.width
                    }
                    // If locked to vertical, do nothing — ScrollView handles it
                }
                .onEnded { _ in
                    lockedAxis = nil
                    withAnimation(.smooth) {
                        offsetX = 0
                    }
                }
        )
    }
}
```

**Using `.simultaneousGesture` vs `.highPriorityGesture`:**

```swift
// .gesture() — default priority, child gestures win
// .highPriorityGesture() — this gesture wins over children
// .simultaneousGesture() — both fire, you decide in code

// For scroll + drag conflicts, .simultaneousGesture is usually
// the right choice because you need both to receive events
// and you arbitrate in .onChanged based on direction.

// For a drag handle above a scroll view, plain .gesture() on
// the handle is sufficient — no conflict exists because
// the gesture regions do not overlap.
```

**Benefits:**
- Scroll content remains fully interactive — users can scroll long lists inside sheets
- Horizontal swipe actions work without breaking vertical scroll
- Axis locking prevents diagonal "drift" that confuses both gestures
- The handle-based approach avoids gesture conflicts entirely for simple sheet patterns

Reference: [WWDC 2023 — What's new in SwiftUI](https://developer.apple.com/wwdc23/10148)
