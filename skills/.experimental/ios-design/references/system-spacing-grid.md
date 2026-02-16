---
title: Use a 4pt Base Unit for All Spacing
impact: HIGH
impactDescription: eliminates pixel-level misalignment on all device scale factors (1x, 2x, 3x) — reduces spacing-related design review comments by 80-90%
tags: system, spacing, grid, kocienda-convergence, edson-systems, layout
---

## Use a 4pt Base Unit for All Spacing

Edson's systems thinking means zooming out to see relationships between objects. A 4pt grid is the spatial system — every measurement relates to every other. Kocienda's convergence demanded that the iPhone keyboard team try dozens of key spacings before finding the one that felt right; the result was a system, not a collection of arbitrary gaps. When spacing is arbitrary (13, 18, 7), the interface feels assembled by accident; when it's systematic (8, 12, 16, 24), every screen feels like part of one deliberate whole.

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

                    Text("Hand-thrown stoneware dripper with matched carafe.")
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

                    Text("Hand-thrown stoneware dripper with matched carafe.")
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
//  4pt — hairline gaps: icon-to-label in compact rows
//  8pt — tight grouping: related items within a section
// 12pt — default list item spacing
// 16pt — standard content padding, screen horizontal margins
// 20pt — section spacing within a scroll view
// 24pt — major group separation
// 32pt — hero spacing, top-of-screen breathing room

// Quick validation: every padding/spacing number must be divisible by 4.
// If you see .padding(13) or .padding(18), it is a spacing violation.
```

**When NOT to enforce:** Text line spacing (`.lineSpacing()`) is controlled by the typographic engine and does not need to conform to the 4pt grid. System-provided spacing from `List` or `Form` should be left as-is.

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout)
