---
title: Use Zoom Navigation Transition for Collection Detail (iOS 18)
impact: HIGH
impactDescription: zoom transitions create spatial hierarchy that push/pop cannot express
tags: spatial, zoom, navigation, iOS18, transition
---

## Use Zoom Navigation Transition for Collection Detail (iOS 18)

iOS 18 introduced `.navigationTransition(.zoom(sourceID:in:))`, a system-level transition that zooms content in from a specific source element and zooms back out on dismissal. This replaces the manual `matchedGeometryEffect` workaround for navigation transitions and produces a result identical to Apple's Photos app — a grid item expands into its detail with spatial continuity, and the back gesture smoothly reverses the zoom.

The standard `NavigationStack` push animation slides content from the right edge. For a photo grid, recipe collection, or product catalog, this slide gives no spatial cue about *which* item was selected. The user taps a thumbnail in the center of the screen, but the detail arrives from the right — the spatial link is broken.

**Incorrect (standard push animation — no spatial connection to tapped item):**

```swift
struct PhotoGridView: View {
    let photos: [Photo]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 2)], spacing: 2) {
                    ForEach(photos) { photo in
                        NavigationLink(value: photo) {
                            // Standard NavigationLink — push animation slides
                            // from the right. User taps a thumbnail in the center
                            // of the grid, but the detail arrives from offscreen.
                            AsyncImage(url: photo.thumbnailURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color(.systemGray5)
                            }
                            .frame(minHeight: 110)
                            .clipped()
                        }
                    }
                }
            }
            .navigationTitle("Photos")
            .navigationDestination(for: Photo.self) { photo in
                PhotoDetailView(photo: photo)
            }
        }
    }
}
```

**Correct (zoom transition — detail expands from the tapped thumbnail):**

```swift
struct PhotoGridView: View {
    @Namespace private var photoNamespace
    let photos: [Photo]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 2)], spacing: 2) {
                    ForEach(photos) { photo in
                        NavigationLink(value: photo) {
                            AsyncImage(url: photo.thumbnailURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color(.systemGray5)
                            }
                            .frame(minHeight: 110)
                            .clipped()
                        }
                        // Mark the source for the zoom transition
                        .matchedTransitionSource(id: photo.id, in: photoNamespace)
                    }
                }
            }
            .navigationTitle("Photos")
            .navigationDestination(for: Photo.self) { photo in
                PhotoDetailView(photo: photo)
                    // The detail zooms in from the matched source
                    .navigationTransition(.zoom(sourceID: photo.id, in: photoNamespace))
            }
        }
    }
}

struct PhotoDetailView: View {
    let photo: Photo

    var body: some View {
        ScrollView {
            AsyncImage(url: photo.fullURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
        }
        .navigationTitle(photo.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
```

**Why zoom transitions replace manual matchedGeometryEffect for navigation:**

| Aspect | matchedGeometryEffect | .navigationTransition(.zoom) |
|---|---|---|
| Scope | Same parent view required | Works across NavigationStack push/pop |
| Back gesture | Must be implemented manually | Built-in interactive pop with zoom reversal |
| Corner radius | Must be animated manually | System handles clipping and radius interpolation |
| Performance | Developer-managed | System-optimized with Metal rendering |

**Key implementation details:**

- **`.matchedTransitionSource(id:in:)`** goes on the source element in the collection. It tells the system where to zoom from.
- **`.navigationTransition(.zoom(sourceID:in:))`** goes on the destination view inside `.navigationDestination`. It tells the system to zoom into this view from the source.
- **The namespace must be shared** between the source (grid) and the destination modifier. Since `.navigationDestination` is a child of the same `NavigationStack`, the `@Namespace` declared in the parent is accessible.
- **Works with `NavigationLink` and programmatic navigation** via `NavigationStack(path:)`.

**Reference:** WWDC 2024 "Enhance your UI animations and transitions" — introduces `.navigationTransition(.zoom)` and `.matchedTransitionSource` as the standard pattern for collection-to-detail spatial transitions.
