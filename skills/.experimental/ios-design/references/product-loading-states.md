---
title: Show Honest Loading States, Not Indefinite Spinners
impact: HIGH
impactDescription: indefinite spinners give users zero information about progress — honest loading states reduce perceived wait time by 30-40% and prevent premature abandonment
tags: product, loading, progress, edson-product-marketing, kocienda-demo, state
---

## Show Honest Loading States, Not Indefinite Spinners

Edson's "the product is the marketing" means loading states are not a technical afterthought — they are part of the product experience. An indefinite spinner says "something is happening, I have no idea how long." A shimmer placeholder says "content is coming and it will look like this." A progress bar says "we're 60% done." Kocienda's demo culture meant that every state of the interface was intentional; a blank screen with a spinner would never survive a Friday demo.

**Incorrect (indefinite spinner with no context):**

```swift
struct FeedView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = true

    var body: some View {
        if isLoading {
            ProgressView()
            // User stares at a spinner with no context
        } else {
            List(posts) { post in
                PostRow(post: post)
            }
        }
    }
}
```

**Correct (skeleton placeholder communicates expected layout):**

```swift
struct FeedView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = true

    var body: some View {
        List {
            if isLoading {
                ForEach(0..<5, id: \.self) { _ in
                    PostRowPlaceholder()
                        .redacted(reason: .placeholder)
                }
            } else {
                ForEach(posts) { post in
                    PostRow(post: post)
                }
            }
        }
        .task {
            posts = await fetchPosts()
            isLoading = false
        }
    }
}

struct PostRowPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading) {
                    Text("Placeholder name")
                    Text("2 hours ago")
                        .font(.caption)
                }
            }
            Text("This is placeholder text that represents the post content area.")
                .font(.body)
        }
    }
}
```

**Loading state hierarchy:**
| Content Type | Loading Pattern | Why |
|-------------|----------------|-----|
| List/feed | `.redacted(reason: .placeholder)` | Shows expected structure |
| Single item | Inline `ProgressView` with label | Minimal, honest |
| File upload | `ProgressView(value:total:)` | Shows real progress |
| Network fetch | Pull-to-refresh indicator | System-managed |
| First launch | Skeleton + shimmer animation | Premium feel |

**When NOT to show loading:** For operations under 100ms, don't show any loading indicator — it creates flicker. For operations under 1 second, a subtle opacity animation is sufficient.

Reference: [Progress indicators - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/progress-indicators)
