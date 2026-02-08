---
title: Replace AnyView with @ViewBuilder or Generics
impact: HIGH
impactDescription: restores type-based diffing, prevents full-tree redraws
tags: view, anyview, viewbuilder, type-erasure, performance, generics
---

## Replace AnyView with @ViewBuilder or Generics

AnyView erases the concrete type of a view, which destroys SwiftUI's ability to perform type-based structural diffing. Instead of comparing individual properties, SwiftUI must tear down the entire subtree and rebuild it from scratch on every update. Replacing AnyView with @ViewBuilder, generics, or Group preserves type information so SwiftUI can diff efficiently and animate transitions correctly.

**Incorrect (AnyView erases types, forcing full subtree rebuilds):**

```swift
struct MediaCard: View {
    let media: MediaItem

    var body: some View {
        VStack {
            mediaContent
            Text(media.title).font(.headline)
        }
    }

    var mediaContent: AnyView {
        switch media.kind {
        case .photo:
            return AnyView(
                AsyncImage(url: media.imageURL) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: { ProgressView() }
            )
        case .video:
            return AnyView(VideoPlayerView(url: media.videoURL))
        case .audio:
            return AnyView(AudioWaveformView(url: media.audioURL))
        }
    }
}
```

**Correct (@ViewBuilder preserves types for efficient diffing):**

```swift
struct MediaCard: View {
    let media: MediaItem

    var body: some View {
        VStack {
            mediaContent
            Text(media.title).font(.headline)
        }
    }

    @ViewBuilder
    var mediaContent: some View {
        switch media.kind {
        case .photo:
            AsyncImage(url: media.imageURL) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: { ProgressView() }
        case .video:
            VideoPlayerView(url: media.videoURL)
        case .audio:
            AudioWaveformView(url: media.audioURL)
        }
    }
}
```

**Alternative with Group:**

```swift
var body: some View {
    Group {
        if showImage {
            AsyncImage(url: imageURL)
        } else {
            Text(placeholder)
        }
    }
}
```

**Using generics instead of type erasure:**

```swift
struct Card<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(.background.secondary)
            .cornerRadius(12)
    }
}
```

**When AnyView is acceptable:**
- Heterogeneous collections where type erasure is unavoidable
- Plugin systems with unknown view types
- Rarely-updated views where diffing cost is negligible

Reference: [Avoiding SwiftUI's AnyView](https://www.swiftbysundell.com/articles/avoiding-anyview-in-swiftui/)
