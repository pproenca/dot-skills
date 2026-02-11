---
title: Define Light and Dark Variants for Every Custom Color
impact: CRITICAL
impactDescription: a single-variant custom color produces invisible text or blinding backgrounds for 82% of iPhone users who have dark mode enabled at least part of the day — the defect ships silently because developers test in one appearance
tags: color, dark-mode, appearance, adaptive, asset-catalog
---

## Define Light and Dark Variants for Every Custom Color

Every custom color that lacks a dark variant is a bug waiting for nightfall. A brand teal that looks refined on a white background becomes illegible against dark gray or, worse, washes out entirely. A principal designer ensures that every custom color in the asset catalog has both "Any Appearance" and "Dark" variants explicitly defined — never relying on a single value to work in both contexts.

**Incorrect (single-value custom color used in both appearances):**

```swift
struct MembershipBanner: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Premium Member")
                .font(.headline)
                .foregroundStyle(Color("brandTeal"))

            Text("Your subscription renews on March 1")
                .font(.subheadline)
                .foregroundStyle(Color("brandDarkGreen"))
        }
        .padding()
        .background(Color("brandLightBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// Asset catalog: "brandTeal" has only one value: #008080
// In dark mode: #008080 on near-black background = 3.2:1 contrast (fails AA)
// Asset catalog: "brandLightBackground" has only one value: #F5F5F0
// In dark mode: renders as a bright rectangle against a dark interface
```

**Correct (adaptive color with explicit light and dark variants):**

```swift
// Option A: Asset catalog with paired variants
// "brandAccent" → Any Appearance: #008080, Dark: #40C8C8
// "backgroundBrandSubtle" → Any Appearance: #F5F5F0, Dark: #1C2A2A

struct MembershipBanner: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Premium Member")
                .font(.headline)
                .foregroundStyle(Color("brandAccent"))

            Text("Your subscription renews on March 1")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color("backgroundBrandSubtle"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// Option B: Programmatic adaptive color (useful for dynamic theming)
extension Color {
    static let brandAccent = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.25, green: 0.78, blue: 0.78, alpha: 1)
                : UIColor(red: 0.0, green: 0.50, blue: 0.50, alpha: 1)
        }
    )
}
```

**Dark variant creation guidelines:**
| Light variant property | Dark variant adjustment |
|---|---|
| Dark foreground text color | Lighten to maintain 4.5:1 on dark backgrounds |
| Light background surface | Darken to sit within iOS dark mode elevation scale |
| Saturated accent | Increase lightness 15-20% to maintain vibrancy on dark surfaces |
| Subtle tint/wash | Reduce opacity or shift to a dark-native desaturated tone |

**Verification checklist:**
1. Open every custom color set in the asset catalog — if "Dark" row is empty, the color is broken
2. Run the app in both appearances and screenshot every screen side by side
3. Check Increase Contrast accessibility setting — asset catalogs support "High Contrast" variants too
4. Use `UITraitCollection.performAsCurrent` in unit tests to validate both variants exist

Reference: [Dark Mode - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/dark-mode), [WWDC19 — Implementing Dark Mode on iOS](https://developer.apple.com/videos/play/wwdc2019/214/)
