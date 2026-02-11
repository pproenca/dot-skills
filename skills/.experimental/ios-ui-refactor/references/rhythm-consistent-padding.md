---
title: Use Consistent Padding Across All Screens
impact: MEDIUM-HIGH
impactDescription: inconsistent screen margins make an app feel like separate features stitched together — standardizing padding values makes every screen instantly recognizable as part of the same product
tags: rhythm, padding, margins, consistency, layout
---

## Use Consistent Padding Across All Screens

When one screen uses 16pt horizontal padding, the next uses 20pt, and a third uses 12pt, users perceive the app as disjointed even if they cannot articulate why. The fix is to define a small set of named padding values — screen margins, content padding, section spacing — and apply them uniformly. This does not mean every screen looks identical; it means the spatial scaffolding is shared across all screens.

**Incorrect (padding values chosen per-screen by different developers):**

```swift
// Screen A: profile
struct ProfileView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Profile")
                    .font(.largeTitle.bold())
                Text("Manage your account settings")
                    .foregroundStyle(.secondary)
                // ... content
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
        }
    }
}

// Screen B: settings — different padding for the same layout pattern
struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Settings")
                    .font(.largeTitle.bold())
                Text("Customize your experience")
                    .foregroundStyle(.secondary)
                // ... content
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }
}

// Screen C: yet another variation
struct ActivityView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Activity")
                    .font(.largeTitle.bold())
                    .padding(.leading, 12)
                // ... content
            }
            .padding(.horizontal, 24)
        }
    }
}
```

**Correct (shared layout constants produce uniform spatial rhythm):**

```swift
enum Layout {
    /// Horizontal inset from screen edges for all scrollable content
    static let screenMargin: CGFloat = 16
    /// Spacing between major sections within a screen
    static let sectionSpacing: CGFloat = 24
    /// Internal padding within cards, banners, grouped containers
    static let contentPadding: CGFloat = 16
    /// Spacing between related items within a section
    static let itemSpacing: CGFloat = 8
}

struct ProfileView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
                VStack(alignment: .leading, spacing: Layout.itemSpacing) {
                    Text("Profile")
                        .font(.largeTitle.bold())
                    Text("Manage your account settings")
                        .foregroundStyle(.secondary)
                }
                // ... content sections
            }
            .padding(.horizontal, Layout.screenMargin)
        }
    }
}

struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
                VStack(alignment: .leading, spacing: Layout.itemSpacing) {
                    Text("Settings")
                        .font(.largeTitle.bold())
                    Text("Customize your experience")
                        .foregroundStyle(.secondary)
                }
                // ... content sections
            }
            .padding(.horizontal, Layout.screenMargin)
        }
    }
}

struct ActivityView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
                Text("Activity")
                    .font(.largeTitle.bold())
                // ... content sections
            }
            .padding(.horizontal, Layout.screenMargin)
        }
    }
}
```

**Audit checklist for padding consistency:**

```swift
// 1. Search the codebase for .padding( — every value should reference Layout.*
// 2. Flag any raw numeric padding that is not 4pt-grid aligned
// 3. Verify all top-level ScrollView content uses the same screenMargin
// 4. Check cards and grouped containers use the same contentPadding
// 5. Confirm section gaps are uniform (sectionSpacing) across all screens
```

**When NOT to enforce:** Full-bleed content (images, maps, media players) intentionally breaks screen margins. `List` and `Form` provide their own system-managed insets — do not override them with manual padding.

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout)
