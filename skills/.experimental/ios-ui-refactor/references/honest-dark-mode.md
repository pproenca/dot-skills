---
title: Define Light and Dark Variants for Every Custom Color
impact: CRITICAL
impactDescription: a single-variant custom color produces invisible text or blinding backgrounds for 82% of iPhone users who have dark mode enabled at least part of the day
tags: honest, dark-mode, color, rams-6, segall-brutal, appearance
---

## Define Light and Dark Variants for Every Custom Color

It is 11 PM, you are in bed, and you switch to dark mode to save your eyes. The app goes dark — except for one banner that stays brand teal on white, a searing rectangle that flares across your retina like a flashlight in a dark room. The designer never opened this screen after sunset. A single-variant custom color is a broken promise: it claims to work everywhere but was only ever tested in one lighting condition. Every custom color needs a light version and a dark version, defined explicitly in the asset catalog — "Any Appearance" and "Dark" — because an interface that blinds you at nightfall is not a styling oversight, it is a craft failure. The honest approach is to treat both appearances as first-class from the start, never relying on a single value that looked fine on a Retina display in a lit office.

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

**When NOT to apply:** Apps that intentionally use a fixed dark or light theme as a core brand identity (e.g., a cinema or astronomy app locked to dark mode), where the content context makes a single appearance the correct choice.

Reference: [Dark Mode - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/dark-mode), [WWDC19 — Implementing Dark Mode on iOS](https://developer.apple.com/videos/play/wwdc2019/214/)
