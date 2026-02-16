---
title: Use Button Styles That Match the Action's Importance
impact: HIGH
impactDescription: system button styles (.borderedProminent, .bordered, .borderless) save 8-15 lines of manual styling per button — automatically provide touch feedback, dark mode, Dynamic Type, and accessibility support that takes 40-60 lines to reimplement
tags: taste, button, style, kocienda-taste, edson-conviction, interaction
---

## Use Button Styles That Match the Action's Importance

Kocienda's taste means assigning visual weight proportional to importance. A primary action (Submit, Purchase, Send) deserves `.borderedProminent` — it stands out as the thing to do. A secondary action (Cancel, Skip) should recede with `.bordered` or plain style. A destructive action (Delete, Remove) should use the `.destructive` role so the system renders it in red. Custom button styling with raw modifiers (`.background(.blue).foregroundStyle(.white)`) bypasses the system's touch feedback, accessibility adjustments, and dark mode handling.

**Incorrect (custom styling bypasses system behavior):**

```swift
struct CheckoutActions: View {
    var body: some View {
        VStack(spacing: 12) {
            Button("Place Order") { placeOrder() }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Button("Continue Shopping") { dismiss() }
                .font(.headline)
                .foregroundStyle(.blue)
        }
    }
}
```

**Correct (system button styles with appropriate hierarchy):**

```swift
struct CheckoutActions: View {
    var body: some View {
        VStack(spacing: 12) {
            // Primary action — prominent, full width
            Button("Place Order") { placeOrder() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

            // Secondary action — recedes visually
            Button("Continue Shopping") { dismiss() }
                .buttonStyle(.bordered)
                .controlSize(.large)
        }
    }
}
```

**Button style hierarchy:**

```swift
// Primary action — use sparingly (one per screen)
Button("Submit") { }.buttonStyle(.borderedProminent)

// Secondary action — supporting actions
Button("Save Draft") { }.buttonStyle(.bordered)

// Tertiary action — minimal visual weight
Button("Cancel") { }.buttonStyle(.borderless)

// Destructive action — system red, requires confirmation
Button("Delete Account", role: .destructive) { }
```

**Control size for context:**

```swift
.controlSize(.mini)        // Toolbars, compact UI
.controlSize(.small)       // Secondary actions
.controlSize(.regular)     // Default
.controlSize(.large)       // Primary actions, full-width
.controlSize(.extraLarge)  // Hero CTAs
```

**When NOT to use system styles:** When the button IS the brand (e.g., Uber's "Request" button with specific brand colors), custom styling is appropriate. But even then, keep touch feedback and accessibility behaviors.

Reference: [Buttons - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/buttons)
