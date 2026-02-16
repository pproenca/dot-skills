---
title: Every Visual Value Has Exactly One Definition Point
impact: MEDIUM
impactDescription: eliminates 100% of token value drift — duplicate definitions diverge within 1-2 refactors, single-source prevents silent inconsistencies
tags: govern, single-source, deduplication, consistency
---

## Every Visual Value Has Exactly One Definition Point

When the same value is defined in two places, they will eventually diverge. Someone will update `Spacing.md` from 16 to 20 but miss `CardLayout.padding` which is also 16. Now you have two "standard paddings" — one at 20, one stuck at 16. The single-source-of-truth principle means every design value has exactly one canonical definition, and all other references derive from it.

**Incorrect (same values defined in multiple places):**

```swift
// DesignSystem/Tokens/Spacing.swift
enum Spacing {
    static let md: CGFloat = 16
}

// Features/Orders/OrderConstants.swift
enum OrderLayout {
    static let cardPadding: CGFloat = 16    // Same as Spacing.md — but who knows?
    static let sectionSpacing: CGFloat = 24  // Same as Spacing.lg — or is it?
}

// Features/Profile/ProfileConstants.swift
enum ProfileLayout {
    static let contentPadding: CGFloat = 16  // Another copy of Spacing.md
    static let avatarSize: CGFloat = 64      // Is this a token or truly local?
}

// After refactor: Spacing.md becomes 20, but OrderLayout.cardPadding
// and ProfileLayout.contentPadding stay at 16. Drift begins.
```

**Correct (single definition, all references derive from it):**

```swift
// DesignSystem/Tokens/Spacing.swift — THE single source
enum Spacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// Features/Orders/OrderRow.swift — references Spacing directly
@Equatable
struct OrderRow: View {
    let order: Order

    var body: some View {
        HStack(spacing: Spacing.sm) {
            OrderStatusIcon(status: order.status)
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(order.title).font(.headline)
                Text(order.date.formatted()).font(.subheadline)
            }
        }
        .padding(Spacing.md)         // Uses token directly, not a local copy
    }
}

// If a component genuinely needs a unique value, name it descriptively
// and document WHY it differs from the scale
struct AvatarView: View {
    let user: User

    // This is intentionally NOT a spacing token — it's a component dimension
    // tied to the avatar's visual design, not to the spacing scale
    private static let diameter: CGFloat = 64

    var body: some View {
        AsyncImage(url: user.avatarURL) { image in
            image.resizable().aspectRatio(contentMode: .fill)
        } placeholder: {
            Image(systemName: "person.crop.circle.fill")
                .foregroundStyle(.labelTertiary)
        }
        .frame(width: Self.diameter, height: Self.diameter)
        .clipShape(Circle())
    }
}
```

**How to audit for duplicates:**

```bash
# Find CGFloat constants in feature directories that match token values
grep -rn "static let.*CGFloat = \(2\|4\|8\|16\|24\|32\|48\)" Sources/Features/
```

If this grep returns results, those constants should either reference the token or be documented as intentionally distinct component-specific values.
