---
title: Anchor Transitions to Their Trigger Location
impact: HIGH
impactDescription: transitions from the correct origin reinforce cause-and-effect; random positions disorient
tags: spatial, origin, anchor, context, position
---

## Anchor Transitions to Their Trigger Location

Every transition has a cause: a button tap, a swipe, a long press. The animation that follows must originate from that cause's location on screen. When a user taps a "+" button in the bottom-right corner, the new element should expand from that corner — not fade in from the center of the screen. When an item is deleted, it should collapse toward the trash icon — not vanish in place. This cause-and-effect anchoring is fundamental to spatial interfaces: it answers "where did that come from?" and "where did that go?" without requiring conscious thought.

The most common violation is using a plain `.opacity` transition for popups, menus, and newly inserted elements. Opacity transitions have no spatial information — the element appears as a ghost, fully formed, with no origin. The user's eye has to search for the new content rather than following it from the trigger.

**Incorrect (menu appears with opacity — no spatial origin):**

```swift
struct ToolbarActionView: View {
    @State private var showMenu = false

    var body: some View {
        VStack {
            Spacer()

            if showMenu {
                VStack(spacing: 0) {
                    ForEach(["Copy", "Paste", "Delete"], id: \.self) { action in
                        Button(action) {}
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        if action != "Delete" {
                            Divider()
                        }
                    }
                }
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .padding(.bottom, 8)
                // Opacity transition: the menu materializes in place
                // with no connection to the button that triggered it.
                // The user must visually locate it.
                .transition(.opacity)
            }

            Button {
                showMenu.toggle()
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.title2)
                    .padding()
            }
        }
        .animation(.smooth, value: showMenu)
    }
}
```

**Correct (menu scales from the trigger button with anchored origin):**

```swift
struct ToolbarActionView: View {
    @State private var showMenu = false

    var body: some View {
        VStack {
            Spacer()

            if showMenu {
                VStack(spacing: 0) {
                    ForEach(["Copy", "Paste", "Delete"], id: \.self) { action in
                        Button(action) {}
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        if action != "Delete" {
                            Divider()
                        }
                    }
                }
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .padding(.bottom, 8)
                // Scale + opacity from the bottom center (where the button is).
                // The menu visually "grows" out of the trigger.
                .transition(
                    .scale(scale: 0.4, anchor: .bottom)
                    .combined(with: .opacity)
                )
            }

            Button {
                showMenu.toggle()
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.title2)
                    .padding()
            }
        }
        .animation(.smooth, value: showMenu)
    }
}
```

**Anchored origin for a floating action button (FAB) expansion:**

```swift
struct FloatingActionMenu: View {
    @State private var isOpen = false

    let actions: [(icon: String, label: String)] = [
        ("camera.fill", "Photo"),
        ("doc.fill", "Document"),
        ("link", "Link")
    ]

    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            // Secondary action buttons expand from the FAB's position
            if isOpen {
                ForEach(Array(actions.enumerated()), id: \.offset) { index, action in
                    HStack(spacing: 12) {
                        Text(action.label)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())

                        Image(systemName: action.icon)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(.blue, in: Circle())
                    }
                    .transition(
                        .scale(scale: 0.3, anchor: .bottomTrailing)
                        .combined(with: .opacity)
                    )
                }
            }

            HStack {
                Spacer()
                Button {
                    isOpen.toggle()
                } label: {
                    Image(systemName: isOpen ? "xmark" : "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(.blue, in: Circle())
                        .rotationEffect(.degrees(isOpen ? 90 : 0))
                        .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .animation(.snappy, value: isOpen)
    }
}
```

**Common anchor points by trigger position:**

| Trigger location | Anchor | Example |
|---|---|---|
| Bottom-right FAB | `.bottomTrailing` | Action menu expansion |
| Top-right nav bar | `.topTrailing` | Settings popover |
| Center of tapped element | `.center` | Context menu on a card |
| Bottom tab bar | `.bottom` | Tab overflow menu |
| Inline "add" button | `.leading` or `.trailing` | New list item insertion |

**The `scaleEffect(anchor:)` technique for press feedback:**

When applying press scale to a button, the anchor determines the perceived origin of the press. A button at the trailing edge should scale from `.trailing` so it appears to compress toward the edge rather than shrinking toward its center.

```swift
struct AnchoredPressButton: View {
    @State private var isPressed = false

    var body: some View {
        HStack {
            Spacer()

            Text("Add to Cart")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(.blue, in: Capsule())
                // Scale toward the trailing edge where the button sits
                .scaleEffect(isPressed ? 0.95 : 1.0, anchor: .trailing)
                .animation(.snappy, value: isPressed)
                .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                    isPressed = pressing
                }, perform: {})
        }
        .padding(.horizontal, 24)
    }
}
```

**Rule of thumb:** if you can point to the spot on screen that caused the transition, the transition's origin should be that spot.
