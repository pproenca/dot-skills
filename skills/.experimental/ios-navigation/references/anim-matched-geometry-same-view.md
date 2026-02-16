---
title: Use matchedGeometryEffect Only Within Same View Hierarchy
impact: HIGH
impactDescription: prevents broken animations across navigation pushes
tags: anim, matched-geometry, view-hierarchy, common-mistake
---

## Use matchedGeometryEffect Only Within Same View Hierarchy

`matchedGeometryEffect` animates geometry changes between two states within a single view hierarchy -- it does NOT work across `NavigationStack` pushes because the source view is removed from the tree before the destination appears. This is one of the most common SwiftUI animation mistakes. Use `.navigationTransition(.zoom)` for hero animations across navigation, and reserve `matchedGeometryEffect` for in-place expand/collapse transitions.

**Incorrect (matchedGeometryEffect across NavigationLink push):**

```swift
// BAD: Namespace cannot bridge across NavigationStack push
// Source cell deallocated before detail appears, animation fails
struct PhotoGalleryView: View {
    @Namespace private var animation
    let photos: [Photo]
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                    ForEach(photos) { photo in
                        NavigationLink(value: photo) {
                            AsyncImage(url: photo.thumbnailURL)
                                .matchedGeometryEffect(id: photo.id, in: animation)
                        }
                    }
                }
            }
            .navigationDestination(for: Photo.self) { photo in
                AsyncImage(url: photo.fullURL)
                    .matchedGeometryEffect(id: photo.id, in: animation, isSource: false)
                    // WRONG: source gone, animation fails
            }
        }
    }
}
```

**Correct (matchedGeometryEffect for in-place expansion, zoom for navigation):**

```swift
@Equatable
struct PhotoGalleryView: View { // In-place expand/collapse (no navigation push)
    @Namespace private var animation
    @State private var expandedPhoto: Photo?
    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                    ForEach(photos) { photo in
                        if expandedPhoto != photo {
                            AsyncImage(url: photo.thumbnailURL)
                                .matchedGeometryEffect(id: photo.id, in: animation)
                                .onTapGesture {
                                    withAnimation(.spring(duration: 0.4, bounce: 0)) { expandedPhoto = photo }
                                }
                        }
                    }
                }
            }
            if let photo = expandedPhoto {
                PhotoDetailOverlay(photo: photo)
                    .matchedGeometryEffect(id: photo.id, in: animation)
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.4, bounce: 0)) { expandedPhoto = nil }
                    }
            }
        }
    }
}
// OPTION B: Navigation push with zoom transition (iOS 18+)
@Equatable
struct PhotoGalleryNavigationView: View {
    @Namespace private var zoomNamespace
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                    ForEach(photos) { photo in
                        NavigationLink(value: photo) {
                            AsyncImage(url: photo.thumbnailURL)
                        }
                        .matchedTransitionSource(id: photo.id, in: zoomNamespace)
                    }
                }
            }
            .navigationDestination(for: Photo.self) { photo in
                PhotoDetailView(photo: photo)
                    .navigationTransition(.zoom(sourceID: photo.id, in: zoomNamespace))
            }
        }
    }
}
```
