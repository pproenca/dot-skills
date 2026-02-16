---
title: Avoid Light Font Weights for Body Text
impact: CRITICAL
impactDescription: light/thin body text fails WCAG 2.1 contrast requirements for ~15% of users with low vision, degrades legibility in bright sunlight and low-brightness settings
tags: thorough, typography, weight, rams-8, rams-2, accessibility
---

## Avoid Light Font Weights for Body Text

Rams' thoroughness extends to every detail of legibility. Thin font weights at body size produce strokes as thin as 0.5-1 pixel — invisible in sunlight, unreadable for anyone over 50. Rams' #2: if the text cannot be read, the product fails at being useful. The designer chose aesthetics over utility, which Rams would reject.

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

Reference: [Apple HIG — Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility), [WCAG 2.1 — 1.4.3 Contrast (Minimum)](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)
