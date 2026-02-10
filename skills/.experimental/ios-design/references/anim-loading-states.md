---
title: Animate Loading and Empty States
impact: MEDIUM-HIGH
impactDescription: reduces perceived load time by 40-60% through skeleton screens
tags: anim, loading, skeleton, placeholder, progress
---

## Animate Loading and Empty States

Use skeleton screens and subtle animations instead of spinners. They reduce perceived wait time and maintain layout stability.

**Incorrect (spinner blocks content):**

```swift
struct ArticleView: View {
    @State private var article: Article?
    @State private var isLoading = true

    var body: some View {
        if isLoading {
            ProgressView()  // Generic, loses context
        } else if let article {
            ArticleContent(article: article)
        }
    }
}
```

**Correct (skeleton maintains layout):**

```swift
struct ArticleView: View {
    @State private var article: Article?
    @State private var isLoading = true

    var body: some View {
        if isLoading {
            ArticleSkeleton()  // Same layout as content
        } else if let article {
            ArticleContent(article: article)
        }
    }
}

struct ArticleSkeleton: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(.gray.opacity(0.3))
                .frame(height: 24)
                .frame(maxWidth: .infinity)

            // Subtitle placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(.gray.opacity(0.3))
                .frame(height: 16)
                .frame(width: 200)

            // Body placeholders
            ForEach(0..<4, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 4)
                    .fill(.gray.opacity(0.3))
                    .frame(height: 14)
            }
        }
        .opacity(isAnimating ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 0.8).repeatForever(), value: isAnimating)
        .onAppear { isAnimating = true }
    }
}
```

**Redacted modifier (iOS 14+):**

```swift
struct ArticleView: View {
    let article: Article?

    var body: some View {
        ArticleContent(article: article ?? .placeholder)
            .redacted(reason: article == nil ? .placeholder : [])
    }
}
```

**Shimmer effect:**

```swift
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.5), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 300
                }
            }
    }
}
```

Reference: [Human Interface Guidelines - Loading](https://developer.apple.com/design/human-interface-guidelines/loading)
