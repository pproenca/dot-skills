---
title: Use Consistent Padding Across All Screens
impact: MEDIUM-HIGH
impactDescription: reduces unique padding values from 10-15 per app to 4 named constants — eliminates per-screen margin drift that makes screens feel disconnected
tags: system, padding, margins, edson-systems, rams-8, consistency
---

## Use Consistent Padding Across All Screens

Edson's systems thinking demands that product and context are one — screens that use different padding values are contextually disconnected. Rams insisted nothing be left to chance. Named layout constants (screenMargin, sectionSpacing, contentPadding) make the spatial system explicit.

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

// SettingsView and ActivityView follow the same pattern:
// VStack(spacing: Layout.sectionSpacing) + .padding(.horizontal, Layout.screenMargin)
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
