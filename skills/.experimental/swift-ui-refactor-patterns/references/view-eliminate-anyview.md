---
title: Replace AnyView with @ViewBuilder
impact: HIGH
impactDescription: restores type-based diffing, prevents full-tree redraws
tags: view, anyview, viewbuilder, type-erasure, performance
---

## Replace AnyView with @ViewBuilder

AnyView erases the concrete type of a view, which destroys SwiftUI's ability to perform type-based structural diffing. Instead of comparing individual properties, SwiftUI must tear down the entire subtree and rebuild it from scratch on every update. Replacing AnyView with @ViewBuilder preserves type information so SwiftUI can diff efficiently and animate transitions correctly.

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

Reference: [Avoiding SwiftUI's AnyView](https://www.swiftbysundell.com/articles/avoiding-anyview-in-swiftui/)
