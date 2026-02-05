---
title: "Use Stacks Instead of Manual Positioning"
impact: CRITICAL
impactDescription: "stacks adapt to all screen sizes, manual positioning breaks on different devices"
tags: layout, stacks, positioning, adaptive, responsive
---

## Use Stacks Instead of Manual Positioning

Manual positioning with `.position()` and `.offset()` uses hardcoded coordinates that only work on a single screen size. When the device changes, text overlaps, elements clip off-screen, and the layout collapses. Stacks compose views relative to each other, so the layout adapts automatically to any screen size or dynamic type setting.

**Incorrect (hardcoded positions break on different screen sizes):**

```swift
struct ProfileCardView: View {
    let userName: String
    let userRole: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(radius: 4)
            Image(systemName: "person.circle.fill")
                .font(.system(size: 48))
                .position(x: 60, y: 50) // breaks on smaller screens
            Text(userName)
                .font(.headline)
                .position(x: 200, y: 35)
            Text(userRole)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .position(x: 200, y: 60)
        }
        .frame(height: 100)
    }
}
```

**Correct (stacks adapt to any screen size automatically):**

```swift
struct ProfileCardView: View {
    let userName: String
    let userRole: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 48))
            VStack(alignment: .leading, spacing: 4) {
                Text(userName)
                    .font(.headline)
                Text(userRole)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(radius: 4)
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
