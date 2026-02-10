---
title: Use AsyncImage with Caching Strategy for Remote Images
impact: MEDIUM
impactDescription: eliminates manual URLSession boilerplate and provides built-in placeholder/error states, but requires explicit caching for production lists
tags: perf, asyncimage, images, loading, remote, caching
---

## Use AsyncImage with Caching Strategy for Remote Images

AsyncImage (iOS 15+) simplifies remote image loading with built-in placeholder and error states. However, AsyncImage does **not** provide meaningful image caching -- it relies on `URLSession.shared`'s `URLCache` (default 512KB memory / 10MB disk), which is insufficient for most apps. Images scrolled off-screen will be re-fetched. For lists and grids, pair AsyncImage with an explicit caching layer or use a dedicated library.

**Incorrect (manual image loading with no error handling):**

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
            let (data, _) = try? await URLSession.shared.data(from: url)
            if let data { image = UIImage(data: data) }
        }
    }
}
```

**Correct (AsyncImage with phase handling):**

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

**When AsyncImage is sufficient:**
- One-off image loads (profile header, settings avatar)
- Images that appear once per session
- Prototypes and simple apps

**When you need a caching library:**
- List/grid rows that recycle (images re-fetched on each scroll)
- Offline support required
- Custom cache eviction policies
- Image transformations (resize, blur, round corners at load time)

Recommended caching libraries:
- [CachedAsyncImage](https://github.com/lorenzofiamingo/swiftui-cached-async-image) -- drop-in AsyncImage replacement with NSCache
- [Nuke](https://github.com/kean/Nuke) -- full pipeline with disk cache, prefetching, progressive loading
- [Kingfisher](https://github.com/onevcat/Kingfisher) -- mature, feature-rich image loading and caching

Reference: [AsyncImage Documentation](https://developer.apple.com/documentation/swiftui/asyncimage)
