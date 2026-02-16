---
title: One Typeface Per App, Differentiate with Weight and Size
impact: CRITICAL
impactDescription: eliminates visual fragmentation, reduces font asset size by 200-800 KB when consolidating 3+ custom typefaces to one
tags: less, typeface, rams-10, segall-minimal, consistency
---

## One Typeface Per App, Differentiate with Weight and Size

Rams' principle "as little design as possible" applied to typography means asking: can we do this with one typeface? Adding a typeface is adding complexity. Every additional typeface introduces a new set of metrics — x-height, ascenders, descenders, letter-spacing — that compete with each other for visual coherence. When a screen mixes Playfair Display for titles, Roboto for body, and Montserrat for captions, the vertical rhythm breaks because each face has different natural line heights at the same point size. Segall's "Think Minimal" demands you ask "can we do this with one?" before adding a second. Apple's own apps use SF Pro (or SF Pro Rounded) exclusively, achieving hierarchy through weight (ultralight to black), size, and color alone. A single typeface family with 3-4 weights provides more than enough range for any screen.

**Incorrect (multiple typefaces creating visual fragmentation):**

```swift
struct RestaurantDetailView: View {
    let restaurant: Restaurant

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(restaurant.name)
                    .font(.custom("PlayfairDisplay-Bold", size: 28))

                Text(restaurant.cuisine)
                    .font(.custom("Montserrat-Medium", size: 14))
                    .foregroundStyle(.secondary)

                Text(restaurant.description)
                    .font(.custom("Roboto-Regular", size: 16))

                Text("Reviews")
                    .font(.custom("Montserrat-SemiBold", size: 18))

                ForEach(restaurant.reviews) { review in
                    Text(review.body)
                        .font(.custom("Roboto-Light", size: 15))
                }
            }
        }
    }
}
```

**Correct (single typeface, hierarchy through weight and text style):**

```swift
struct RestaurantDetailView: View {
    let restaurant: Restaurant

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(restaurant.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(restaurant.cuisine)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(restaurant.description)
                    .font(.body)

                Text("Reviews")
                    .font(.headline)

                ForEach(restaurant.reviews) { review in
                    Text(review.body)
                        .font(.body)
                }
            }
        }
    }
}
```

**If your brand requires a custom typeface**, register a single family and map it to Apple's text styles:

```swift
Text(restaurant.name)
    .font(.custom("BrandSans-Bold", size: 34, relativeTo: .largeTitle))

Text(restaurant.description)
    .font(.custom("BrandSans-Regular", size: 17, relativeTo: .body))
```

This preserves Dynamic Type scaling while maintaining brand identity through one consistent face.

**When NOT to apply:**
- A secondary monospaced face for code snippets or data tables (e.g., `.font(.system(.body, design: .monospaced))`) is a functional distinction, not a decorative one, and is acceptable alongside the primary typeface.

Reference: [Apple HIG — Typography](https://developer.apple.com/design/human-interface-guidelines/typography)
