---
title: Use matchedGeometryEffect for Contextual Origin Transitions
impact: MEDIUM
impactDescription: when a thumbnail expands to a detail view, matchedGeometryEffect maintains object permanence — the user sees the same element grow rather than one disappear and another appear
tags: product, matched-geometry, transition, edson-product-marketing, kocienda-demo, motion
---

## Use matchedGeometryEffect for Contextual Origin Transitions

Edson's "the product is the marketing" means transitions communicate the relationship between views. When a user taps a card and it expands to fill the screen, `matchedGeometryEffect` creates visual continuity — the card morphs into the detail view rather than cross-fading. This maintains "object permanence" — the user understands that the detail view IS the card, not a replacement. Kocienda's demo culture demanded that transitions tell stories; matched geometry is how you tell the story of "this thing became that thing."

**Incorrect (cross-fade between list item and detail — no spatial continuity):**

```swift
struct GalleryView: View {
    @State private var selectedPhoto: Photo?

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
            ForEach(photos) { photo in
                Image(photo.name)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 100)
                    .clipped()
                    .onTapGesture { selectedPhoto = photo }
            }
        }
        .sheet(item: $selectedPhoto) { photo in
            // New image appears — no connection to the thumbnail
            Image(photo.name)
                .resizable()
                .scaledToFit()
        }
    }
}
```

**Correct (matched geometry creates visual continuity):**

```swift
struct GalleryView: View {
    @Namespace private var photoTransition
    @State private var selectedPhoto: Photo?

    var body: some View {
        ZStack {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                ForEach(photos) { photo in
                    if selectedPhoto != photo {
                        Image(photo.name)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 100)
                            .clipped()
                            .matchedGeometryEffect(id: photo.id, in: photoTransition)
                            .onTapGesture {
                                withAnimation(.smooth) {
                                    selectedPhoto = photo
                                }
                            }
                    }
                }
            }

            if let photo = selectedPhoto {
                Image(photo.name)
                    .resizable()
                    .scaledToFit()
                    .matchedGeometryEffect(id: photo.id, in: photoTransition)
                    .onTapGesture {
                        withAnimation(.smooth) {
                            selectedPhoto = nil
                        }
                    }
            }
        }
    }
}
```

**Requirements for matchedGeometryEffect:**
- Both source and destination must share the same `@Namespace`
- Both must use the same `id` value
- Only one instance of each `id` should be visible at a time
- Wrap the state change in `withAnimation` for the transition to animate

**When NOT to use:** Cross-screen navigation (use NavigationStack's built-in transitions), unrelated views (the user wouldn't expect visual continuity), or when the source and destination look completely different.

Reference: [matchedGeometryEffect - Apple Documentation](https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:issource:))
