---
title: Use a 4pt Base Unit for All Spacing
impact: MEDIUM-HIGH
impactDescription: arbitrary spacing values create pixel-level misalignment across screens — a 4pt grid guarantees alignment on all device scale factors (1x, 2x, 3x) and cuts design-to-dev handoff disputes by eliminating guesswork
tags: rhythm, spacing, grid, padding, layout, consistency
---

## Use a 4pt Base Unit for All Spacing

Arbitrary padding values like 13, 18, or 7 points break alignment between adjacent elements and produce sub-pixel rendering on 2x and 3x displays. A 4pt base unit snaps every measurement to values that divide evenly into all iOS display scales, ensuring crisp edges without anti-aliasing artifacts. Define spacing constants once and reference them everywhere — this turns spacing from a per-view decision into a system-level constraint.

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

**When NOT to enforce:** Text line spacing (`.lineSpacing()`) is controlled by the typographic engine and does not need to conform to the 4pt grid. System-provided spacing from `List` or `Form` should also be left as-is.

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout)
