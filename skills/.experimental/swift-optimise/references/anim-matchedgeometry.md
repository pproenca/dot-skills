---
title: Use matchedGeometryEffect for Shared Transitions
impact: MEDIUM
impactDescription: creates fluid hero transitions between views, perceived 2-3x smoother than cross-dissolve for shared elements
tags: anim, matchedgeometryeffect, transition, hero, shared-element
---

## Use matchedGeometryEffect for Shared Transitions

matchedGeometryEffect creates smooth transitions where elements appear to move between different views, like Apple's Photos app.

**Incorrect (abrupt appearance):**

```swift
struct PhotoGallery: View {
    @State private var selectedPhoto: Photo?

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(photos) { photo in
                    PhotoThumbnail(photo: photo)
                        .onTapGesture { selectedPhoto = photo }
                }
            }
        }
        .fullScreenCover(item: $selectedPhoto) { photo in
            PhotoDetail(photo: photo)  // Appears from nowhere
        }
    }
}
```

**Correct (matched geometry transition):**

```swift
struct PhotoGallery: View {
    @State private var selectedPhoto: Photo?
    @Namespace private var animation

    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(photos) { photo in
                        if selectedPhoto != photo {
                            PhotoThumbnail(photo: photo)
                                .matchedGeometryEffect(id: photo.id, in: animation)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        selectedPhoto = photo
                                    }
                                }
                        }
                    }
                }
            }

            if let photo = selectedPhoto {
                PhotoDetail(photo: photo)
                    .matchedGeometryEffect(id: photo.id, in: animation)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedPhoto = nil
                        }
                    }
            }
        }
    }
}
```

**Key requirements:**
1. Same `id` on both source and destination views
2. Same `@Namespace` shared between views
3. Wrap state change in `withAnimation`
4. Only one view with the ID visible at a time

**Card expansion example:**

```swift
struct ExpandableCardList: View {
    @State private var expandedID: UUID?
    @Namespace private var cardAnimation

    var body: some View {
        ForEach(cards) { card in
            CardView(card: card, isExpanded: expandedID == card.id)
                .matchedGeometryEffect(id: card.id, in: cardAnimation)
                .onTapGesture {
                    withAnimation(.spring(response: 0.4)) {
                        expandedID = expandedID == card.id ? nil : card.id
                    }
                }
        }
    }
}
```

**Known Limitations:**
- **Modifier order matters** -- apply `.matchedGeometryEffect` before `.frame()` and other layout modifiers, or the animation will interpolate from the wrong geometry
- **Unreliable inside NavigationStack** -- push/pop transitions conflict with matchedGeometryEffect; use `ZStack`-based custom navigation instead
- **AttributeGraph crashes** -- if two views with the same ID are visible simultaneously, SwiftUI may crash with "Bound preference ... tried to update multiple times per frame". Ensure only one view with a given ID is in the hierarchy at a time
- **Performance with many items** -- each matched ID adds overhead to the animation system; avoid matching more than ~20 items simultaneously

Reference: [matchedGeometryEffect Documentation](https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:issource:))
