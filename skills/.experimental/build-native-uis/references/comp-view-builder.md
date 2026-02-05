---
title: Use @ViewBuilder for Conditional View Content
impact: CRITICAL
impactDescription: enables conditional and dynamic view composition without type erasure
tags: comp, swiftui, viewbuilder, conditional, generics
---

## Use @ViewBuilder for Conditional View Content

Wrapping views in `AnyView` to handle conditionals erases static type information, which disables SwiftUI's diffing optimizations and causes unnecessary view identity resets. `@ViewBuilder` lets the compiler preserve concrete types through conditional branches, keeping animations and state intact.

**Incorrect (AnyView erases type information, breaks diffing):**

```swift
struct MembershipBanner: View {
    let isPremium: Bool
    let memberName: String

    var body: some View {
        bannerContent()
    }

    func bannerContent() -> some View {
        if isPremium {
            return AnyView( // type erasure on every branch
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.yellow)
                    Text("\(memberName) — Premium Member")
                        .font(.headline)
                }
                .padding()
                .background(Color.indigo.opacity(0.15))
                .clipShape(Capsule())
            )
        } else {
            return AnyView(
                Text("\(memberName) — Free Tier")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
            )
        }
    }
}
```

**Correct (@ViewBuilder preserves type information and diffing):**

```swift
struct MembershipBanner: View {
    let isPremium: Bool
    let memberName: String

    var body: some View {
        bannerContent
    }

    @ViewBuilder // compiler tracks concrete types per branch
    var bannerContent: some View {
        if isPremium {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundStyle(.yellow)
                Text("\(memberName) — Premium Member")
                    .font(.headline)
            }
            .padding()
            .background(Color.indigo.opacity(0.15))
            .clipShape(Capsule())
        } else {
            Text("\(memberName) — Free Tier")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding()
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
