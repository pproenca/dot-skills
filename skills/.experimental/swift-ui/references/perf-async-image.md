---
title: Use AsyncImage for Remote Images
impact: MEDIUM
impactDescription: automatic caching, placeholder, and error handling
tags: perf, asyncimage, images, loading, remote
---

## Use AsyncImage for Remote Images

AsyncImage (iOS 15+) handles image loading with built-in placeholder, error states, and caching. No need for third-party libraries for basic use cases.

**Incorrect (manual image loading):**

```swift
struct AvatarView: View {
    let url: URL
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
            } else {
                ProgressView()
            }
        }
        .task {
            // Manual loading, no caching, no error handling
            let (data, _) = try? await URLSession.shared.data(from: url)
            if let data { image = UIImage(data: data) }
        }
    }
}
```

**Correct (AsyncImage with states):**

```swift
struct AvatarView: View {
    let url: URL

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                Image(systemName: "person.circle.fill")
                    .foregroundStyle(.secondary)
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 50, height: 50)
        .clipShape(Circle())
    }
}
```

**Simplified syntax with placeholder:**

```swift
AsyncImage(url: user.avatarURL) { image in
    image
        .resizable()
        .aspectRatio(contentMode: .fill)
} placeholder: {
    Color.gray.opacity(0.3)
}
.frame(width: 50, height: 50)
.clipShape(Circle())
```

**With transition:**

```swift
AsyncImage(url: url, transaction: Transaction(animation: .easeIn)) { phase in
    switch phase {
    case .success(let image):
        image.resizable()
    default:
        Color.gray.opacity(0.3)
    }
}
```

**For complex caching needs, consider:**
- Kingfisher
- Nuke
- SDWebImage

But for most apps, AsyncImage is sufficient.

Reference: [AsyncImage Documentation](https://developer.apple.com/documentation/swiftui/asyncimage)
