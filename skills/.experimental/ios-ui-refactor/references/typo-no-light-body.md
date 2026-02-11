---
title: Avoid Light Font Weights for Body Text
impact: CRITICAL
impactDescription: light/thin body text fails WCAG 2.1 contrast requirements for ~15% of users with low vision, degrades legibility in bright sunlight and low-brightness settings
tags: typo, weight, accessibility, legibility
---

## Avoid Light Font Weights for Body Text

Ultralight and thin font weights were designed for large display sizes (40pt+) where individual stroke details are visible. At body text sizes (15-17pt on iOS), these weights produce strokes as thin as 0.5-1 pixel on standard displays, which disappear under bright ambient light, low screen brightness, or any degree of visual impairment. SF Pro's regular weight at body size is carefully tuned for optical clarity across all viewing conditions. Using lighter weights for content the user must actually read is trading legibility for a "modern" aesthetic that only works on a designer's calibrated monitor.

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
