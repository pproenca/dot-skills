---
title: Avoid Light Font Weights for Body Text
impact: CRITICAL
impactDescription: light/thin body text fails WCAG 2.1 contrast requirements for ~15% of users with low vision, degrades legibility in bright sunlight and low-brightness settings
tags: thorough, typography, weight, rams-8, rams-2, accessibility
---

## Avoid Light Font Weights for Body Text

Thin font weights at body size look refined on a designer's retina monitor in a dim office, but they produce strokes as thin as half a pixel — strokes that vanish in sunlight and become invisible to anyone over 50. The aesthetic that reads as "elegant" on the design file reads as "where did the text go?" on a bus in daylight. Choosing a weight that cannot be read in real conditions is choosing decoration over craft. If the text disappears outside the controlled environment where it was designed, the typography has failed at its only job.

**Incorrect (light/thin weights on body and content text):**

```swift
struct ProfileView: View {
    let user: UserProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(user.displayName)
                .font(.title)
                .fontWeight(.ultraLight)

            Text(user.bio)
                .font(.body)
                .fontWeight(.light)

            Text("Member since \(user.joinDate.formatted(.dateTime.year().month()))")
                .font(.subheadline)
                .fontWeight(.thin)

            ForEach(user.recentPosts) { post in
                Text(post.body)
                    .font(.body)
                    .fontWeight(.light)
            }
        }
    }
}
```

**Correct (regular weight minimum for readable text, light only for large display):**

```swift
struct ProfileView: View {
    let user: UserProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(user.displayName)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(user.bio)
                .font(.body)

            Text("Member since \(user.joinDate.formatted(.dateTime.year().month()))")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(user.recentPosts) { post in
                Text(post.body)
                    .font(.body)
            }
        }
    }
}
```

**Where lighter weights are appropriate:**

```swift
// Large display text (40pt+) where thin strokes remain clearly visible
Text("Good Morning")
    .font(.system(size: 48, weight: .thin))

// Decorative numerals in a dashboard hero area
Text("2,847")
    .font(.system(size: 64, weight: .ultraLight))
    .contentTransition(.numericText())
```

**Quick rule of thumb:** if the text is smaller than `.title` (28pt), use `.regular` weight or heavier. Reserve `.light`, `.thin`, and `.ultraLight` for text that would still be legible even if its stroke width were halved.

**When NOT to apply:** Large display text (40pt+) used as a hero element where thin/ultraLight strokes remain clearly visible, and decorative numerals in dashboard headers where the oversized type compensates for the reduced stroke weight.

Reference: [Apple HIG — Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility), [WCAG 2.1 — 1.4.3 Contrast (Minimum)](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)
