---
title: Avoid Hiding Back Button Without Preserving Swipe Gesture
impact: HIGH
impactDescription: breaks iOS muscle memory, most users rely on swipe-back gesture
tags: anti, back-button, swipe-gesture, ux
---

## Avoid Hiding Back Button Without Preserving Swipe Gesture

Applying `.navigationBarBackButtonHidden(true)` disables both the visible back button and the interactive swipe-back gesture. Most iOS users rely on the edge-swipe to go back — it is deeply ingrained muscle memory. Removing it without a replacement makes the app feel broken and increases the cognitive load of every navigation action. If you need a custom back button appearance, use a toolbar item while preserving the underlying gesture recognizer.

**Incorrect (back button hidden with no swipe-back alternative):**

```swift
// BAD: Hides the back button AND kills the edge-swipe gesture.
// Users are trapped unless they find the custom button.
// Accessibility users with motor impairments are especially affected.
struct OrderDetailView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Text("Order #12345")
            Button("Go Back") { dismiss() } // Only way out — easy to miss
        }
        .navigationBarBackButtonHidden(true) // Also disables swipe-back
    }
}
```

**Correct (custom back button via toolbar while preserving swipe-back):**

```swift
// GOOD: Custom back button appearance via toolbar, with the
// swipe-back gesture explicitly re-enabled through the
// UINavigationController's interactivePopGestureRecognizer.
struct OrderDetailView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Text("Order #12345")
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Orders")
                    }
                }
            }
        }
        .background(SwipeBackEnabler()) // Re-enable edge-swipe gesture
    }
}

// Utility to restore the interactive pop gesture when
// the default back button is hidden.
struct SwipeBackEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        DispatchQueue.main.async {
            controller.navigationController?
                .interactivePopGestureRecognizer?.isEnabled = true
            controller.navigationController?
                .interactivePopGestureRecognizer?.delegate = nil
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
```

**When NOT to use this pattern:**
- The `SwipeBackEnabler` is a UIKit interop hack — setting `delegate = nil` on `interactivePopGestureRecognizer` can cause a frozen state if the user swipes back from the root view of a stack. Test thoroughly on edge cases.
- This approach may break across iOS versions since it relies on UIKit internals.
- Prefer keeping the system back button visible and using `.toolbar` only for supplementary leading items alongside it.
