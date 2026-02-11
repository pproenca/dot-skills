---
title: Limit Typography Variations to 3-4 Per Screen
impact: HIGH
impactDescription: more than 4 distinct type treatments per screen creates visual noise — Apple's own apps rarely exceed 3 (title, body, caption)
tags: type, hierarchy, visual-design, discipline
---

## Limit Typography Variations to 3-4 Per Screen

Every distinct font/weight/size combination on a screen competes for the user's attention. With 3 treatments, the hierarchy is clear: primary, secondary, tertiary. With 6+, nothing stands out and the eye wanders. Apple's own apps are disciplined about this — a Settings screen uses `.headline` for row labels, `.body` for descriptions, and `.caption` for footers. That's it.

**Incorrect (too many typographic treatments):**

```swift
struct OverloadedProfileView: View {
    var body: some View {
        ScrollView {
            // Treatment 1: large title
            Text(user.name)
                .font(.largeTitle.weight(.bold))

            // Treatment 2: title2
            Text("@\(user.handle)")
                .font(.title2)

            // Treatment 3: headline
            Text("\(user.followers) followers")
                .font(.headline)

            // Treatment 4: subheadline
            Text("Joined \(user.joinDate)")
                .font(.subheadline)

            // Treatment 5: body
            Text(user.bio)
                .font(.body)

            // Treatment 6: callout
            Text("Recent Activity")
                .font(.callout.weight(.semibold))

            // Treatment 7: footnote
            Text("Last active 2h ago")
                .font(.footnote)

            // Treatment 8: caption
            Text("Profile ID: \(user.id)")
                .font(.caption2)

            // 8 distinct treatments — the hierarchy is unclear
            // The eye has no clear scanning path
        }
    }
}
```

**Correct (3 treatments with clear hierarchy):**

```swift
struct CleanProfileView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Treatment 1: Primary — user identity
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(user.name)
                        .font(AppTypography.headlinePrimary)
                    Text("@\(user.handle)")
                        .font(AppTypography.bodySecondary)
                        .foregroundStyle(.secondary)
                }

                // Treatment 2: Body — main content
                Text(user.bio)
                    .font(AppTypography.bodyPrimary)

                // Treatment 3: Caption — metadata
                HStack(spacing: Spacing.md) {
                    Label("\(user.followers) followers", systemImage: "person.2")
                    Label("Joined \(user.joinDate)", systemImage: "calendar")
                }
                .font(AppTypography.caption)
                .foregroundStyle(.secondary)
            }
        }
    }
}
// 3 treatments: headline for name, body for content, caption for metadata
// Clear visual hierarchy, easy scanning path
```

**When you need more than 4 treatments, restructure the information:**

```swift
// Instead of cramming everything onto one screen,
// use progressive disclosure:

struct ProfileView: View {
    var body: some View {
        List {
            ProfileHeaderSection(user: user)   // 3 treatments
            StatsSection(stats: user.stats)     // 2 treatments (reuses body + caption)
            NavigationLink("Activity") {
                ActivityDetailView(user: user)  // Own screen, own hierarchy
            }
        }
    }
}
```

If a screen genuinely needs 5+ type treatments, that screen is doing too much. Split it into sections or child screens.
