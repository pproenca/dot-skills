---
title: Always Respect Safe Areas for Content
impact: CRITICAL
impactDescription: ignoring safe areas clips content behind the Dynamic Island, home indicator, and status bar on 100% of modern iPhones — text becomes unreadable and buttons become untappable
tags: empathy, safe-area, layout, kocienda-empathy, edson-people, device
---

## Always Respect Safe Areas for Content

Kocienda's keyboard team tested on every prototype device — they knew the physical form factor was a constraint to empathize with, not fight against. The Dynamic Island, home indicator, and status bar are the modern equivalents: physical constraints that protect the user's content from being obscured. Edson's "design is about people" means accepting that your content must live within the space the user can actually see and touch, not behind hardware elements they cannot move.

**Incorrect (ignoring safe areas clips content behind system UI):**

```swift
struct ArticleView: View {
    let article: Article

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(article.title)
                    .font(.largeTitle.bold())

                Text(article.body)
                    .font(.body)
            }
            .padding(.horizontal, 16)
        }
        // Ignores safe areas — text hides behind Dynamic Island and home indicator
        .ignoresSafeArea()
    }
}
```

**Correct (safe areas protect content, edges extend backgrounds):**

```swift
struct ArticleView: View {
    let article: Article

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(article.title)
                    .font(.largeTitle.bold())

                Text(article.body)
                    .font(.body)
            }
            // Content respects safe areas automatically
            .padding(.horizontal, 16)
        }
        // Only background extends to edges, not content
        .background(.background)
    }
}
```

**Safe area rules:**
- **Content** (text, buttons, inputs) must always respect safe areas — never use `.ignoresSafeArea()` on content
- **Backgrounds** (colors, images, materials) should extend to edges using `.ignoresSafeArea()` or `.background { Color.blue.ignoresSafeArea() }`
- **Scroll views** automatically handle safe areas for their content; don't add manual insets
- **Keyboard** safe area: use `.safeAreaInset(edge: .bottom)` for floating elements above the keyboard

**When to use .ignoresSafeArea():** Only for decorative backgrounds, hero images, or full-bleed media where the content itself is not interactive or textual. Even then, overlay text must still respect safe areas.

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout)
