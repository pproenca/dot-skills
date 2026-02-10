---
title: Use matchedGeometryEffect for Smooth View Transitions
impact: MEDIUM
impactDescription: "enables fluid hero animations between 2 view states; eliminates manual frame calculations"
tags: anim, matched-geometry, hero, transition, namespace
---

## Use matchedGeometryEffect for Smooth View Transitions

`matchedGeometryEffect` creates smooth transitions between two views that represent the same conceptual element, like a thumbnail expanding to full-screen.

**Incorrect (abrupt switch between views):**

```swift
struct PhotoGallery: View {
    @State private var selectedPhoto: Photo?

    var body: some View {
        if let photo = selectedPhoto {
            FullScreenPhoto(photo: photo) // Pops in abruptly
        } else {
            LazyVGrid(columns: columns) {
                ForEach(photos) { photo in
                    PhotoThumbnail(photo: photo)
                        .onTapGesture { selectedPhoto = photo }
                }
            }
        }
    }
}
```

**Correct (matched geometry for fluid transition):**

```swift
struct PhotoGallery: View {
    @Namespace private var photoNamespace
    @State private var selectedPhoto: Photo?

    var body: some View {
        ZStack {
            LazyVGrid(columns: columns) {
                ForEach(photos) { photo in
                    if selectedPhoto != photo {
                        PhotoThumbnail(photo: photo)
                            .matchedGeometryEffect(id: photo.id, in: photoNamespace)
                            .onTapGesture {
                                withAnimation(.spring(duration: 0.35)) {
                                    selectedPhoto = photo
                                }
                            }
                    }
                }
            }

            if let photo = selectedPhoto {
                FullScreenPhoto(photo: photo)
                    .matchedGeometryEffect(id: photo.id, in: photoNamespace)
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.35)) {
                            selectedPhoto = nil
                        }
                    }
            }
        }
    }
}
```

**Key requirements:**
- Both views must share the same `@Namespace` and `id`
- Only one view with a given id should be visible at a time
- Wrap the state change in `withAnimation`

Reference: [matchedGeometryEffect - Apple Documentation](https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:issource:))
