---
title: Avoid Hiding Back Button Without Preserving Swipe Gesture
impact: HIGH
impactDescription: breaks muscle memory for 90%+ of iOS users who rely on swipe-back
tags: anti, back-button, swipe-gesture, ux
---

## Avoid Hiding Back Button Without Preserving Swipe Gesture

Applying `.navigationBarBackButtonHidden(true)` disables both the visible back button and the interactive swipe-back gesture. Most iOS users rely on the edge-swipe to go back — it is deeply ingrained muscle memory. Removing it without a replacement makes the app feel broken and increases the cognitive load of every navigation action. Prefer keeping the system back button and adding supplementary toolbar items alongside it.

**Incorrect (back button hidden with no swipe-back alternative):**

```swift
// BAD: Hides the back button AND kills the edge-swipe gesture.
// Users are trapped unless they find the custom button.
struct OrderDetailView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Text("Order #12345")
            Button("Go Back") { dismiss() } // Only way out
        }
        .navigationBarBackButtonHidden(true)
    }
}
```

**Correct (keep system back button, add supplementary toolbar items):**

```swift
// GOOD: System back button remains — swipe-back works automatically.
// Custom toolbar items add functionality alongside the back button,
// not as a replacement for it.
struct OrderDetailView: View {
    var body: some View {
        ScrollView {
            Text("Order #12345")
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ShareLink(item: orderURL)
            }
        }
    }
}
```

**Last resort (custom back button with UIKit gesture re-enablement):**

If you absolutely must hide the system back button (e.g., for a branded navigation bar), re-enable the swipe-back gesture through UIKit interop. **Warning:** Setting `delegate = nil` on `interactivePopGestureRecognizer` can cause a frozen state if the user swipes back from the root view. This approach relies on UIKit internals and may break across iOS versions. Test thoroughly.

```swift
struct BrandedDetailView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack { /* ... */ }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Orders")
                        }
                    }
                }
            }
            .background(SwipeBackEnabler())
    }
}

// WARNING: UIKit interop hack — fragile across iOS versions.
struct SwipeBackEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        DispatchQueue.main.async {
            controller.navigationController?
                .interactivePopGestureRecognizer?.isEnabled = true
        }
        return controller
    }

    func updateUIViewController(_ vc: UIViewController, context: Context) {}
}
```
