---
title: Never Break the System Back-Swipe Gesture
impact: HIGH
impactDescription: breaking the iOS edge-swipe-to-go-back gesture is the number one way to make an app feel non-native — 70%+ of iOS users rely on it
tags: enduring, swipe-back, navigation, rams-7, edson-conviction, gesture
---

## Never Break the System Back-Swipe Gesture

Rams designed objects that lasted decades because they respected how people use them. The left-edge swipe to go back is one of iOS's most enduring interaction patterns — it will outlast any custom gesture you replace it with. Edson's Design With Conviction means committing to platform gestures, not fighting them.

**Incorrect (custom drag gesture conflicts with system back swipe):**

```swift
struct ImageViewer: View {
    @State private var offset: CGSize = .zero

    var body: some View {
        // This DragGesture captures ALL horizontal drags,
        // including the system's edge-swipe-to-go-back
        Image("photo")
            .resizable()
            .scaledToFit()
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation
                    }
                    .onEnded { _ in
                        withAnimation(.smooth) { offset = .zero }
                    }
            )
    }
}
```

**Correct (gesture restricted to avoid edge-swipe conflict):**

```swift
struct ImageViewer: View {
    @State private var offset: CGSize = .zero
    @GestureState private var isDragging = false

    var body: some View {
        Image("photo")
            .resizable()
            .scaledToFit()
            .offset(offset)
            .gesture(
                DragGesture(minimumDistance: 20)
                    .updating($isDragging) { _, state, _ in
                        state = true
                    }
                    .onChanged { value in
                        // Only handle vertical drag-to-dismiss,
                        // leave horizontal edge swipes to the system
                        if abs(value.translation.height) > abs(value.translation.width) {
                            offset = CGSize(width: 0, height: value.translation.height)
                        }
                    }
                    .onEnded { value in
                        if abs(value.translation.height) > 200 {
                            dismiss()
                        } else {
                            withAnimation(.smooth) { offset = .zero }
                        }
                    }
            )
    }

    @Environment(\.dismiss) private var dismiss
}
```

**Common causes of broken swipe-back:**
| Anti-pattern | Fix |
|---|---|
| `TabView` with `.tabViewStyle(.page)` inside a `NavigationStack` | Place paging content in a non-navigated context, or use a custom pager that yields the leading edge |
| `.navigationBarBackButtonHidden(true)` with no replacement | Always provide a custom back button **and** keep the swipe gesture via `.toolbar` placement instead |
| Custom `NavigationView` replacement (e.g., manual stack with `AnyView`) | Migrate to `NavigationStack` which handles the interactive pop transition natively |
| `DragGesture()` with no directional constraint | Constrain to vertical axis, or use `simultaneousGesture` with `.highPriorityGesture` to yield to the system |

**Alternative (custom back button without losing swipe):**

```swift
struct DetailView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ContentView()
            // Hide the default back button but keep the swipe gesture
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
            }
    }
}
```

**Reference:** [Apple HIG — Navigation](https://developer.apple.com/design/human-interface-guidelines/navigation) — "Always provide a clear path back. People usually know how they got to the current screen and expect to be able to go back."
