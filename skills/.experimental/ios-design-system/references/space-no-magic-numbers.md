---
title: Zero Magic Numbers in View Layout Code
impact: HIGH
impactDescription: a single .padding(17) is technical debt — when the spacing scale changes, magic numbers are impossible to find and update systematically
tags: space, magic-numbers, governance, consistency, layout
---

## Zero Magic Numbers in View Layout Code

Every raw number in layout code is an implicit decision that cannot be searched, refactored, or audited. When the design team adjusts the base spacing from 16pt to 14pt, token-based code updates in one place while magic numbers require a manual sweep across hundreds of files — with no guarantee of completeness. The rule is absolute: if it's a spacing, padding, or sizing value, it must reference a token.

**Incorrect (magic numbers throughout):**

```swift
struct CheckoutView: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "cart")
                    .frame(width: 28, height: 28)  // magic
                Text("Your Cart")
                    .padding(.leading, 6)  // magic
            }
            .padding(.horizontal, 20)  // magic
            .padding(.top, 16)  // magic

            ForEach(items) { item in
                HStack(spacing: 10) {  // magic
                    item.thumbnail
                        .frame(width: 60, height: 60)  // magic
                        .clipShape(RoundedRectangle(cornerRadius: 8))  // magic

                    VStack(alignment: .leading, spacing: 4) {  // magic
                        Text(item.name)
                        Text(item.price)
                            .padding(.top, 2)  // magic
                    }
                }
                .padding(.vertical, 8)  // magic
            }

            Button("Checkout") { }
                .padding(.horizontal, 32)  // magic
                .padding(.vertical, 14)  // magic
                .clipShape(RoundedRectangle(cornerRadius: 12))  // magic
        }
        .padding(.bottom, 24)  // magic
    }
}
// 14 magic numbers. Which are intentional design decisions?
// Which are quick guesses? Impossible to tell.
```

**Correct (every value references a token):**

```swift
struct CheckoutView: View {
    var body: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                Image(systemName: "cart")
                    .frame(width: IconSize.md, height: IconSize.md)
                Text("Your Cart")
                    .padding(.leading, Spacing.xs)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)

            ForEach(items) { item in
                HStack(spacing: Spacing.sm) {
                    item.thumbnail
                        .frame(width: AvatarSize.md, height: AvatarSize.md)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(item.name)
                        Text(item.price)
                            .padding(.top, Spacing.xxs)
                    }
                }
                .padding(.vertical, Spacing.sm)
            }

            Button("Checkout") { }
                .buttonStyle(.primary)
        }
        .padding(.bottom, Spacing.lg)
    }
}
// Every value is traceable to a design decision.
// A spacing audit takes seconds, not hours.
```

**Allowed exceptions (not magic numbers):**

```swift
// Zero — the absence of spacing is not a magic number
.padding(0)
VStack(spacing: 0)

// Intrinsic dimensions — these describe the element, not spacing
Divider() // 1pt is intrinsic to Divider
    .frame(height: 1)

// Geometric ratios — structural, not spacing
.aspectRatio(16/9, contentMode: .fit)
.rotationEffect(.degrees(45))

// Layout priorities — not visual dimensions
.layoutPriority(1)
```

**Enforcing the rule in code review:**

A quick regex search for raw numbers in SwiftUI layout calls catches violations:

```text
// Regex pattern for PR reviews:
\.(padding|spacing|frame|offset)\(.*\d{2,}.*\)
// Matches .padding(16), .frame(width: 44), etc.
// Should match ZERO lines in committed code.
```
