---
title: Consistent Alignment Per Content Type Within a Screen
impact: MEDIUM-HIGH
impactDescription: mixed alignment within a single screen breaks the vertical reading edge — the eye has to re-anchor on every element, increasing cognitive load by 20-40% compared to a consistent left edge
tags: rhythm, alignment, layout, readability, visual-edge
---

## Consistent Alignment Per Content Type Within a Screen

When a title is left-aligned, the body text is centered, a caption returns to left-aligned, and the button is centered again, the eye has no stable anchor. Every alignment change forces the reader to scan horizontally to find where the next line starts. A principal designer establishes one alignment convention per content type: left-align all text content, center-align full-width action buttons, and never mix alignment for the same content type on the same screen.

**Incorrect (alignment changes on every element):**

```swift
struct OnboardingStepView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "bell.badge")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            // Title: centered
            Text("Stay in the Loop")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            // Body: left-aligned — breaks the centered flow
            Text("Get notified when friends share new photos, when your prints are ready for pickup, and when limited editions drop.")
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Caption: centered again
            Text("You can change this anytime in Settings.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            // Button: left-aligned — no reason to break from centered
            Button("Enable Notifications") { }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
}
```

**Correct (centered layout with consistent alignment throughout):**

```swift
struct OnboardingStepView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "bell.badge")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            // All text: centered (onboarding convention)
            VStack(spacing: 8) {
                Text("Stay in the Loop")
                    .font(.title2.bold())

                Text("Get notified when friends share new photos, when your prints are ready for pickup, and when limited editions drop.")
                    .font(.body)
                    .foregroundStyle(.secondary)

                Text("You can change this anytime in Settings.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .multilineTextAlignment(.center)

            // Full-width button: centered by nature
            Button("Enable Notifications") { }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
        }
        .padding()
    }
}
```

**Alternative — left-aligned detail screen (the more common pattern):**

```swift
struct OrderConfirmationView: View {
    var body: some View {
        ScrollView {
            // Leading alignment for all content in detail/form screens
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order Confirmed")
                        .font(.title2.bold())
                    Text("Your order #4821 is on its way.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Label("Estimated delivery: Tomorrow", systemImage: "shippingbox")
                    Label("Tracking: 1Z999AA10123456784", systemImage: "barcode")
                }
                .font(.subheadline)

                // Full-width button is the one exception — centered by default
                Button("Track Order") { }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
            }
            .padding()
        }
    }
}
```

**Alignment conventions by screen type:**

```swift
// Screen type        | Text alignment | Button alignment
// -------------------|----------------|------------------
// Onboarding/empty   | Center         | Center (full-width)
// Detail/form        | Leading        | Center (full-width)
// List/feed          | Leading        | Trailing (inline actions)
// Modal/alert        | Center         | Center (stacked)
// Settings           | Leading        | System-managed (List)

// Rule: pick ONE text alignment per screen and apply it to ALL text.
// The only element that may differ is a full-width button (inherently centered).
```

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout)
