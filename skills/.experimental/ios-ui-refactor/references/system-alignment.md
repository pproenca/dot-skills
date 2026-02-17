---
title: Consistent Alignment Per Content Type Within a Screen
impact: MEDIUM-HIGH
impactDescription: mixed alignment within a single screen breaks the vertical reading edge — the eye has to re-anchor on every element, noticeably increasing cognitive load
tags: system, alignment, layout, edson-systems, rams-8, readability
---

## Consistent Alignment Per Content Type Within a Screen

Reading a screen where alignment shifts on every element is like reading a book where the margins change on every page — your eye has to re-anchor each time, searching for the new left edge instead of absorbing the content. A centered title followed by left-aligned body text followed by a centered caption forces the user to solve a layout puzzle that should be invisible. One alignment convention per content type, applied without exception, gives the eye a single rail to follow from top to bottom.

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

**When NOT to apply:** Asymmetric layouts where intentional alignment contrast creates visual hierarchy (e.g., a centered hero section above a left-aligned detail section), as long as each section is internally consistent and the contrast is deliberate rather than accidental.

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout)
