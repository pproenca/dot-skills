---
title: Use a 4pt Base Unit for All Spacing
impact: MEDIUM-HIGH
impactDescription: eliminates pixel-level misalignment on all device scale factors (1x, 2x, 3x) — virtually removes spacing-related design review comments by giving every measurement a shared rationale
tags: system, spacing, grid, edson-systems, rams-8, layout
---

## Use a 4pt Base Unit for All Spacing

An app with consistent spacing feels composed, intentional, premium — like a room where every object was placed with purpose. An app with arbitrary spacing (13, 18, 7) feels subtly untrustworthy. The user cannot articulate what is wrong, but something is off: the margins don't rhyme, the gaps between elements feel improvised, and the whole experience reads as unfinished. This is what Rams meant by "nothing must be arbitrary" — the user feels the absence of a system even if they cannot name it. A 4pt grid is the spatial system that makes every measurement relate to every other, so every screen feels part of one deliberate whole.

**Incorrect (arbitrary values that misalign across screens):**

```swift
struct ProductDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Image("product-hero")
                    .resizable()
                    .aspectRatio(contentMode: .fill)

                VStack(alignment: .leading, spacing: 7) {
                    Text("Ceramic Pour-Over Set")
                        .font(.title2.bold())
                        .padding(.top, 13)

                    Text("$48.00")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 9)

                    Text("Hand-thrown stoneware dripper with matched carafe. Fits standard #2 filters.")
                        .font(.body)
                        .padding(.horizontal, 18)

                    Button("Add to Cart") { }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 11)
                }
                .padding(.horizontal, 15)
            }
        }
    }
}
```

**Correct (all spacing derived from a 4pt base unit):**

```swift
enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

struct ProductDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Image("product-hero")
                    .resizable()
                    .aspectRatio(contentMode: .fill)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Ceramic Pour-Over Set")
                        .font(.title2.bold())
                        .padding(.top, Spacing.md)

                    Text("$48.00")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, Spacing.xs)

                    Text("Hand-thrown stoneware dripper with matched carafe. Fits standard #2 filters.")
                        .font(.body)

                    Button("Add to Cart") { }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                        .padding(.top, Spacing.sm)
                }
                .padding(.horizontal, Spacing.md)
            }
        }
    }
}
```

**Exceptional (the creative leap) — spacing as breathing room:**

```swift
enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40

    /// Extra generous top margin for section headers —
    /// creates chapter-like pauses in the scroll.
    static let sectionBreak: CGFloat = 48
}

struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                sectionHeader("Account")
                settingsRow("Name", value: "Pedro Proença")
                settingsRow("Email", value: "admin@therocketgrowth.com")

                sectionHeader("Notifications")
                    .padding(.top, Spacing.sectionBreak) // chapter pause
                settingsRow("Push Notifications", toggle: true)
                settingsRow("Email Digest", toggle: true)

                sectionHeader("Appearance")
                    .padding(.top, Spacing.sectionBreak)
                settingsRow("App Icon", value: "Default")
                settingsRow("Theme", value: "System")
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.xxl)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .padding(.bottom, Spacing.sm)
    }

    private func settingsRow(_ title: String, value: String = "",
                             toggle: Bool = false) -> some View {
        HStack {
            Text(title)
            Spacer()
            if toggle { Toggle("", isOn: .constant(true)).labelsHidden() }
            else { Text(value).foregroundStyle(.secondary) }
        }
        .padding(.vertical, Spacing.sm)
    }
}
```

The difference between "consistent" and "composed" lives in those `sectionBreak` pauses. A 48pt top margin before each section header does something no amount of grid compliance can achieve on its own — it gives the eye permission to rest, turning a settings screen into something that reads like chapters in a short book rather than a continuous scroll of rows. The screen feels unhurried because you gave it room to breathe on purpose, not by accident. That deliberate generosity is what separates a grid system from a spatial composition.

**The 4pt scale and when to use each step:**

```swift
//  4pt  — hairline gaps: icon-to-label in compact rows
//  8pt  — tight grouping: related items within a section
// 12pt  — default list item spacing
// 16pt  — standard content padding, screen horizontal margins
// 20pt  — section spacing within a scroll view
// 24pt  — major group separation
// 32pt  — hero spacing, top-of-screen breathing room

// Validating at a glance: every number should be divisible by 4.
// If you see .padding(13) or .padding(18), it is a spacing violation.
```

**When NOT to apply:** Text line spacing (`.lineSpacing()`) is controlled by the typographic engine and does not need to conform to the 4pt grid. System-provided spacing from `List` or `Form` should also be left as-is.

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout)
