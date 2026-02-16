---
title: Prefer Composition Over Inheritance for View Reuse
impact: HIGH
impactDescription: inheritance creates rigid hierarchies that resist change — composition through small views and modifiers enables the flexible recombination that iterative design demands
tags: compose, composition, inheritance, kocienda-creative-selection, architecture
---

## Prefer Composition Over Inheritance for View Reuse

Kocienda's title concept — creative selection — literally describes the process of composing great software from well-crafted pieces. SwiftUI's `View` protocol uses structs, which cannot inherit from each other. This is by design: Apple chose composition over inheritance because composition scales. Instead of a `BaseCard` that `UserCard` and `ProductCard` inherit from (and then fight to override), you compose from small building blocks: a card container, a header view, a detail row. Each piece can be freely recombined without the constraints of a class hierarchy.

**Incorrect (attempting inheritance-style reuse):**

```swift
// Trying to create a "base" view with shared behavior
struct BaseListRow: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
    }
}
// No way for UserRow or OrderRow to extend this without copying it
```

**Correct (composition from small, focused pieces):**

```swift
// Small composable pieces
struct ItemRow<Leading: View, Trailing: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let leading: Leading
    @ViewBuilder let trailing: Trailing

    var body: some View {
        HStack(spacing: 12) {
            leading
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            trailing
        }
    }
}

// Composed into specific contexts
struct UserRow: View {
    let user: User

    var body: some View {
        ItemRow(title: user.name, subtitle: user.role) {
            Avatar(url: user.avatarURL, size: 40)
        } trailing: {
            StatusBadge(title: user.status, color: user.statusColor)
        }
    }
}

struct OrderRow: View {
    let order: Order

    var body: some View {
        ItemRow(title: order.number, subtitle: order.date.formatted()) {
            Image(systemName: "bag.fill")
                .foregroundStyle(.tint)
        } trailing: {
            Text(order.total, format: .currency(code: "USD"))
                .font(.subheadline.bold())
        }
    }
}
```

**Composition patterns:**
- **Container + Content**: `Card { ... }`, `Section { ... }`
- **Slot-based**: `ItemRow(leading:trailing:)`
- **ViewModifier**: `.cardStyle()` for shared visual treatment
- **Extension methods**: `.primaryButton()` for repeated modifier chains

**When NOT to prefer composition:** When the shared behavior is purely visual (same padding, background, corner radius), a custom `ViewModifier` is simpler than a container view.

Reference: [View fundamentals - Apple Documentation](https://developer.apple.com/documentation/swiftui/view-fundamentals)
