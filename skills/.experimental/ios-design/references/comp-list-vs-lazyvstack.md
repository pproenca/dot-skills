---
title: Choose List vs LazyVStack by Feature Needs
impact: HIGH
impactDescription: prevents rebuilding UI when wrong component lacks needed features
tags: comp, list, lazyvstack, scrollview, selection
---

## Choose List vs LazyVStack by Feature Needs

List provides built-in features (swipe actions, selection, editing). LazyVStack offers more customization. Choose based on what you need.

**Incorrect (LazyVStack when List features needed):**

```swift
struct InboxView: View {
    @State private var emails: [Email] = []

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(emails) { email in
                    EmailRow(email: email)
                    // No swipe actions, no selection, no edit mode
                    // Would need to rebuild from scratch to add these
                }
            }
        }
    }
}
```

**Correct (List when swipe/selection needed):**

```swift
struct InboxView: View {
    @State private var emails: [Email] = []
    @State private var selection: Set<Email.ID> = []

    var body: some View {
        List(emails, selection: $selection) { email in
            EmailRow(email: email)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) { delete(email) } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
        }
        .listStyle(.plain)
    }
}
```

**Use LazyVStack for custom layouts:**

```swift
struct FeedView: View {
    let posts: [Post]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(posts) { post in
                    PostCard(post: post)
                        .padding(.horizontal)
                }
            }
        }
    }
}
```

**Decision matrix:**

| Need | Use |
|------|-----|
| Swipe actions | List |
| Selection (single/multi) | List |
| Section headers with sticky | List |
| Edit mode (reorder/delete) | List |
| Custom layouts | LazyVStack |
| Full visual control | LazyVStack |

Reference: [List or LazyVStack - Fatbobman](https://fatbobman.com/en/posts/list-or-lazyvstack/)
