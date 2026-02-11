---
title: Scale Buttons to 0.97 on Press for Tactile Feedback
impact: HIGH
impactDescription: 0.97 scale is the sweet spot — visible but not exaggerated, matching Apple's system button behavior
tags: micro, button, press, scale, feedback
---

## Scale Buttons to 0.97 on Press for Tactile Feedback

A subtle scale-down on press makes buttons feel physically pushable — like a real surface depressing under your finger. The magic number is 0.97: it is large enough to be visible but small enough to avoid looking cartoonish. Apple uses similar values in its own system buttons. The effect works because it creates an immediate visual response tied to the press gesture, closing the perception gap between touch and action. Implementing this as a reusable `ButtonStyle` ensures consistency across every tappable surface in the app.

**Incorrect (no press animation — button looks static and unresponsive):**

```swift
struct CheckoutButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "bag.fill")
                Text("Checkout")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(.white)
            .background(.blue, in: RoundedRectangle(cornerRadius: 12))
        }
        // No press feedback at all — tapping this button gives zero visual
        // confirmation that the touch registered. Users double-tap because
        // they are unsure the first tap worked.
    }
}
```

**Correct (0.97 scale on press feels physically pushable):**

```swift
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.snappy, value: configuration.isPressed)
    }
}

struct CheckoutButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "bag.fill")
                Text("Checkout")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(.white)
            .background(.blue, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
```

**Production-ready version with opacity dimming:**

```swift
struct TactileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.snappy, value: configuration.isPressed)
    }
}

// Apply globally via a ViewModifier or per-button:
struct ProductCard: View {
    let product: Product

    var body: some View {
        Button {
            // navigate to detail
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Image(product.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(product.name)
                    .font(.headline)

                Text(product.price, format: .currency(code: "USD"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(TactileButtonStyle())
    }
}
```

**Scale values and their perceived effect:**

| Scale Factor | Feels like | Use for |
|---|---|---|
| `1.0` | No feedback | Never — always add press feedback |
| `0.98` | Very subtle dimple | Small icon buttons, toolbar items |
| `0.97` | Gentle press | Primary buttons, cards, list rows |
| `0.95` | Noticeable push | Large hero buttons, call-to-action |
| `< 0.90` | Broken / collapsing | Never — looks like a rendering bug |

**Warning:** never scale to 0 or below 0.9. Values under 0.9 make the button look like it is collapsing into itself, and 0 makes it disappear entirely. The goal is "pressed surface", not "shrinking object".

Reference: Apple Human Interface Guidelines — Buttons
