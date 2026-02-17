---
title: One Typeface Per App, Differentiate with Weight and Size
impact: CRITICAL
impactDescription: eliminates visual fragmentation, reduces font asset size by 200-800 KB when consolidating 3+ custom typefaces to one
tags: less, typeface, rams-10, segall-minimal, consistency
---

## One Typeface Per App, Differentiate with Weight and Size

When you read a screen set in one typeface, the text feels like one voice speaking at different volumes — a whisper for captions, a clear tone for body, a commanding presence for titles. When a screen mixes Playfair Display for headlines, Roboto for body, and Montserrat for captions, it feels like three strangers narrating the same story. The vertical rhythm fractures because each typeface has different natural line heights, letter spacing, and x-heights at the same point size — they simply do not breathe together. Apple understood this: every first-party app uses SF Pro, achieving remarkable range through weight alone (ultralight to black), size, and color. A single typeface family with 3-4 weights is not a constraint — it is a discipline that produces visual coherence you can feel even if you cannot name it.

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
