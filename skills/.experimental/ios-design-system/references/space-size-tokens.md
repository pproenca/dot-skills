---
title: Define Size Tokens for Common Dimensions
impact: HIGH
impactDescription: icon sizes, avatar dimensions, and touch targets scattered as magic numbers drift across screens — standardized sizes ensure visual consistency and HIG compliance
tags: space, size, dimensions, touch-targets, icons
---

## Define Size Tokens for Common Dimensions

Beyond spacing and radii, apps have recurring dimensional values: icon sizes, avatar sizes, minimum touch targets, thumbnail dimensions, and divider heights. Without tokens, these drift — one screen uses 24pt icons, another uses 20pt, a third uses 28pt. Size tokens lock these dimensions to a defined scale and ensure HIG compliance (e.g., the 44pt minimum touch target).

**Incorrect (dimensions as magic numbers):**

```swift
// NavigationBar.swift
Image(systemName: "bell")
    .frame(width: 22, height: 22)

// ProfileHeader.swift
AsyncImage(url: user.avatarURL)
    .frame(width: 80, height: 80)
    .clipShape(Circle())

// MessageRow.swift
AsyncImage(url: sender.avatarURL)
    .frame(width: 40, height: 40) // Different avatar size, intentional?
    .clipShape(Circle())

// SettingsRow.swift
Image(systemName: "gear")
    .frame(width: 28, height: 28) // Different icon size than nav bar

// ActionButton.swift
Button { } label: { Image(systemName: "plus") }
    .frame(width: 36, height: 36) // Below 44pt minimum touch target!
```

**Correct (size tokens by category):**

```swift
// DesignSystem/Tokens/Size.swift

/// Icon sizes — for SF Symbols and custom icons
enum IconSize {
    /// 16pt — inline icons (list accessories, label decorations)
    static let sm: CGFloat = 16

    /// 24pt — standard icons (toolbar, navigation, list leading)
    static let md: CGFloat = 24

    /// 32pt — prominent icons (empty states, feature callouts)
    static let lg: CGFloat = 32

    /// 48pt — hero icons (onboarding, large empty states)
    static let xl: CGFloat = 48
}

/// Avatar sizes — for user/entity images
enum AvatarSize {
    /// 32pt — compact contexts (comment threads, inline mentions)
    static let sm: CGFloat = 32

    /// 44pt — standard contexts (list rows, message cells)
    static let md: CGFloat = 44

    /// 64pt — detail contexts (profile headers, contact cards)
    static let lg: CGFloat = 64

    /// 96pt — hero contexts (own profile, full-screen headers)
    static let xl: CGFloat = 96
}

/// Touch target minimums — Apple HIG compliance
enum HitTarget {
    /// 44pt — absolute minimum per Apple HIG
    static let minimum: CGFloat = 44

    /// 48pt — comfortable target for primary actions
    static let comfortable: CGFloat = 48
}

/// Thumbnail sizes — for media previews
enum ThumbnailSize {
    /// 60pt — compact grid thumbnails
    static let sm: CGFloat = 60

    /// 80pt — list row thumbnails
    static let md: CGFloat = 80

    /// 120pt — featured content thumbnails
    static let lg: CGFloat = 120
}
```

**Usage in views:**

```swift
struct MessageRow: View {
    let message: Message

    var body: some View {
        HStack(spacing: Spacing.sm) {
            AsyncImage(url: message.sender.avatarURL)
                .frame(width: AvatarSize.md, height: AvatarSize.md)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(message.sender.name)
                    .font(AppTypography.headlinePrimary)
                Text(message.preview)
                    .font(AppTypography.bodySecondary)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .frame(width: IconSize.sm, height: IconSize.sm)
                .foregroundStyle(.tertiary)
        }
        .padding(.listCell)
    }
}

// Touch target compliance:
struct FloatingActionButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title3)
                .frame(
                    width: HitTarget.comfortable,
                    height: HitTarget.comfortable
                )
                .background(.accentPrimary)
                .foregroundStyle(.white)
                .clipShape(Circle())
                .shadow(radius: 4, y: 2)
        }
    }
}
```

Size tokens complement spacing tokens. Together, they eliminate all layout magic numbers.
